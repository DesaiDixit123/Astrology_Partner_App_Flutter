import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;
import '../../../../core/network/api_service.dart';
import '../../../../config/routes/app_routes.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/utils/snackbar_util.dart';
import '../../../chat/presentation/controllers/chat_inbox_controller.dart';
import '../../../calls/presentation/controllers/partner_call_controller.dart';
import '../../../profile/presentation/controllers/profile_controller.dart';

class DashboardController extends GetxController {
  final RxMap dashboardData = {}.obs;
  final RxMap profile = {}.obs;
  final RxMap earningsSummary = {}.obs;
  final RxList currentQueue = [].obs;
  final RxBool isLoading = false.obs;
  final RxBool isOnline = false.obs;
  final RxBool isCallAvailable = false.obs;
  final RxBool isChatAvailable = false.obs;
  final RxBool isVideoCallAvailable = false.obs;
  final RxBool hasActiveSubscription = false.obs;
  final RxMap activeSubscriptionData = {}.obs;

  // ── Compat aliases for existing pages ───────────────────
  RxInt currentIndex = 0.obs;
  void changeTab(int index) => currentIndex.value = index;
  Future<void> fetchDashboard() => loadDashboard();
  RxMap get stats => earningsSummary;

  final _api = ApiService.instance;
  io.Socket? _socket;

  @override
  void onInit() {
    super.onInit();
    _bootstrapDashboard();
  }

  @override
  void onClose() {
    _socket?.disconnect();
    super.onClose();
  }

  String? get approvalStatus {
    final value = profile['approve_status']?.toString();
    if (value == null || value.isEmpty) {
      return null;
    }
    return value;
  }

  String get rejectionReason =>
      profile['rejection_reason']?.toString().trim() ?? '';

  Future<void> _bootstrapDashboard() async {
    await _hydrateCachedApprovalState();
    await loadDashboard();
    if (approvalStatus == 'approved' && !hasActiveSubscription.value) {
      Get.toNamed(AppRoutes.subscription);
    }
  }

  Future<void> _hydrateCachedApprovalState() async {
    final prefs = await SharedPreferences.getInstance();
    final cachedApprovalStatus = prefs.getString(
      AppConstants.keyApprovalStatus,
    );
    if (cachedApprovalStatus == null || cachedApprovalStatus.isEmpty) {
      return;
    }

    profile['approve_status'] = cachedApprovalStatus;

    final cachedRejectionReason = prefs.getString(
      AppConstants.keyApprovalRejectionReason,
    );
    if (cachedRejectionReason != null && cachedRejectionReason.isNotEmpty) {
      profile['rejection_reason'] = cachedRejectionReason;
    } else {
      profile.remove('rejection_reason');
    }

    profile.refresh();
  }

  Future<void> _cacheApprovalState(Map<String, dynamic> data) async {
    final prefs = await SharedPreferences.getInstance();
    final currentApprovalStatus = data['approve_status']?.toString().trim();
    if (currentApprovalStatus != null && currentApprovalStatus.isNotEmpty) {
      await prefs.setString(
        AppConstants.keyApprovalStatus,
        currentApprovalStatus,
      );
    }

    final currentRejectionReason = data['rejection_reason']?.toString().trim();
    if (currentRejectionReason != null && currentRejectionReason.isNotEmpty) {
      await prefs.setString(
        AppConstants.keyApprovalRejectionReason,
        currentRejectionReason,
      );
    } else {
      await prefs.remove(AppConstants.keyApprovalRejectionReason);
    }
  }

