import 'package:get/get.dart';
import '../../../../core/network/api_service.dart';
import '../../../../config/routes/app_routes.dart';
import '../../../dashboard/presentation/controllers/dashboard_controller.dart';
import '../../../chat/presentation/controllers/chat_inbox_controller.dart';
import '../../../../core/utils/snackbar_util.dart';

class ChatRequestController extends GetxController {
  final _api = ApiService.instance;
  String? _rejectedSessionId;

  DashboardController? get _dashboardController =>
      Get.isRegistered<DashboardController>() ? Get.find<DashboardController>() : null;
  
  final RxMap requestData = {}.obs;
  final RxBool hasRequest = false.obs;

  @override
  void onInit() {
    super.onInit();
    
    // Initial data from arguments (for direct navigation)
    if (Get.arguments != null && Get.arguments is Map && (Get.arguments as Map).isNotEmpty) {
      _updateFromData(Get.arguments as Map);
    } else {
      _syncWithQueue();
    }

    // Listen to queue changes safely
    if (_dashboardController != null) {
      ever(_dashboardController!.currentQueue, (_) => _syncWithQueue());
    }
    
    // Listen to chat session changes as a fallback
    if (Get.isRegistered<ChatInboxController>()) {
      ever(Get.find<ChatInboxController>().chatSessions, (_) => _syncWithQueue());
    }
  }

  void setIncomingRequest(Map data) {
    if (data.isEmpty) return;
    _updateFromData(data);
  }

  void clearRequest() {
    hasRequest.value = false;
    requestData.clear();
  }

  void _syncWithQueue() {
    // If an incoming request is actively displaying, do not clear it
    // unless this specific session is confirmed cancelled or ended.
    if (hasRequest.value && requestData.isNotEmpty) {
      final currentId = sessionId;
      if (Get.isRegistered<ChatInboxController>() && currentId.isNotEmpty) {
        final inboxController = Get.find<ChatInboxController>();
        final matchedSession = inboxController.chatSessions.firstWhereOrNull(
          (s) => s['_id']?.toString() == currentId,
        );
        if (matchedSession != null) {
          final status = matchedSession['status']?.toString().toLowerCase();
          if (status == 'cancelled' || status == 'completed' || status == 'ended' || status == 'declined') {
            clearRequest();
            if (Get.currentRoute == AppRoutes.chatRequest) {
              Get.back();
            }
            return;
          }
        }
      }
      return; // Preserve the current active request
    }

    // 1. Primary source: Main Queue (usually for calls)
    if (_dashboardController != null && _dashboardController!.currentQueue.isNotEmpty) {
      final firstItem = _dashboardController!.currentQueue.first;
      _updateFromData({
        'session': firstItem,
        'customer': firstItem['customer_id'] ?? firstItem['customer'] ?? {},
      });
      return;
    }

    // 2. Secondary source: Initiated Chat Sessions (fallback for chats)
    if (Get.isRegistered<ChatInboxController>()) {
      final inboxController = Get.find<ChatInboxController>();
      final pendingChat = inboxController.chatSessions.firstWhereOrNull(
        (s) {
          final id = s['_id']?.toString();
          if (id != null && id == _rejectedSessionId) return false;
          return s['status']?.toString().toLowerCase() == 'initiated';
        },
      );
      
      if (pendingChat != null) {
        _updateFromData({
          'session': pendingChat,
          'customer': pendingChat['customer_id'] ?? pendingChat['customer'] ?? {},
        });
        return;
      }
    }

    // 3. If no active request found, clear the state
    clearRequest();
  }

