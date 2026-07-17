import 'package:get/get.dart';
import '../../../../core/network/api_service.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/utils/snackbar_util.dart';

class PujaController extends GetxController {
  final _api = ApiService.instance;

  final RxList activePujaOrders = [].obs;
  final RxList completedPujaOrders = [].obs;
  final RxBool isLoading = false.obs;
  final RxBool isSubmitting = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadPujaOrders();
  }

  Future<void> loadPujaOrders() async {
    isLoading.value = true;
    try {
      // 1. Fetch active puja orders (pending/placed)
      final resActive = await _api.get(
        ApiConstants.pujaOrders,
        queryParameters: {'status': 'active', 'page': 1, 'limit': 100},
      );

      // 2. Fetch history puja orders (completed/cancelled/refunded)
      final resHistory = await _api.get(
        ApiConstants.pujaOrders,
        queryParameters: {'status': 'history', 'page': 1, 'limit': 100},
      );

      if (ApiService.isSuccess(resActive)) {
        final data = ApiService.getData(resActive);
        activePujaOrders.value = data is Map ? (data['docs'] ?? []) : (data ?? []);
      }

      if (ApiService.isSuccess(resHistory)) {
        final data = ApiService.getData(resHistory);
        completedPujaOrders.value = data is Map ? (data['docs'] ?? []) : (data ?? []);
      }
    } catch (e) {
      print('Error loading puja orders: $e');
      SnackbarUtil.error('Failed to load puja orders.');
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> updatePujaStatus(String orderId, String status) async {
    isSubmitting.value = true;
    try {
      final res = await _api.put(
        '${ApiConstants.pujaOrders}/$orderId/status',
        data: {'status': status},
      );

      if (ApiService.isSuccess(res)) {
        SnackbarUtil.success('Puja marked as $status successfully!');
        loadPujaOrders(); // Reload list
        return true;
      } else {
        SnackbarUtil.error(ApiService.getMessage(res));
      }
    } catch (e) {
      print('Error updating puja status: $e');
      SnackbarUtil.error('Failed to update status.');
    } finally {
      isSubmitting.value = false;
    }
    return false;
  }

  Future<bool> updateBroadcastLink(String orderId, String link) async {
    isSubmitting.value = true;
    try {
      final res = await _api.put(
        '${ApiConstants.pujaOrders}/$orderId/status',
        data: {'broadcast_link': link.trim()},
      );

      if (ApiService.isSuccess(res)) {
        SnackbarUtil.success('Broadcast link updated successfully!');
        loadPujaOrders(); // Reload list
        return true;
      } else {
        SnackbarUtil.error(ApiService.getMessage(res));
      }
    } catch (e) {
      print('Error updating broadcast link: $e');
      SnackbarUtil.error('Failed to update link.');
    } finally {
      isSubmitting.value = false;
    }
    return false;
  }
}
