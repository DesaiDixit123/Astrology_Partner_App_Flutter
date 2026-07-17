import 'package:animate_do/animate_do.dart';
import 'package:astrology_partner/config/routes/app_routes.dart';
import 'package:astrology_partner/core/theme/app_colors.dart';
import 'package:astrology_partner/core/theme/app_text_styles.dart';
import 'package:astrology_partner/shared/widgets/premium_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../controllers/earnings_controller.dart';

class EarningsPage extends GetView<EarningsController> {
  const EarningsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final navbarHeight = 70.h + 12.h + MediaQuery.of(context).padding.bottom + 16.h;
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('earnings'.tr),
        actions: [
          IconButton(
            icon: const Icon(Icons.history_rounded),
            onPressed: () => Get.toNamed(AppRoutes.transactions),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await controller.fetchDashboard();
          await controller.fetchTransactions();
        },
        color: AppColors.primary,
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(20.w, 10.h, 20.w, navbarHeight),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              FadeInDown(child: _buildTotalEarningsCard()),
              SizedBox(height: 24.h),
              FadeInUp(delay: const Duration(milliseconds: 200), child: _buildPeriodEarnings()),
              SizedBox(height: 24.h),
              FadeInUp(delay: const Duration(milliseconds: 400), child: _buildWithdrawButton()),
              SizedBox(height: 32.h),
              FadeInUp(delay: const Duration(milliseconds: 600), child: _buildRecentTransactions()),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTotalEarningsCard() {
    return Obx(() => PremiumCard(
      padding: EdgeInsets.all(24.w),
      gradientColors: [AppColors.primary, AppColors.primaryDark],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'total_balance'.tr,
                style: AppTextStyles.bodyMedium.copyWith(color: Colors.white70),
              ),
              Icon(Icons.account_balance_wallet_rounded, color: Colors.white30, size: 24.sp),
            ],
          ),
          SizedBox(height: 8.h),
          Text(
            '₹${controller.walletBalance.value.toStringAsFixed(2)}',
            style: AppTextStyles.h1.copyWith(color: Colors.white, fontSize: 32.sp),
          ),
          SizedBox(height: 20.h),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Text(
              'payout_msg'.tr,
              style: AppTextStyles.caption.copyWith(color: Colors.white, fontSize: 10.sp),
            ),
          ),
        ],
      ),
    ));
  }

  Widget _buildPeriodEarnings() {
    return Obx(() => Row(
      children: [
        Expanded(
          child: _buildPeriodCard(
            'today'.tr,
            (controller.dashboardData['todayEarnings'] ?? 0.0).toDouble(),
            Colors.green,
          ),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: _buildPeriodCard(
            'this_week'.tr,
            (controller.dashboardData['weekEarnings'] ?? 0.0).toDouble(),
            Colors.blue,
          ),
        ),
      ],
    ));
  }

  Widget _buildPeriodCard(String period, double amount, Color color) {
    return PremiumCard(
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(period, style: AppTextStyles.caption),
          SizedBox(height: 8.h),
          Text(
            '₹${amount.toStringAsFixed(0)}',
            style: AppTextStyles.h3.copyWith(color: color),
          ),
        ],
      ),
    );
  }

  Widget _buildWithdrawButton() {
    return PremiumCard(
      onTap: () => Get.toNamed(AppRoutes.withdrawal),
      padding: EdgeInsets.all(16.w),
      gradientColors: [AppColors.accent, Colors.orange.shade700],
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.account_balance_rounded, color: Colors.white, size: 20.sp),
          SizedBox(width: 12.w),
          Text(
            'withdraw_to_bank'.tr,
            style: AppTextStyles.button.copyWith(color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentTransactions() {
    return Obx(() {
      if (controller.isLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }
      if (controller.transactions.isEmpty) return const SizedBox.shrink();

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('tx_history'.tr, style: AppTextStyles.h4),
              TextButton(
                onPressed: () => Get.toNamed(AppRoutes.transactions),
                child: Text('view_all'.tr, style: AppTextStyles.buttonSmall.copyWith(color: AppColors.primary)),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          ...controller.transactions.take(5).map((tx) => _buildTransactionCard(tx as Map)),
        ],
      );
    });
  }

  Widget _buildTransactionCard(Map tx) {
    return PremiumCard(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(12.w),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(10.w),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Icon(Icons.currency_rupee_rounded, color: AppColors.primary, size: 20.sp),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  tx['description'] ?? 'earning'.tr,
                  style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.bold),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  tx['date'] ?? '',
                  style: AppTextStyles.caption,
                ),
              ],
            ),
          ),
          Text(
            '+₹${tx['amount']}',
            style: AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.bold, color: Colors.green),
          ),
        ],
      ),
    );
  }
}