  Future<void> loadDashboard() async {
    isLoading.value = true;
    final results = await Future.wait([
      _api.get(ApiConstants.dashboard),
      _api.get(ApiConstants.profile),
      _api.get(ApiConstants.subscriptionActive),
    ]);
    final res = results[0];
    final profileRes = results[1];
    final subRes = results[2];
    isLoading.value = false;

    if (ApiService.isSuccess(subRes)) {
      final subData = ApiService.getData(subRes);
      if (subData is Map && subData['active_subscription'] != null) {
        final activeSub = subData['active_subscription'] as Map;
        activeSubscriptionData.value = activeSub;
        hasActiveSubscription.value = activeSub['status'] == 'active';
      } else {
        activeSubscriptionData.clear();
        hasActiveSubscription.value = false;
      }
    }

    if (ApiService.isSuccess(res)) {
      final data = ApiService.getData(res) as Map<String, dynamic>?;
      if (data != null) {
        dashboardData.value = data;

        final dashboardProfile = Map<String, dynamic>.from(
          data['profile'] ?? {},
        );
        if (ApiService.isSuccess(profileRes)) {
          final fullProfileData =
              ApiService.getData(profileRes) as Map<String, dynamic>?;
          if (fullProfileData != null) {
            dashboardProfile.addAll(fullProfileData);
          }
        }
        profile.value = dashboardProfile;
        await _cacheApprovalState(dashboardProfile);

        earningsSummary.value = Map<String, dynamic>.from(
          data['earnings'] ?? {},
        );
        currentQueue.value = List.from(data['current_queue'] ?? []);

        // Sync toggles from server state
        isOnline.value = profile['is_online'] == true;
        isCallAvailable.value = profile['is_call_available'] == true;
        isChatAvailable.value = profile['is_chat_available'] == true;
        isVideoCallAvailable.value = profile['is_video_call_available'] == true;

        if (Get.isRegistered<PartnerCallController>()) {
          PartnerCallController.to.updatePresenceRegistration(
            astrologerId: profile['_id']?.toString() ?? '',
            isOnline: isOnline.value,
          );
        }

        if (!hasActiveSubscription.value && isOnline.value) {
          isOnline.value = false;
          isCallAvailable.value = false;
          isChatAvailable.value = false;
          isVideoCallAvailable.value = false;
          _socket?.disconnect();
        }

        if (isOnline.value) {
          _initSocket();
        }
      }
    }
  }

  void _initSocket() {
    if (_socket != null) {
      if (_socket!.connected) return;
      _socket!.connect();
      return;
    }

    final astrologerId = profile['_id']?.toString();
    if (astrologerId == null) return;

    _socket = io.io(
      ApiConstants.baseUrl,
      io.OptionBuilder()
          .setTransports(['websocket'])
          .disableAutoConnect()
          .build(),
    );

    _socket?.onConnect((_) {
      debugPrint('Dashboard: Connected to Socket.io');
      _registerIfReady();
    });

    _socket?.on('new_chat_session', (data) {
      if (data is Map) {
        debugPrint('New chat session received: $data');
        if (Get.isDialogOpen == true) return; // Prevent duplicate dialogs

        if (Get.isRegistered<ChatInboxController>()) {
          Get.find<ChatInboxController>().fetchChatSessions();
        }

        loadQueue(); // Synchronize the Requests tab
        Get.toNamed(AppRoutes.chatRequest, arguments: data);
      }
    });

    _socket?.on('cancel_chat_request', (data) {
      loadQueue(); // Synchronize the Requests tab
      if (Get.isRegistered<ChatInboxController>()) {
        Get.find<ChatInboxController>().fetchChatSessions();
      }
      if (Get.currentRoute == AppRoutes.chatRequest) {
        Get.back(); // Close the incoming request screen
        SnackbarUtil.info('Chat request was cancelled by the user.');
      }
    });

    _socket?.on('follower_update', (data) {
      debugPrint('Follower update received in real-time: $data');
      if (Get.isRegistered<ProfileController>()) {
        Get.find<ProfileController>().loadProfile();
      }
    });

    _socket?.on('astrologer_status_update', (data) {
      if (data is Map && data['followers_count'] != null) {
        debugPrint('Astrologer followers status update: $data');
        if (Get.isRegistered<ProfileController>()) {
          Get.find<ProfileController>().loadProfile();
        }
      }
    });

    _socket?.onDisconnect(
      (_) => debugPrint('Disconnected from Socket.io server'),
    );

    _socket?.connect();
  }

  void _registerIfReady() {
    if (_socket == null || !_socket!.connected) return;
    final astrologerId = profile['_id']?.toString();
    if (astrologerId != null && astrologerId.isNotEmpty) {
      _socket?.emit('register_astrologer', astrologerId);
      debugPrint('Dashboard: Registered astrologer $astrologerId');
    }
  }

