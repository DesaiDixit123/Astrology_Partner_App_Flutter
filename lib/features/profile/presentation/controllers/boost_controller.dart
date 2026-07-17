import 'package:get/get.dart';
import '../../../../core/network/api_service.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/utils/snackbar_util.dart';

class BoostController extends GetxController {
  final _api = ApiService.instance;

  final RxMap eligibility = {}.obs;
  final RxList history = [].obs;
  final RxMap settings = {}.obs;
  final RxBool isLoading = false.obs;
  final RxBool isApplying = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchBoostData();
  }

  Future<void> fetchBoostData() async {
    isLoading.value = true;
    await Future.wait([
      checkEligibility(),
      fetchHistory(),
    ]);
    isLoading.value = false;
  }

  Future<void> checkEligibility() async {
    final res = await _api.get(ApiConstants.boostCheckEligibility);
    if (ApiService.isSuccess(res)) {
      eligibility.value = ApiService.getData(res) as Map<String, dynamic>? ?? {};
    }
  }

  Future<void> fetchHistory() async {
    final res = await _api.get(ApiConstants.boostHistory);
    if (ApiService.isSuccess(res)) {
      final data = ApiService.getData(res) as Map<String, dynamic>? ?? {};
      history.assignAll(List.from(data['history']?['docs'] ?? []));
      settings.value = data['settings'] as Map<String, dynamic>? ?? {};
    }
  }

  Future<bool> applyBoost() async {
    isApplying.value = true;
    final res = await _api.post(ApiConstants.boostApply);
    isApplying.value = false;

    if (ApiService.isSuccess(res)) {
      SnackbarUtil.success('Profile boosted successfully!');
      fetchBoostData(); // Refresh info
      return true;
    } else {
      SnackbarUtil.error(ApiService.getMessage(res));
      return false;
    }
  }

  List<String> get benefits => List<String>.from(settings['benefits'] ?? []);
  
  double get chatCommission => (settings['chatCommission'] ?? 0).toDouble();
  double get callCommission => (settings['callCommission'] ?? 0).toDouble();
  double get videoCommission => (settings['videoCommission'] ?? 0).toDouble();
  
  int get remainingBoosts {
    final limit = (settings['monthlyBoostLimit'] ?? 0).toInt();
    final used = (eligibility['requirements']?['monthlyBoostUsed'] ?? 0).toInt();
    return limit - used;
  }

  double get boostPrice => (settings['boostPrice'] ?? 0).toDouble();
}
