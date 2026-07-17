import 'package:get/get.dart';
import '../../../../core/network/api_service.dart';
import '../../../../config/routes/app_routes.dart';
import '../../../dashboard/presentation/controllers/dashboard_controller.dart';
import '../../../chat/presentation/controllers/chat_inbox_controller.dart';
import '../../../../core/utils/snackbar_util.dart';

class ChatRequestController extends GetxController {
  final _api = ApiService.instance;
  final _dashboardController = Get.find<DashboardController>();
  
  final RxMap requestData = {}.obs;
  final RxBool hasRequest = false.obs;

  @override
  void onInit() {
    super.onInit();
    
    // Initial data from arguments (for direct navigation)
    if (Get.arguments != null) {
      _updateFromData(Get.arguments as Map);
    } else {
      _syncWithQueue();
    }

    // Listen to queue changes
    ever(_dashboardController.currentQueue, (_) => _syncWithQueue());
    
    // Listen to chat session changes as a fallback
    if (Get.isRegistered<ChatInboxController>()) {
      ever(Get.find<ChatInboxController>().chatSessions, (_) => _syncWithQueue());
    }
  }

  void _syncWithQueue() {
    // 1. Primary source: Main Queue (usually for calls)
    if (_dashboardController.currentQueue.isNotEmpty) {
      final firstItem = _dashboardController.currentQueue.first;
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
        (s) => s['status']?.toString().toLowerCase() == 'initiated'
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
    hasRequest.value = false;
    requestData.clear();
    
    if (Get.currentRoute == AppRoutes.chatRequest) {
      Get.back();
    }
  }

  void _updateFromData(Map data) {
    requestData.value = data;
    hasRequest.value = true;
  }

  Map get session => requestData['session'] ?? {};
  Map get customer => requestData['customer'] ?? {};
  String get sessionId => session['_id']?.toString() ?? '';
  String get userName => customer['name'] ?? 'User';

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
          _syncWithQueue();
          return;
        }
      }
    }

    Get.offNamed(AppRoutes.partnerChat, arguments: Map.from(requestData));
  }

  Future<void> rejectChat() async {
    if (sessionId.isNotEmpty) {
      await _api.post(
        '/partner/chat/end',
        data: {
          'session_id': sessionId,
          'duration': 0,
          'reason': 'astrologer_declined',
        },
      );
      // Refresh queue after rejection
      _dashboardController.loadQueue();
      if (Get.isRegistered<ChatInboxController>()) {
        Get.find<ChatInboxController>().fetchChatSessions();
      }
    }
    
    // If we came from a direct popup navigation, go back. 
    // If we're on the tab, just clearing the item will handle the UI.
    if (Get.currentRoute == AppRoutes.chatRequest) {
      Get.back();
    }
  }
}
