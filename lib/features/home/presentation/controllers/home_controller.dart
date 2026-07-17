import 'package:get/get.dart';
import '../../../../core/network/api_service.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/utils/snackbar_util.dart';

class HomeController extends GetxController {
  final RxMap dashboardData = {}.obs;
  final RxList myBlogs = [].obs;
  final RxBool isLoading = false.obs;

  // ── Compat aliases for existing pages ───────────────────
  Future<void> loadDashboard() => loadHome();
  RxMap get stats => dashboardData;
  RxList get pendingRequests => [].obs;
  Future<void> acceptRequest(String id) async {}

  final _api = ApiService.instance;

  @override
  void onInit() {
    super.onInit();
    loadHome();
  }

  Future<void> loadHome() async {
    isLoading.value = true;
    await Future.wait([_fetchDashboard(), _fetchBlogs()]);
    isLoading.value = false;
  }

  Future<void> _fetchDashboard() async {
    final res = await _api.get(ApiConstants.dashboard);
    if (ApiService.isSuccess(res)) {
      final data = ApiService.getData(res) as Map<String, dynamic>?;
      if (data != null) {
        final earnings = data['earnings'] as Map<String, dynamic>? ?? {};
        final profile = data['profile'] as Map<String, dynamic>? ?? {};
        
        dashboardData.value = {
          'todayEarnings': earnings['todayEarnings'] ?? 0,
          'totalEarnings': earnings['totalEarnings'] ?? 0,
          'rating': profile['rating'] ?? 0.0,
          'totalReviews': profile['total_reviews'] ?? 0,
          'totalSessions': profile['total_sessions'] ?? 0,
          'followers': data['followers'] ?? 0,
          'walletBalance': data['wallet_balance'] ?? 0,
        };
      }
    }
  }

  Future<void> _fetchBlogs() async {
    final res = await _api.get(ApiConstants.myBlogs, queryParameters: {'page': 1, 'limit': 20});
    if (ApiService.isSuccess(res)) {
      myBlogs.value = List.from(ApiService.getData(res)?['docs'] ?? []);
    }
  }

  Future<void> createBlog(String imageUrl, {String title = '', String content = ''}) async {
    if (imageUrl.isEmpty) {
      SnackbarUtil.error('Please upload a blog image first.');
      return;
    }
    final res = await _api.post(ApiConstants.createBlog, data: {
      'image': imageUrl,
      'title': title,
      'content': content,
    });
    if (ApiService.isSuccess(res)) {
      SnackbarUtil.success('Blog submitted for review!');
      await _fetchBlogs();
    } else {
      SnackbarUtil.error(ApiService.getMessage(res));
    }
  }

  Future<void> deleteBlog(String blogId) async {
    final res = await _api.delete('/partner/blog/$blogId');
    if (ApiService.isSuccess(res)) {
      SnackbarUtil.success('Blog deleted.');
      myBlogs.removeWhere((b) => b['_id'] == blogId);
    } else {
      SnackbarUtil.error(ApiService.getMessage(res));
    }
  }

  Future<void> refresh() => loadHome();
}
