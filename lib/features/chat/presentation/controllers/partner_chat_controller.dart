import 'dart:async';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart' as dio;
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/network/api_service.dart';
import '../../../dashboard/presentation/controllers/dashboard_controller.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/utils/snackbar_util.dart';
import '../../../../core/utils/image_picker_util.dart';
import '../../../../config/routes/app_routes.dart';
import 'chat_inbox_controller.dart';

class PartnerChatController extends GetxController {
  final RxList messages = [].obs;
  final RxBool isLoading = false.obs;
  final RxBool isSending = false.obs;
  final RxBool isEnded = false.obs;
  final RxInt chatDuration = 0.obs;
  final RxMap currentSession = {}.obs;
  final RxMap customer = {}.obs;
  final RxBool isOtherTyping = false.obs;
  final RxBool isReadOnly = false.obs;
  final RxBool isUploading = false.obs;
  bool _isShowingEndedDialog = false;

  final ImagePicker _picker = ImagePicker();

  IO.Socket? _socket;
  final _api = ApiService.instance;
  Timer? _durationTimer;
  Timer? _typingDebounce;
  final ScrollController scrollController = ScrollController();
  final TextEditingController msgController = TextEditingController();
  String _astrologerId = '';

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments as Map?;
    if (args != null) {
      if (args['session'] != null) {
        currentSession.value = args['session'];
        // The customer might be nested in 'session' (via customer_id) or passed adjacent in the notification payload
        customer.value = args['customer'] ?? currentSession['customer_id'] ?? currentSession['customer'] ?? {};
      } else if (args['sessionId'] != null) {
        currentSession.value = {'_id': args['sessionId']};
      }
    }
    
