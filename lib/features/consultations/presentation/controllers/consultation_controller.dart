import 'package:get/get.dart';
import '../../../../core/network/api_service.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/utils/snackbar_util.dart';

class ConsultationController extends GetxController {
  final RxList serviceOrders = [].obs;
  final RxList myServices = [].obs;
  final RxBool isLoading = false.obs;
  final RxString selectedStatus = ''.obs;

  // ── Compat aliases for existing pages ───────────────────
  RxInt selectedTab = 0.obs;
  RxList get pendingConsultations => serviceOrders;
  RxList get activeConsultations => serviceOrders;
  RxList get completedConsultations => serviceOrders;
  Future<void> loadConsultations() => _fetchServiceOrders();
  Future<void> rejectConsultation(String id) => rejectOrder(id);
  Future<void> acceptConsultation(String id) => acceptOrder(id);

  final _api = ApiService.instance;

  @override
  void onInit() {
    super.onInit();
    loadAll();
  }

  Future<void> loadAll() async {
    isLoading.value = true;
    await Future.wait([_fetchServiceOrders(), _fetchMyServices()]);
    isLoading.value = false;
  }

  Future<void> _fetchServiceOrders({String? status}) async {
    final res = await _api.get(ApiConstants.serviceOrders, queryParameters: {
      'page': 1,
      'limit': 50,
      if (status != null && status.isNotEmpty) 'status': status,
    });
    if (ApiService.isSuccess(res)) {
      serviceOrders.value = List.from(ApiService.getData(res)?['docs'] ?? []);
    }
  }

  Future<void> _fetchMyServices() async {
    final res = await _api.get(ApiConstants.myServices);
    if (ApiService.isSuccess(res)) {
      myServices.value = List.from(ApiService.getData(res) ?? []);
    }
  }

  Future<void> acceptOrder(String orderId) async {
    final res = await _api.put('/partner/service-orders/$orderId/accept');
    if (ApiService.isSuccess(res)) {
      SnackbarUtil.success('Order accepted! Payment deducted from customer.');
      await _fetchServiceOrders();
    } else {
      SnackbarUtil.error(ApiService.getMessage(res));
    }
  }

  Future<void> rejectOrder(String orderId, {String reason = ''}) async {
    final res = await _api.put('/partner/service-orders/$orderId/reject', data: {'reason': reason});
    if (ApiService.isSuccess(res)) {
      SnackbarUtil.success('Order rejected.');
      await _fetchServiceOrders();
    } else {
      SnackbarUtil.error(ApiService.getMessage(res));
    }
  }

  Future<void> assignService({
    required String serviceId,
    required String categoryId,
    required double price,
    required int duration,
  }) async {
    final res = await _api.post(ApiConstants.assignService, data: {
      'service_id': serviceId,
      'category_id': categoryId,
      'price': price,
      'duration': duration,
    });
    if (ApiService.isSuccess(res)) {
      SnackbarUtil.success('Service assigned!');
      await _fetchMyServices();
    } else {
      SnackbarUtil.error(ApiService.getMessage(res));
    }
  }

  Future<void> updateService(String serviceId, {double? price, int? duration, bool? isActive}) async {
    final data = <String, dynamic>{};
    if (price != null) data['price'] = price;
    if (duration != null) data['duration'] = duration;
    if (isActive != null) data['is_active'] = isActive;

    final res = await _api.put('/partner/services/$serviceId', data: data);
    if (ApiService.isSuccess(res)) {
      SnackbarUtil.success('Service updated!');
      await _fetchMyServices();
    } else {
      SnackbarUtil.error(ApiService.getMessage(res));
    }
  }

  Future<void> deleteService(String serviceId) async {
    final res = await _api.delete('/partner/services/$serviceId');
    if (ApiService.isSuccess(res)) {
      SnackbarUtil.success('Service deleted.');
      await _fetchMyServices();
    } else {
      SnackbarUtil.error(ApiService.getMessage(res));
    }
  }

  void filterByStatus(String status) {
    selectedStatus.value = status;
    _fetchServiceOrders(status: status);
  }

  Future<void> refresh() => loadAll();
}
