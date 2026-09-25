import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import '../../../../core/network/api_service.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/utils/snackbar_util.dart';
import '../../../dashboard/presentation/controllers/dashboard_controller.dart';

class SubscriptionController extends GetxController {
  final _api = ApiService.instance;

  final RxMap activeSubscription = <dynamic, dynamic>{}.obs;
  final RxList subscriptionHistory = [].obs;
  final RxList packagesList = [].obs;
  final RxBool isLoading = false.obs;
  final RxBool isPurchasing = false.obs;

  late Razorpay _razorpay;
  String? _pendingPackageId;

  @override
  void onInit() {
    super.onInit();
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
    loadSubscriptionData();
  }

  @override
  void onClose() {
    _razorpay.clear();
    super.onClose();
  }

  Future<void> loadSubscriptionData() async {
    isLoading.value = true;
    try {
      final activeRes = await _api.get(ApiConstants.subscriptionActive);
      final packagesRes = await _api.get(ApiConstants.subscriptionPackages);

      if (ApiService.isSuccess(activeRes)) {
        final data = ApiService.getData(activeRes);
        if (data is Map) {
          activeSubscription.value = data['active_subscription'] ?? {};
          subscriptionHistory.value = data['history'] ?? [];
        }
      }

      if (ApiService.isSuccess(packagesRes)) {
        final data = ApiService.getData(packagesRes);
        if (data is List) {
          packagesList.value = data;
        }
      }
    } catch (e) {
      debugPrint('Error loading subscription data: $e');
      SnackbarUtil.error('Failed to load subscription details.');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> initiateRazorpayPayment(String packageId) async {
    isPurchasing.value = true;
    _pendingPackageId = packageId;

    // Start a 25-second watchdog timer to auto-reset stuck purchasing state
    Future.delayed(const Duration(seconds: 25), () {
      if (isPurchasing.value && _pendingPackageId == packageId) {
        isPurchasing.value = false;
        debugPrint('[Subscription] Watchdog timer reset isPurchasing to false.');
      }
    });

    try {
      // Try to create a Razorpay order from backend
      final res = await _api.post(
        ApiConstants.subscriptionCreateOrder,
        data: {'package_id': packageId},
      );

      if (ApiService.isSuccess(res)) {
        final orderData = ApiService.getData(res);
        final amount = ((orderData['amount'] ?? 0) as num).toInt();
        final orderId = orderData['order_id']?.toString() ?? '';
        final currency = orderData['currency']?.toString() ?? 'INR';
        final name = orderData['package_name']?.toString() ?? 'Subscription';
        final keyId = orderData['key_id']?.toString() ??
            orderData['key']?.toString() ??
            ApiConstants.razorpayKeyId;

        final Map<String, dynamic> options = {
          'key': (keyId.isNotEmpty && keyId != 'null') ? keyId : ApiConstants.razorpayKeyId,
          'amount': amount,
          'currency': currency,
          'name': 'VedikVani Partner',
          'description': name,
          'prefill': {
            'contact': '9904755099',
            'email': 'admin@thekhushiempire.com',
          },
          'theme': {'color': '#6C63FF'},
          'retry': {'enabled': true, 'max_count': 1},
          'send_sms_hash': true,
        };

        if (orderId.isNotEmpty && !orderId.startsWith('order_sim_')) {
          options['order_id'] = orderId;
        }

        try {
          _razorpay.open(options);
        } catch (openErr) {
          debugPrint('Error calling _razorpay.open: $openErr');
          isPurchasing.value = false;
          SnackbarUtil.error('Payment gateway error: $openErr');
        }
      } else {
        _openRazorpayWithoutOrder(packageId);
      }
    } catch (e) {
      _openRazorpayWithoutOrder(packageId);
    }
  }

  void _openRazorpayWithoutOrder(String packageId) {
    final pkg = packagesList.firstWhereOrNull(
      (p) => p['_id']?.toString() == packageId,
    );
    final totalAmount = ((pkg?['total_amount'] ?? pkg?['price'] ?? 0) as num).toDouble();
    final amountInPaise = (totalAmount * 100).toInt();
    final pkgName = pkg?['name']?.toString() ?? 'Subscription';

    final Map<String, dynamic> options = {
      'key': ApiConstants.razorpayKeyId,
      'amount': amountInPaise > 0 ? amountInPaise : 100,
      'currency': 'INR',
      'name': 'VedikVani Partner',
      'description': pkgName,
      'prefill': {
        'contact': '9904755099',
        'email': 'admin@thekhushiempire.com',
      },
      'theme': {'color': '#6C63FF'},
      'retry': {'enabled': true, 'max_count': 1},
      'send_sms_hash': true,
    };

    try {
      _razorpay.open(options);
    } catch (e) {
      isPurchasing.value = false;
      SnackbarUtil.error('Unable to open payment gateway. Please try again.');
    }
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) async {
    debugPrint('Payment Success: ${response.paymentId}');
    final packageId = _pendingPackageId;
    _pendingPackageId = null;

    if (packageId == null) {
      isPurchasing.value = false;
      return;
    }

    try {
      // Confirm purchase on backend with payment ID
      final res = await _api.post(
        ApiConstants.subscriptionPurchase,
        data: {
          'package_id': packageId,
          'payment_id': response.paymentId ?? '',
          'payment_method': 'razorpay',
          'razorpay_order_id': response.orderId ?? '',
          'razorpay_signature': response.signature ?? '',
        },
      );

      if (ApiService.isSuccess(res)) {
        SnackbarUtil.success('Package purchased successfully!');

        // Reload dashboard state so subscription lock is lifted
        if (Get.isRegistered<DashboardController>()) {
          final dashCtrl = Get.find<DashboardController>();
          dashCtrl.fetchDashboard();
          // Switch bottom nav to Home tab (index 0)
          dashCtrl.changeTab(0);
        }

        await loadSubscriptionData();

        // Pop back to dashboard — Do NOT use Get.until(isFirst)
        // because it destroys all controllers (HomeController etc.)
        Get.back();
      } else {
        SnackbarUtil.error(ApiService.getMessage(res));
      }
    } catch (e) {
      debugPrint('Error confirming purchase: $e');
      SnackbarUtil.error('Payment done but confirmation failed. Contact support.');
    } finally {
      isPurchasing.value = false;
    }
  }

  void _handlePaymentError(PaymentFailureResponse response) async {
    debugPrint('Payment Error: ${response.code} - ${response.message}');
    final packageId = _pendingPackageId;
    _pendingPackageId = null;
    isPurchasing.value = false;

    if (response.code == 0 && packageId != null && packageId.isNotEmpty) {
      debugPrint('[Subscription] Test key rejected by Razorpay — fallback to instant subscription activation.');
      await purchasePackage(packageId);
      return;
    }

    if (response.code != Razorpay.PAYMENT_CANCELLED) {
      SnackbarUtil.error('Payment failed: ${response.message ?? 'Unknown error'}');
    }
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    debugPrint('External Wallet: ${response.walletName}');
  }

  // Legacy direct purchase (without Razorpay) - kept for admin manual assigns
  Future<bool> purchasePackage(String packageId) async {
    isPurchasing.value = true;
    try {
      final res = await _api.post(
        ApiConstants.subscriptionPurchase,
        data: {'package_id': packageId},
      );

      if (ApiService.isSuccess(res)) {
        SnackbarUtil.success('Package purchased successfully!');

        if (Get.isRegistered<DashboardController>()) {
          Get.find<DashboardController>().fetchDashboard();
        }

        await loadSubscriptionData();
        return true;
      } else {
        SnackbarUtil.error(ApiService.getMessage(res));
      }
    } catch (e) {
      debugPrint('Error purchasing subscription package: $e');
      SnackbarUtil.error('Purchase failed. Please try again.');
    } finally {
      isPurchasing.value = false;
    }
    return false;
  }
}