    _loadUserAndInit();
  }

  Future<void> _loadUserAndInit() async {
    final prefs = await SharedPreferences.getInstance();
    _astrologerId = prefs.getString(AppConstants.keyUserId) ?? '';
    
    final args = Get.arguments as Map?;
    isReadOnly.value = args?['readonly'] == true;
    
    if (!isReadOnly.value) {
      _initSocket();
    }
    
    if (currentSession['_id'] != null) {
      await _resumeSession(currentSession['_id']);
    }
  }

  @override
  void onClose() {
    if (!isReadOnly.value && !isEnded.value && currentSession['_id'] != null) {
      _socket?.emit('end_chat', {'session_id': currentSession['_id']});
    }
    _durationTimer?.cancel();
    _typingDebounce?.cancel();
    scrollController.dispose();
    msgController.dispose();
    _socket?.disconnect();
    super.onClose();
  }


  void _initSocket() {
    _socket = IO.io(ApiConstants.baseUrl, IO.OptionBuilder()
      .setTransports(['websocket'])
      .build());

    _socket?.onConnect((_) {
      print('Partner Chat: Connected to Socket.io');
      if (currentSession['_id'] != null) {
        _joinRoom(currentSession['_id']);
      }
    });

    // Listen for all incoming chat/call/video events
    _socket?.on('receive_message', (data) {
      if (data is Map) {
        messages.add(data);
        _scrollToBottom();
      }
    });

    _socket?.on('typing', (data) {
      if (data is Map) {
        isOtherTyping.value = data['is_typing'] == true;
      }
    });

    _socket?.on('chat_ended', (data) {
      if (isEnded.value && _isShowingEndedDialog) return; // Already handled locally
      isEnded.value = true;
      _durationTimer?.cancel();
      _showEndedDialog(data is Map ? data : {});
    });

    _socket?.on('partner_joined', (data) {
      print('Partner joined the chat room (session became active)');
      _startTimer();
    });

    // ✅ FIXED: Listen for availability restored notification from backend
    _socket?.on('chat_availability_updated', (data) {
      if (data is Map && data['is_chat_available'] == true) {
        SnackbarUtil.success('You are now available for new chats!');
        // Refresh dashboard to reflect latest status
        if (Get.isRegistered<DashboardController>()) {
          Get.find<DashboardController>().loadDashboard();
        }
      }
    });

    // Add listeners for call/video events as needed
    // _socket?.on('call_request', ...);
    // _socket?.on('video_call_request', ...);
  }

  void _joinRoom(String sessionId) {
    _socket?.emit('join_chat', {
      'session_id': sessionId,
      'customer_id': customer['_id'],
      'astrologer_id': _astrologerId,
      'participant_type': 'astrologer',
    });
  }

  void onMessageChanged(String text) {
    if (currentSession['_id'] == null) return;
    _socket?.emit('typing', {
      'session_id': currentSession['_id'],
      'is_typing': true
    });

    _typingDebounce?.cancel();
    _typingDebounce = Timer(const Duration(seconds: 2), () {
      _socket?.emit('typing', {
        'session_id': currentSession['_id'],
        'is_typing': false
      });
    });
  }

  Future<void> _resumeSession(String sessionId) async {
    isLoading.value = true;
    final res = await _api.get('/partner/chat/messages/$sessionId');
    isLoading.value = false;

    if (ApiService.isSuccess(res) && res != null) {
      final data = res['Data'];
      
      // Try to get status from primary response
      String? status;
      if (data is Map && data['session'] != null) {
        status = data['session']['status']?.toString().toLowerCase();
        currentSession.value = Map<String, dynamic>.from(data['session']);
      }

      // Fallback: Check global inbox sessions if status is missing or looks suspicious
      if (status == null && Get.isRegistered<ChatInboxController>()) {
        final inboxSessions = Get.find<ChatInboxController>().chatSessions;
        final matchingSession = inboxSessions.firstWhereOrNull(
          (s) => s['_id']?.toString() == sessionId,
        );
        if (matchingSession != null) {
          status = matchingSession['status']?.toString().toLowerCase();
          currentSession.value = Map<String, dynamic>.from(matchingSession);
        }
      }

      // If status is definitely inactive, block access (only if NOT readonly)
      if (!isReadOnly.value && status != null && 
          (status == 'cancelled' || status == 'completed' || status == 'ended' || status == 'declined')) {
        _showStatusErrorDialog(status);
        return;
      }

      // Sync timer if connected
      if (status == 'connected' && currentSession['started_at'] != null) {
        try {
          final startedAt = DateTime.parse(currentSession['started_at'].toString()).toLocal();
          final now = DateTime.now();
          final diff = now.difference(startedAt).inSeconds;
          chatDuration.value = diff > 0 ? diff : 0;
        } catch (_) {}
      }

      messages.value = List.from(data is List ? data : (data['messages'] ?? []));
      if (!isReadOnly.value) {
        _joinRoom(sessionId);
        if (status == 'connected') {
          _startTimer();
        }
      }
      _scrollToBottom();
    }
  }

  void _showStatusErrorDialog(String status) {
    if (Get.isDialogOpen == true) Get.back();
    Get.defaultDialog(
      title: 'Session Inactive',
      middleText: 'This chat session has already been $status.',
      textConfirm: 'OK',
      onConfirm: () {
        Get.back(); // Close dialog
        Get.back(); // Exit chat screen
      },
      barrierDismissible: false,
    );
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (scrollController.hasClients) {
        scrollController.animateTo(
          scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _startTimer() {
    _durationTimer?.cancel();
    // In a real app, we should calculate the elapsed time from startTime
    _durationTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      chatDuration.value++;
    });
  }

  Future<void> sendMessage(String text, {String? image, String messageType = 'text'}) async {
    if (isEnded.value) return;
    if (messageType == 'text' && text.trim().isEmpty) return;

    // ✅ FIXED: Do NOT re-emit join_chat on every sendMessage — already joined at session start

    final payload = {
      'session_id': currentSession['_id'],
      'sender_id': _astrologerId,
      'sender_type': 'astrologer',
      'text': text.trim(),
      'image': image ?? '',
      'message_type': messageType
    };

    _socket?.emit('send_message', payload);
  }

  Future<void> pickAndSendImage([ImageSource? source]) async {
    try {
      final selectedSource = source ?? await ImagePickerUtil.showImageSourceBottomSheet();
      if (selectedSource == null) return;
      final XFile? file = await _picker.pickImage(
        source: selectedSource,
        imageQuality: 70,
      );

      if (file != null) {
        await _uploadAndSendImage(file);
      }
    } catch (e) {
      SnackbarUtil.error('Error picking image: $e');
    }
  }

  Future<void> _uploadAndSendImage(XFile file) async {
    isUploading.value = true;
    try {
      final String fileName = file.path.split('/').last;
      final dio.FormData formData = dio.FormData.fromMap({
        'file': await dio.MultipartFile.fromFile(file.path, filename: fileName),
      });

      final res = await _api.post(ApiConstants.upload, data: formData);

      if (ApiService.isSuccess(res)) {
        final data = ApiService.getData(res);
        final imageUrl = data['full_url'] ?? '';
        if (imageUrl.isNotEmpty) {
          await sendMessage('', image: imageUrl, messageType: 'image');
        }
      } else {
        SnackbarUtil.error(ApiService.getMessage(res));
      }
    } catch (e) {
      SnackbarUtil.error('Error uploading image: $e');
    } finally {
      isUploading.value = false;
    }
  }

  Future<void> endChat() async {
    if (isEnded.value) return;
    isEnded.value = true;
    _durationTimer?.cancel();
    
    final sessionId = currentSession['_id']?.toString();
    if (sessionId != null && sessionId.isNotEmpty) {
      Map<String, dynamic>? result;
      try {
        final res = await _api.post('/partner/chat/end', data: {
          'session_id': sessionId,
          'duration': chatDuration.value
        });
        if (ApiService.isSuccess(res)) {
          result = ApiService.getData(res) as Map<String, dynamic>?;
        }
      } catch (_) {}
      
      // ✅ FIXED: Update astrologer availability after chat ends using PUT method and correct endpoint
      try {
        await _api.put(ApiConstants.updateStatus, data: {
          'is_chat_available': true,
          'is_call_available': true,
          'is_video_call_available': true,
        });
      } catch (_) {}
      
      // Also emit socket event
      _socket?.emit('end_chat', {'session_id': sessionId});
      if (Get.isRegistered<ChatInboxController>()) {
        Get.find<ChatInboxController>().fetchChatSessions();
      }
      _showEndedDialog(result ?? {});
    } else {
      Get.back();
    }
  }

  void _showEndedDialog(Map data) {
    if (_isShowingEndedDialog) return;
    _isShowingEndedDialog = true;

    if (Get.isDialogOpen == true) Get.back();
    
    final int durationSec = (data['duration'] ?? chatDuration.value) as int;
    final double totalEarning = (data['total_charge'] as num?)?.toDouble() ?? (data['total_earning'] as num?)?.toDouble() ?? 0.0;
    final double balance = (data['astrologer_balance'] as num?)?.toDouble() ?? 0.0;
    final String reason = data['reason'] ?? 'Session completed';

    final String durationText = '${(durationSec ~/ 60).toString().padLeft(2, '0')}:${(durationSec % 60).toString().padLeft(2, '0')}';

    Get.defaultDialog(
      title: 'Chat Ended',
      content: Column(
        children: [
          if (reason.isNotEmpty && reason != 'Session completed')
            Text(reason, style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          _summaryRow('Duration', durationText),
          _summaryRow('Amount Earned', '₹${totalEarning.toStringAsFixed(2)}'),
          if (balance > 0) _summaryRow('Wallet Balance', '₹${balance.toStringAsFixed(2)}'),
        ],
      ),
      textConfirm: 'OK',
      onConfirm: () {
        _isShowingEndedDialog = false;
        Get.back(); // Close dialog first
        
        // Show Toastify Message (Success Snackbar)
        SnackbarUtil.success('Chat ended. Earning: ₹${totalEarning.toStringAsFixed(2)}');
        
        // Refresh inbox sessions
        if (Get.isRegistered<ChatInboxController>()) {
          Get.find<ChatInboxController>().fetchChatSessions();
        }

        // Redirect to Home Page (first tab of Dashboard)
        if (Get.isRegistered<DashboardController>()) {
          final dashboard = Get.find<DashboardController>();
          dashboard.currentIndex.value = 0; // Reset to Home Tab
          dashboard.loadDashboard();
        }
        Get.offAllNamed(AppRoutes.dashboard);
      },
      barrierDismissible: false,
    );
  }

  Widget _summaryRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
