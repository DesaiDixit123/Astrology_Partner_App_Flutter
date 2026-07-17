import 'package:animate_do/animate_do.dart';
import 'package:astrology_partner/core/theme/app_colors.dart';
import 'package:astrology_partner/core/theme/app_text_styles.dart';
import 'package:astrology_partner/shared/widgets/premium_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../dashboard/presentation/controllers/dashboard_controller.dart';
import '../../../../config/routes/app_routes.dart';
import '../controllers/home_controller.dart';
import '../../../profile/presentation/widgets/boost_dialog.dart';

class HomePage extends GetView<HomeController> {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final dashboardController = Get.find<DashboardController>();
    // navbar pill (70.h) + gap above pill (12.h) + system gesture bar + extra breathing room
    final navbarHeight = 70.h + 12.h + MediaQuery.of(context).padding.bottom + 16.h;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('home'.tr),
        actions: [
          Obx(() => _buildOnlineToggle(dashboardController)),
          SizedBox(width: 16.w),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: controller.loadDashboard,
        color: AppColors.primary,
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(20.w, 10.h, 20.w, navbarHeight),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              FadeInDown(child: _buildAvailabilitySection(dashboardController)),
              SizedBox(height: 24.h),
              FadeInUp(
                delay: const Duration(milliseconds: 100),
                child: _buildSubscriptionStatsCard(dashboardController),
              ),
              SizedBox(height: 24.h),
              FadeInUp(
                delay: const Duration(milliseconds: 200),
                child: _buildStatsSection(),
              ),
              SizedBox(height: 24.h),
              FadeInUp(
                delay: const Duration(milliseconds: 400),
                child: _buildQuickActions(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOnlineToggle(DashboardController dashboardController) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 8.h),
      padding: EdgeInsets.symmetric(horizontal: 12.w),
      decoration: BoxDecoration(
        color: dashboardController.isOnline.value
            ? AppColors.online.withValues(alpha: 0.1)
            : AppColors.offline.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(
          color: dashboardController.isOnline.value
              ? AppColors.online.withValues(alpha: 0.2)
              : AppColors.offline.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8.w,
            height: 8.w,
            decoration: BoxDecoration(
              color: dashboardController.isOnline.value
                  ? AppColors.online
                  : AppColors.offline,
              shape: BoxShape.circle,
              boxShadow: [
                if (dashboardController.isOnline.value)
                  BoxShadow(
                    color: AppColors.online.withValues(alpha: 0.5),
                    blurRadius: 4,
                    spreadRadius: 2,
                  ),
              ],
            ),
          ),
          SizedBox(width: 8.w),
          Text(
            dashboardController.isOnline.value ? 'online'.tr : 'offline'.tr,
            style: AppTextStyles.bodySmall.copyWith(
              color: dashboardController.isOnline.value
                  ? AppColors.online
                  : AppColors.offline,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(width: 4.w),
          Switch(
            value: dashboardController.isOnline.value,
            onChanged: (val) => dashboardController.toggleOnlineStatus(val),
            activeThumbColor: AppColors.online,
            //scale: 0.8,
          ),
        ],
      ),
    );
  }

  Widget _buildAvailabilitySection(DashboardController dashboardController) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('availability_section'.tr, style: AppTextStyles.h4),
        SizedBox(height: 16.h),
        
       _buildToggleCard(
            'chat'.tr,
            Icons.chat_bubble_rounded,
            AppColors.primary,
            dashboardController.isChatAvailable,
            (v) => dashboardController.toggleChatAvailability(v),
          ),
        
        SizedBox(height: 12.h),
        _buildToggleCard(
          'call'.tr,
          Icons.call_rounded,
          Colors.orange,
          dashboardController.isCallAvailable,
          (v) => dashboardController.toggleCallAvailability(v),
        ),
        SizedBox(height: 12.h),
        _buildToggleCard(
          'video_call'.tr,
          Icons.videocam_rounded,
          Colors.purple,
          dashboardController.isVideoCallAvailable,
          (v) => dashboardController.toggleVideoCallAvailability(v),
          isFullWidth: true,
        ),
      ],
    );
  }

  Widget _buildToggleCard(
    String label,
    IconData icon,
    Color color,
    RxBool value,
    Function(bool) onChanged, {
    bool isFullWidth = false,
  }) {
    return Obx(
      () => PremiumCard(
        padding: EdgeInsets.all(16.w),
        onTap: () => onChanged(!value.value),
        gradientColors: value.value
            ? [color.withValues(alpha: 0.15), color.withValues(alpha: 0.05)]
            : null,
        border: Border.all(
          color: value.value ? color.withValues(alpha: 0.3) : AppColors.border,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(8.w),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Icon(icon, color: color, size: 20.sp),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Text(
                      label,
                      style: AppTextStyles.label,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ),
                ],
              ),
            ),
            Switch(
              value: value.value,
              onChanged: onChanged,
              activeThumbColor: color,
              //scale: 0.8,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsSection() {
    return Obx(
      () => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('insights'.tr, style: AppTextStyles.h4),
          SizedBox(height: 16.h),
          Row(
            children: [
              Expanded(
                child: _buildSimpleStatCard(
                  'today_earnings'.tr,
                  '₹${controller.stats['todayEarnings']}',
                  Icons.currency_rupee_rounded,
                  Colors.green,
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: _buildSimpleStatCard(
                  'rating'.tr,
                  '${controller.stats['rating']} ⭐',
                  Icons.star_rounded,
                  Colors.amber,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSimpleStatCard(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return PremiumCard(
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(8.w),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Icon(icon, color: color, size: 20.sp),
          ),
          SizedBox(height: 12.h),
          Text(label, style: AppTextStyles.bodySmall),
          SizedBox(height: 4.h),
          Text(value, style: AppTextStyles.h3.copyWith(color: color)),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('quick_actions'.tr, style: AppTextStyles.h4),
        SizedBox(height: 16.h),
        Row(
          children: [
            Expanded(
              child: _buildQuickActionCard(
                'go_live'.tr,
                Icons.video_call_rounded,
                Colors.redAccent,
                () => Get.toNamed(AppRoutes.goLive),
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: _buildQuickActionCard(
                'inbox'.tr,
                Icons.chat_rounded,
                AppColors.secondary,
                () => Get.toNamed(AppRoutes.chatInbox),
              ),
            ),
          ],
        ),
        SizedBox(height: 12.h),
        _buildQuickActionCard(
          'boost_profile'.tr,
          Icons.rocket_launch_rounded,
          Colors.blueAccent,
          () => Get.dialog(const BoostDialog()),
          isSmall: true,
        ),
      ],
    );
  }

  Widget _buildQuickActionCard(
    String label,
    IconData icon,
    Color color,
    VoidCallback onTap, {
    bool isSmall = false,
  }) {
    return PremiumCard(
      onTap: onTap,
      padding: EdgeInsets.all(isSmall ? 12.w : 20.w),
      gradientColors: [color, color.withValues(alpha: 0.8)],
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: Colors.white, size: 20.sp),
          SizedBox(width: 8.w),
          Flexible(
            child: Text(
              label,
              style: AppTextStyles.button.copyWith(color: Colors.white),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubscriptionStatsCard(DashboardController dashboardController) {
    return Obx(() {
      final activeSub = dashboardController.activeSubscriptionData;

      // Hide if no active subscription at all
      if (activeSub.isEmpty) return const SizedBox.shrink();

      // package_id can be a populated Map OR just a String ID from API
      final rawPkg = activeSub['package_id'];
      final bool isPkgPopulated = rawPkg is Map && rawPkg.isNotEmpty;

      // Resolve package name — try multiple possible fields
      String pkgName = '';
      Map pkg = {};
      if (isPkgPopulated) {
        pkg = rawPkg;
        pkgName = (pkg['name']?.toString() ?? pkg['package_name']?.toString() ?? '').trim();
      }

      // If we still have no name at all, hide the card
      if (pkgName.isEmpty) return const SizedBox.shrink();

      // Expiry date badge
      String expiryText = '';
      try {
        final expiry = activeSub['expiry_date'];
        if (expiry != null) {
          final dt = DateTime.tryParse(expiry.toString());
          if (dt != null) {
            final diff = dt.difference(DateTime.now()).inDays;
            expiryText = diff > 0 ? '$diff days left' : 'Expired';
          }
        }
      } catch (_) {}

      // Safely parse usage counts
      int parseInt(dynamic v) => v is int ? v : int.tryParse(v?.toString() ?? '0') ?? 0;

      final callsUsed = parseInt(activeSub['calls_used']);
      final chatUsed  = parseInt(activeSub['chat_used']);
      final videoUsed = parseInt(activeSub['video_used']);
      final callLimit = parseInt(pkg['call_limit']);
      final chatLimit = parseInt(pkg['chat_limit']);
      final videoLimit = parseInt(pkg['video_call_limit']);

      return PremiumCard(
        padding: EdgeInsets.all(16.w),
        // ── IMPORTANT: must provide gradient so white text is visible ──
        gradientColors: [AppColors.primary, AppColors.primaryDark],
        onTap: () => Get.toNamed(AppRoutes.subscription),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header ────────────────────────────────────────────
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Icons.stars_rounded, color: Colors.white, size: 20.sp),
                    SizedBox(width: 8.w),
                    Text(
                      pkgName,
                      style: AppTextStyles.h4.copyWith(color: Colors.white),
                    ),
                  ],
                ),
                Row(
                  children: [
                    if (expiryText.isNotEmpty)
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                        decoration: BoxDecoration(
                          color: expiryText == 'Expired'
                              ? Colors.redAccent.withValues(alpha: 0.3)
                              : Colors.white.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        child: Text(
                          expiryText,
                          style: AppTextStyles.bodySmall.copyWith(
                            color: expiryText == 'Expired' ? Colors.redAccent.shade100 : Colors.white,
                            fontSize: 11.sp,
                          ),
                        ),
                      ),
                    SizedBox(width: 6.w),
                    Icon(Icons.chevron_right_rounded, color: Colors.white54, size: 20.sp),
                  ],
                ),
              ],
            ),
            SizedBox(height: 14.h),
            // ── Usage progress bars ───────────────────────────────
            if (callLimit > 0 || chatLimit > 0 || videoLimit > 0)
              Row(
                children: [
                  _buildMiniProgress('Voice Call', callsUsed, callLimit),
                  _buildMiniProgress('Chat', chatUsed, chatLimit),
                  _buildMiniProgress('Video Call', videoUsed, videoLimit),
                ],
              ),
          ],
        ),
      );
    });
  }


  Widget _buildMiniProgress(String label, int used, int limit) {
    final String valText = limit == -1 ? '$used / ∞' : '$used / $limit';
    final double pct = limit == -1 ? 0.0 : (limit > 0 ? used / limit : 0.0);
    final displayPct = pct > 1.0 ? 1.0 : pct;

    return Expanded(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 4.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: AppTextStyles.bodySmall.copyWith(
                color: Colors.white60,
                fontWeight: FontWeight.bold,
                fontSize: 10.sp,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            SizedBox(height: 4.h),
            ClipRRect(
              borderRadius: BorderRadius.circular(10.r),
              child: LinearProgressIndicator(
                value: displayPct,
                backgroundColor: Colors.white10,
                color: pct >= 0.9 ? Colors.redAccent : AppColors.primaryLight,
                minHeight: 4.h,
              ),
            ),
            SizedBox(height: 4.h),
            Text(
              valText,
              style: AppTextStyles.bodySmall.copyWith(color: Colors.white70),
            ),
          ],
        ),
      ),
    );
  }
}
