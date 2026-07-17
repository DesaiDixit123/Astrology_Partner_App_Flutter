import 'package:get/get.dart';
import '../../../../core/network/api_service.dart';
import '../../../../config/routes/app_routes.dart';

class ChatInboxController extends GetxController {
  final RxList chatSessions = [].obs;
  final RxBool isLoading = false.obs;
  final _api = ApiService.instance;
  @override
  void onInit() {
    super.onInit();
    fetchChatSessions();
  }

  @override
  void onClose() {
    super.onClose();
  }

  Future<void> fetchChatSessions() async {
    isLoading.value = true;
    final res = await _api.get('/partner/chat/sessions');
    isLoading.value = false;

    if (ApiService.isSuccess(res)) {
      chatSessions.value = List.from(ApiService.getData(res) ?? []);
    }
  }

  void goToChat(Map session) {
    final status = (session['status'] ?? '').toString().toLowerCase();
    final isCompleted = status == 'completed' || status == 'cancelled' || status == 'ended' || status == 'declined';
    Get.toNamed(AppRoutes.partnerChat, arguments: {
      'session': session,
      'readonly': isCompleted,
    });
  }
}
