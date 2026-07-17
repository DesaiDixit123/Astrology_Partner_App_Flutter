import 'package:get/get.dart';
import '../../../../core/network/api_service.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/utils/snackbar_util.dart';

class EarningsController extends GetxController {
  final RxDouble walletBalance = 0.0.obs;
  final RxList earnings = [].obs;
  final RxList withdrawals = [].obs;
  final RxBool isLoading = false.obs;
  final RxBool isWithdrawing = false.obs;

  // ── Compat aliases for existing pages ─────────────────
  final RxMap dashboardData = {}.obs;
  final _api = ApiService.instance;

  Future<void> fetchDashboard() async {
    final res = await _api.get(ApiConstants.dashboard);
    if (ApiService.isSuccess(res)) {
      final data = ApiService.getData(res) as Map<String, dynamic>?;
      if (data != null) {
        dashboardData.value = Map<String, dynamic>.from(data['earnings'] ?? {});
        walletBalance.value = (data['wallet_balance'] ?? 0).toDouble();
      }
    }
  }

  Future<void> fetchTransactions() => _fetchEarnings();
  RxList get transactions => earnings;

  @override
  void onInit() {
    super.onInit();
    loadAll();
  }

  Future<void> loadAll() async {
    isLoading.value = true;
    await Future.wait([fetchDashboard(), _fetchEarnings(), _fetchWithdrawals()]);
    isLoading.value = false;
  }


  Future<void> _fetchEarnings({String? sourceFilter}) async {
    final res = await _api.get(ApiConstants.earnings, queryParameters: {
      'page': 1,
      'limit': 50,
      if (sourceFilter != null) 'type': sourceFilter,
    });
    if (ApiService.isSuccess(res)) {
      earnings.value = List.from(ApiService.getData(res)?['docs'] ?? []);
    }
  }

  Future<void> _fetchWithdrawals() async {
    final res = await _api.get(ApiConstants.withdrawalHistory, queryParameters: {'page': 1, 'limit': 20});
    if (ApiService.isSuccess(res)) {
      withdrawals.value = List.from(ApiService.getData(res)?['docs'] ?? []);
    }
  }

  Future<bool> requestWithdrawal(double amount) async {
    if (amount <= 0 || amount > walletBalance.value) {
      SnackbarUtil.error('Invalid amount. Available balance: ₹${walletBalance.value.toStringAsFixed(2)}');
      return false;
    }
    isWithdrawing.value = true;
    final res = await _api.post(ApiConstants.requestWithdrawal, data: {'amount': amount});
    isWithdrawing.value = false;
    if (ApiService.isSuccess(res)) {
      walletBalance.value -= amount;
      SnackbarUtil.success('Withdrawal request submitted. You\'ll receive ₹$amount in 3-5 business days.');
      await _fetchWithdrawals();
      return true;
    } else {
      SnackbarUtil.error(ApiService.getMessage(res));
      return false;
    }
  }

  Future<void> filterBySource(String? source) => _fetchEarnings(sourceFilter: source);
  Future<void> refresh() => loadAll();
}