  void _updateFromData(Map data) {
    final Map normalized = Map.from(data);

    // Ensure 'session' map is populated
    if (normalized['session'] is! Map) {
      normalized['session'] = {
        '_id': normalized['session_id'] ?? normalized['sessionId'] ?? normalized['_id'],
        'price_per_minute': normalized['price_per_minute'] ?? normalized['pricePerMinute'],
        'status': normalized['status'] ?? 'initiated',
      };
    }

    // Ensure 'customer' map is populated
    if (normalized['customer'] is! Map || (normalized['customer'] as Map).isEmpty) {
      if (normalized['session'] is Map && normalized['session']['customer_id'] is Map) {
        normalized['customer'] = normalized['session']['customer_id'];
      } else if (normalized['session'] is Map && normalized['session']['customer'] is Map) {
        normalized['customer'] = normalized['session']['customer'];
      } else {
        normalized['customer'] = {
          '_id': normalized['customer_id'] ?? '',
          'name': normalized['customer_name'] ?? 'User',
          'profile_pic': normalized['customer_pic'] ?? normalized['profile_pic'] ?? '',
        };
      }
    }

    requestData.value = normalized;
    hasRequest.value = true;
  }

  Map get session => requestData['session'] is Map ? requestData['session'] : {};
  Map get customer => requestData['customer'] is Map ? requestData['customer'] : {};
  String get sessionId => session['_id']?.toString() ?? requestData['session_id']?.toString() ?? '';
  String get userName {
    final name = customer['name']?.toString() ?? '';
    return name.isNotEmpty ? name : 'User';
  }
  String get userPic => customer['profile_pic']?.toString() ?? customer['profileImage']?.toString() ?? '';
  num get pricePerMinute => num.tryParse(session['price_per_minute']?.toString() ?? requestData['price_per_minute']?.toString() ?? '0') ?? 0;

  Future<void> acceptChat() async {
    if (requestData.isEmpty) return;
    
    final id = sessionId;
    if (id.isEmpty) return;

    if (Get.isRegistered<ChatInboxController>()) {
      final inboxController = Get.find<ChatInboxController>();
      final session = inboxController.chatSessions.firstWhereOrNull(
        (s) => s['_id']?.toString() == id
      );

      if (session != null) {
        final status = session['status']?.toString().toLowerCase();
        if (status == 'cancelled' || status == 'completed' || status == 'ended' || status == 'declined') {
          SnackbarUtil.info('request_no_longer_available'.tr);
          clearRequest();
          if (Get.currentRoute == AppRoutes.chatRequest) Get.back();
          return;
        }
      }
    }

    final dataToPass = Map.from(requestData);
    clearRequest();

    if (Get.currentRoute == AppRoutes.chatRequest) {
      Get.offNamed(AppRoutes.partnerChat, arguments: dataToPass);
    } else {
      Get.toNamed(AppRoutes.partnerChat, arguments: dataToPass);
    }
  }

  Future<void> rejectChat() async {
    final id = sessionId;
    if (id.isEmpty) {
      clearRequest();
      if (Get.currentRoute == AppRoutes.chatRequest) {
        Get.back();
      }
      return;
    }

    _rejectedSessionId = id;
    clearRequest(); // Immediate UI dismissal on first tap!

    // Also remove from local inbox cache so _syncWithQueue won't restore it
    if (Get.isRegistered<ChatInboxController>()) {
      Get.find<ChatInboxController>().chatSessions.removeWhere(
        (s) => s['_id']?.toString() == id,
      );
    }

    if (Get.currentRoute == AppRoutes.chatRequest) {
      Get.back();
    }

    try {
      // 1. Emit cancel_chat_request directly via socket
      _dashboardController?.socket?.emit('cancel_chat_request', {
        'session_id': id,
        'reason': 'astrologer_declined',
      });

      // 2. Call backend to update DB cleanly
      await _api.post(
        '/partner/chat/end',
        data: {
          'session_id': id,
          'duration': 0,
          'reason': 'astrologer_declined',
        },
      );
    } catch (e) {
      print('Error in rejectChat: $e');
    } finally {
      _dashboardController?.loadQueue();
      if (Get.isRegistered<ChatInboxController>()) {
        Get.find<ChatInboxController>().fetchChatSessions();
      }
    }
  }
}