  Future<void> toggleOnlineStatus(bool value) async {
    if (!hasActiveSubscription.value && value) {
      showSubscriptionRequiredDialog();
      return;
    }
    isOnline.value = value;
    if (Get.isRegistered<PartnerCallController>()) {
      PartnerCallController.to.updatePresenceRegistration(
        astrologerId: profile['_id']?.toString() ?? '',
        isOnline: value,
      );
    }
    if (value) {
      _initSocket();
    } else {
      _socket?.disconnect();
      // Automatically disable all services when going offline
      isCallAvailable.value = false;
      isChatAvailable.value = false;
      isVideoCallAvailable.value = false;
    }
    await _updateStatus(
      isOnline: value,
      isCallAvailable: value ? isCallAvailable.value : false,
      isChatAvailable: value ? isChatAvailable.value : false,
      isVideoCallAvailable: value ? isVideoCallAvailable.value : false,
    );
  }

  Future<void> toggleCallAvailability(bool value) async {
    if (!hasActiveSubscription.value && value) {
      showSubscriptionRequiredDialog();
      return;
    }
    if (!isOnline.value && value) {
      _showMustOnlineDialog();
      return;
    }
    isCallAvailable.value = value;
    await _updateStatus(isCallAvailable: value);
  }

  Future<void> toggleChatAvailability(bool value) async {
    if (!hasActiveSubscription.value && value) {
      showSubscriptionRequiredDialog();
      return;
    }
    if (!isOnline.value && value) {
      _showMustOnlineDialog();
      return;
    }
    isChatAvailable.value = value;
    await _updateStatus(isChatAvailable: value);
  }

  Future<void> toggleVideoCallAvailability(bool value) async {
    if (!hasActiveSubscription.value && value) {
      showSubscriptionRequiredDialog();
      return;
    }
    if (!isOnline.value && value) {
      _showMustOnlineDialog();
      return;
    }
    isVideoCallAvailable.value = value;
    await _updateStatus(isVideoCallAvailable: value);
  }

  void _showMustOnlineDialog() {
    Get.defaultDialog(
      title: 'Action Required',
      middleText: 'You must be Online first to enable services.',
      textConfirm: 'OK',
      onConfirm: () => Get.back(),
    );
  }

  void showSubscriptionRequiredDialog() {
    Get.defaultDialog(
      title: 'Subscription Required',
      middleText: 'You need an active subscription package to toggle online presence or enable customer services.',
      textConfirm: 'Buy Subscription',
      textCancel: 'Cancel',
      confirmTextColor: Colors.white,
      onConfirm: () {
        Get.back();
        Get.toNamed(AppRoutes.subscription);
      },
    );
  }

  Future<void> _updateStatus({
    bool? isOnline,
    bool? isCallAvailable,
    bool? isChatAvailable,
    bool? isVideoCallAvailable,
  }) async {
    final body = <String, dynamic>{};
    if (isOnline != null) body['is_online'] = isOnline;
    if (isCallAvailable != null) body['is_call_available'] = isCallAvailable;
    if (isChatAvailable != null) body['is_chat_available'] = isChatAvailable;
    if (isVideoCallAvailable != null) {
      body['is_video_call_available'] = isVideoCallAvailable;
    }
    await _api.put(ApiConstants.updateStatus, data: body);
  }

  Future<void> loadQueue() async {
    final res = await _api.get(ApiConstants.queue);
    if (ApiService.isSuccess(res)) {
      currentQueue.value = List.from(ApiService.getData(res) ?? []);
    }
  }

  Future<void> refreshDashboard() async {
    await loadDashboard();
    final status = approvalStatus;
    if (status == 'approved') {
      SnackbarUtil.success('Account approved successfully!');
      if (!hasActiveSubscription.value) {
        Get.toNamed(AppRoutes.subscription);
      }
    } else if (status == 'rejected') {
      SnackbarUtil.error(rejectionReason.isEmpty ? 'Account rejected.' : 'Account rejected: $rejectionReason');
    } else {
      SnackbarUtil.info('Status refreshed: Still under review.');
    }
  }
}
