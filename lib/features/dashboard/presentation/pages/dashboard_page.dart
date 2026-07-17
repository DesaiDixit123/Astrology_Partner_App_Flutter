import 'package:animate_do/animate_do.dart';
import 'package:astrology_partner/core/theme/app_colors.dart';
import 'package:astrology_partner/core/theme/app_text_styles.dart';
import 'package:astrology_partner/shared/widgets/premium_nav.dart';
import 'package:astrology_partner/shared/widgets/premium_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../home/presentation/pages/home_page.dart';
import '../../../earnings/presentation/pages/earnings_page.dart';
import '../../../profile/presentation/pages/profile_page.dart';
import '../../../chat/presentation/pages/chat_request_page.dart';
import '../controllers/dashboard_controller.dart';
import '../../../../config/routes/app_routes.dart';
import '../../../../core/constants/api_constants.dart';

class DashboardPage extends GetView<DashboardController> {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      const HomePage(),
      const ChatRequestPage(),
      const EarningsPage(),
      const ProfilePage(),
    ];

    return Scaffold(
      extendBody: true,
      backgroundColor: AppColors.background,
      body: Obx(() {
        final approveStatus = controller.approvalStatus;

        if (approveStatus == null) {
          return const Center(child: CircularProgressIndicator());
        }

        if (approveStatus != 'approved') {
          return _buildStatusScreen(approveStatus);
        }

        final currentIdx = controller.currentIndex.value;
        final hasSub = controller.hasActiveSubscription.value;

        if (!hasSub && currentIdx != 3) {
          return _buildSubscriptionLockScreen();
        }

        return pages[currentIdx];
      }),
      bottomNavigationBar: Obx(() {
        if (controller.approvalStatus != 'approved') return const SizedBox.shrink();
        
        final hasSub = controller.hasActiveSubscription.value;
        return PremiumBottomNav(
          currentIndex: controller.currentIndex.value,
          onTap: (index) {
            if (!hasSub && index != 3) {
              controller.showSubscriptionRequiredDialog();
              return;
            }
            controller.changeTab(index);
          },
          items: [
            PremiumNavItem(
              icon: Icons.dashboard_outlined,
              activeIcon: Icons.dashboard_rounded,
              label: 'home'.tr,
            ),
            PremiumNavItem(
              icon: Icons.pending_actions_rounded,
              activeIcon: Icons.pending_actions_rounded,
              label: 'requests'.tr,
            ),
            PremiumNavItem(
              icon: Icons.account_balance_wallet_outlined,
              activeIcon: Icons.account_balance_wallet_rounded,
              label: 'earnings'.tr,
            ),
            PremiumNavItem(
              icon: Icons.person_outline,
              activeIcon: Icons.person_rounded,
              label: 'profile'.tr,
            ),
          ],
        );
      }),
    );
  }

  Widget _buildStatusScreen(String status) {
    final isRejected = status == 'rejected';
    final personalDetails = controller.profile['personal_details'] ?? {};
    final name = personalDetails['name']?.toString() ?? 'Partner';
    final profilePic = personalDetails['profile_image']?.toString() ?? '';
    final resolvedImageUrl = ApiConstants.resolveImage(profilePic);

    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: const BoxDecoration(gradient: AppColors.cosmicGradient),
      child: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 20.h),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // ── Glowing Avatar Container ───────────────────────────
                FadeInDown(
                  duration: const Duration(milliseconds: 600),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Ambient Glow behind
                      Container(
                        width: 130.w,
                        height: 130.w,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: (isRejected ? Colors.redAccent : Colors.amberAccent).withValues(alpha: 0.25),
                              blurRadius: 30,
                              spreadRadius: 4,
                            ),
                          ],
                        ),
                      ),
                      // Outer Border Ring
                      Container(
                        width: 114.w,
                        height: 114.w,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: (isRejected ? Colors.redAccent : Colors.amberAccent).withValues(alpha: 0.3),
                            width: 2.5,
                          ),
                        ),
                      ),
                      // Core circular avatar container
                      Container(
                        width: 96.w,
                        height: 96.w,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withValues(alpha: 0.08),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.2),
                            width: 1.5,
                          ),
                        ),
                        child: ClipOval(
                          child: resolvedImageUrl.isNotEmpty
                              ? Image.network(
                                  resolvedImageUrl,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) => _buildDefaultAvatar(name),
                                )
                              : _buildDefaultAvatar(name),
                        ),
                      ),
                      // Corner icon badge
                      Positioned(
                        bottom: 4.h,
                        right: 4.w,
                        child: Container(
                          padding: EdgeInsets.all(6.w),
                          decoration: BoxDecoration(
                            color: isRejected ? Colors.redAccent : Colors.amber,
                            shape: BoxShape.circle,
                            boxShadow: const [
                              BoxShadow(
                                color: Colors.black26,
                                blurRadius: 4,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Icon(
                            isRejected ? Icons.close_rounded : Icons.hourglass_top_rounded,
                            size: 14.sp,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 28.h),

                // ── Partner Name & Status Badge ───────────────────────────
                FadeInUp(
                  duration: const Duration(milliseconds: 600),
                  child: Column(
                    children: [
                      Text(
                        name,
                        style: AppTextStyles.h3.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 10.h),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 5.h),
                        decoration: BoxDecoration(
                          color: (isRejected ? Colors.redAccent : Colors.amber).withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(20.r),
                          border: Border.all(
                            color: (isRejected ? Colors.redAccent : Colors.amber).withValues(alpha: 0.25),
                          ),
                        ),
                        child: Text(
                          isRejected ? 'ACCOUNT REJECTED' : 'UNDER REVIEW',
                          style: AppTextStyles.caption.copyWith(
                            color: isRejected ? Colors.redAccent : Colors.amber,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.2,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 24.h),

                // ── Informative Rejection/Review Card ───────────────────────────
                FadeInUp(
                  duration: const Duration(milliseconds: 700),
                  child: Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(18.w),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(20.r),
                      border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
                    ),
                    child: Column(
                      children: [
                        Text(
                          isRejected ? 'account_rejected'.tr : 'under_review'.tr,
                          style: AppTextStyles.bodyLarge.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 8.h),
                        Text(
                          isRejected
                              ? (controller.rejectionReason.isEmpty ? 'N/A' : controller.rejectionReason)
                              : 'under_review_message'.tr,
                          textAlign: TextAlign.center,
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: Colors.white70,
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 36.h),

                // ── Refresh Action Button ───────────────────────────
                FadeInUp(
                  duration: const Duration(milliseconds: 800),
                  child: Row(
                    children: [
                      Expanded(
                        child: PremiumCard(
                          onTap: controller.refreshDashboard,
                          borderRadius: 16,
                          gradientColors: [AppColors.primary, AppColors.primaryDark],
                          child: Container(
                            height: 50.h,
                            alignment: Alignment.center,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.refresh_rounded, color: Colors.white, size: 18.sp),
                                SizedBox(width: 8.w),
                                Text(
                                  'refresh_status'.tr,
                                  style: AppTextStyles.button.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDefaultAvatar(String name) {
    final initial = name.isNotEmpty ? name[0].toUpperCase() : 'P';
    return Container(
      color: AppColors.primary.withValues(alpha: 0.25),
      alignment: Alignment.center,
      child: Text(
        initial,
        style: AppTextStyles.h2.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildSubscriptionLockScreen() {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: const BoxDecoration(gradient: AppColors.cosmicGradient),
      child: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 28.w, vertical: 24.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(height: 16.h),

                // ── Glowing Lock Icon ───────────────────────────────
                FadeInDown(
                  duration: const Duration(milliseconds: 600),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Glow ring
                      Container(
                        width: 140.w,
                        height: 140.w,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: RadialGradient(
                            colors: [
                              AppColors.primary.withValues(alpha: 0.35),
                              Colors.transparent,
                            ],
                          ),
                        ),
                      ),
                      // Icon circle
                      Container(
                        padding: EdgeInsets.all(26.w),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.08),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppColors.primaryLight.withValues(alpha: 0.5),
                            width: 1.5.w,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withValues(alpha: 0.3),
                              blurRadius: 24,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: Icon(
                          Icons.workspace_premium_rounded,
                          size: 64.sp,
                          color: AppColors.primaryLight,
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 28.h),

                // ── Title ────────────────────────────────────────────
                FadeInUp(
                  delay: const Duration(milliseconds: 100),
                  child: Text(
                    'Activate Your Subscription',
                    textAlign: TextAlign.center,
                    style: AppTextStyles.h1.copyWith(
                      color: Colors.white,
                      height: 1.25,
                    ),
                  ),
                ),

                SizedBox(height: 12.h),

                FadeInUp(
                  delay: const Duration(milliseconds: 200),
                  child: Text(
                    'Subscribe to a package and start receiving calls, chats & earning money as a partner astrologer.',
                    textAlign: TextAlign.center,
                    style: AppTextStyles.bodyMedium
                        .copyWith(color: Colors.white60, height: 1.6),
                  ),
                ),

                SizedBox(height: 30.h),

                // ── Features Grid ─────────────────────────────────────
                FadeInUp(
                  delay: const Duration(milliseconds: 300),
                  child: Container(
                    padding: EdgeInsets.all(18.w),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(20.r),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.1),
                      ),
                    ),
                    child: Column(
                      children: [
                        Text(
                          'What you get with a subscription',
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.primaryLight,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 16.h),
                        Row(
                          children: [
                            Expanded(child: _buildFeatureChip(Icons.call_rounded, 'Voice Calls')),
                            SizedBox(width: 10.w),
                            Expanded(child: _buildFeatureChip(Icons.chat_bubble_rounded, 'Chat Sessions')),
                          ],
                        ),
                        SizedBox(height: 10.h),
                        Row(
                          children: [
                            Expanded(child: _buildFeatureChip(Icons.videocam_rounded, 'Video Calls')),
                            SizedBox(width: 10.w),
                            Expanded(child: _buildFeatureChip(Icons.account_balance_wallet_rounded, 'Earnings')),
                          ],
                        ),
                        SizedBox(height: 10.h),
                        Row(
                          children: [
                            Expanded(child: _buildFeatureChip(Icons.celebration_rounded, 'Puja Orders')),
                            SizedBox(width: 10.w),
                            Expanded(child: _buildFeatureChip(Icons.trending_up_rounded, 'Online Status')),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                SizedBox(height: 30.h),

                // ── CTA Button ────────────────────────────────────────
                FadeInUp(
                  delay: const Duration(milliseconds: 450),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () => Get.toNamed(AppRoutes.subscription),
                      icon: Icon(Icons.shopping_bag_rounded, size: 20.sp),
                      label: Text(
                        'View & Buy Packages',
                        style: AppTextStyles.button.copyWith(color: Colors.white),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(vertical: 18.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16.r),
                        ),
                        elevation: 8,
                        shadowColor: AppColors.primary.withValues(alpha: 0.5),
                      ),
                    ),
                  ),
                ),

                SizedBox(height: 14.h),

                FadeInUp(
                  delay: const Duration(milliseconds: 500),
                  child: TextButton.icon(
                    onPressed: () => controller.changeTab(3),
                    icon: Icon(Icons.person_outline,
                        size: 16.sp, color: Colors.white38),
                    label: Text(
                      'Go to Profile & Logout',
                      style: AppTextStyles.bodyMedium
                          .copyWith(color: Colors.white38),
                    ),
                  ),
                ),

                SizedBox(height: 24.h),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureChip(IconData icon, String label) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 8.w),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 15.sp, color: AppColors.primaryLight),
          SizedBox(width: 6.w),
          Flexible(
            child: Text(
              label,
              style: AppTextStyles.bodySmall.copyWith(color: Colors.white70),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
