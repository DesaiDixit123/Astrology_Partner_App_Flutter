import 'dart:io';
import 'package:dio/dio.dart' as dio;
import 'package:get/get.dart';
import '../../../../core/network/api_service.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/utils/snackbar_util.dart';
import '../../../dashboard/presentation/controllers/dashboard_controller.dart';

class LiveController extends GetxController {
  final RxBool isLive = false.obs;
  final RxMap activeStream = {}.obs;
  final RxList liveRequests = [].obs;
  final RxBool isLoading = false.obs;
  final RxString thumbnailUrl = ''.obs;

  Future<String?> uploadThumbnail(File file) async {
    isLoading.value = true;
    try {
      final formData = dio.FormData.fromMap({
        'file': await dio.MultipartFile.fromFile(file.path),
      });
      final res = await _api.post(ApiConstants.upload, data: formData);
      if (ApiService.isSuccess(res)) {
        final data = ApiService.getData(res);
        final url = data['full_url'] ?? '';
        thumbnailUrl.value = url;
        return url;
      } else {
        SnackbarUtil.error('Failed to upload thumbnail');
        return null;
      }
    } catch (e) {
      SnackbarUtil.error('Error uploading thumbnail: $e');
      return null;
    } finally {
      isLoading.value = false;
    }
  }

  final _api = ApiService.instance;

  Future<void> startLive({
    String title = '',
    String thumbnail = '',
    bool isCallEnabled = true,
    bool isVideoCallEnabled = true,
    int callDuration = 15,
  }) async {
    isLoading.value = true;
    final res = await _api.post(ApiConstants.startLive, data: {
      'title': title,
      'thumbnail': thumbnail,
      'is_call_enabled': isCallEnabled,
      'is_video_call_enabled': isVideoCallEnabled,
      'call_duration': callDuration,
    });
    isLoading.value = false;
    if (ApiService.isSuccess(res)) {
      isLive.value = true;
      activeStream.value = Map<String, dynamic>.from(ApiService.getData(res) ?? {});
      if (Get.isRegistered<DashboardController>()) {
        final dashboardController = Get.find<DashboardController>();
        dashboardController.isOnline.value = false;
        dashboardController.isCallAvailable.value = false;
        dashboardController.isChatAvailable.value = false;
        dashboardController.isVideoCallAvailable.value = false;
        dashboardController.profile['is_online'] = false;
        dashboardController.profile['is_call_available'] = false;
        dashboardController.profile['is_chat_available'] = false;
        dashboardController.profile['is_video_call_available'] = false;
      }
      SnackbarUtil.success(ApiService.getMessage(res));
    } else {
      SnackbarUtil.error(ApiService.getMessage(res));
    }
  }

  Future<void> endLive() async {
    final res = await _api.post(ApiConstants.endLive);
    if (ApiService.isSuccess(res)) {
      isLive.value = false;
      activeStream.clear();
      if (Get.isRegistered<DashboardController>()) {
        final dashboardController = Get.find<DashboardController>();
        dashboardController.isOnline.value = false;
        dashboardController.isCallAvailable.value = false;
        dashboardController.isChatAvailable.value = false;
        dashboardController.isVideoCallAvailable.value = false;
        dashboardController.profile['is_online'] = false;
        dashboardController.profile['is_call_available'] = false;
        dashboardController.profile['is_chat_available'] = false;
        dashboardController.profile['is_video_call_available'] = false;
      }
      SnackbarUtil.success('Live stream ended.');
    } else {
      SnackbarUtil.error(ApiService.getMessage(res));
    }
  }

  Future<void> loadRequests() async {
    final res = await _api.get(ApiConstants.liveRequests);
    if (ApiService.isSuccess(res)) {
      liveRequests.value = List.from(ApiService.getData(res) ?? []);
    }
  }

  Future<void> acceptRequest(String requestId) async {
    final res = await _api.put('/partner/live/requests/$requestId', data: {'action': 'accept'});
    if (ApiService.isSuccess(res)) {
      SnackbarUtil.success('Request accepted. Customer will be notified to join.');
      liveRequests.removeWhere((e) => e['_id'] == requestId);
    } else {
      SnackbarUtil.error(ApiService.getMessage(res));
    }
  }

  Future<void> rejectRequest(String requestId) async {
    final res = await _api.put('/partner/live/requests/$requestId', data: {'action': 'reject'});
    if (ApiService.isSuccess(res)) {
      liveRequests.removeWhere((e) => e['_id'] == requestId);
    } else {
      SnackbarUtil.error(ApiService.getMessage(res));
    }
  }
}
