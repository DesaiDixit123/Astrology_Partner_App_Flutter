import 'package:animate_do/animate_do.dart';
import 'package:astrology_partner/config/routes/app_routes.dart';
import 'package:astrology_partner/core/theme/app_colors.dart';
import 'package:astrology_partner/core/theme/app_text_styles.dart';
import 'package:astrology_partner/shared/widgets/premium_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../controllers/profile_controller.dart';
import 'followers_list_page.dart';

class ProfilePage extends GetView<ProfileController> {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final navbarHeight = 70.h + 12.h + MediaQuery.of(context).padding.bottom + 16.h;
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        return CustomScrollView(
          slivers: [
            _buildSliverAppBar(),
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, navbarHeight),
                child: Column(
                  children: [
                    FadeInUp(child: _buildStatsSection()),
                    SizedBox(height: 24.h),
                    FadeInUp(
                      delay: const Duration(milliseconds: 200),
                      child: _buildMenuSection(),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildSliverAppBar() {
    final name = controller.userData['name'] ?? 'partner'.tr;
    final specialization =
        controller.userData['specialization'] ??
        ((controller.userData['skills'] as List?)?.isNotEmpty == true
            ? (controller.userData['skills'] as List).first.toString()
            : 'astrologer'.tr);

    return SliverAppBar(
      expandedHeight: 280.h,
      pinned: true,
      backgroundColor: AppColors.deepCosmic,
      elevation: 0,
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          alignment: Alignment.center,
          children: [
            Container(
              decoration: const BoxDecoration(
                gradient: AppColors.cosmicGradient,
              ),
            ),
            Positioned(
              top: 60.h,
              child: Column(
                children: [
                  Hero(
                    tag: 'profile_pic',
                    child: Container(
                      padding: EdgeInsets.all(4.w),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.2),
                          width: 2,
                        ),
                      ),
                      child: CircleAvatar(
                        radius: 50.r,
                        backgroundColor: Colors.white,
                        backgroundImage: controller.profileImageUrl.isNotEmpty
                            ? NetworkImage(controller.profileImageUrl)
                            : null,
                        child: controller.profileImageUrl.isEmpty
                            ? Icon(
                                Icons.person,
                                size: 50.sp,
                                color: AppColors.primary,
                              )
                            : null,
                      ),
                    ),
                  ),
                  SizedBox(height: 12.h),
                  Text(
                    name,
                    style: AppTextStyles.h2.copyWith(color: Colors.white),
                  ),
                  Text(
                    specialization,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: Colors.white70,
                    ),
                  ),
                  SizedBox(height: 12.h),
                ],
              ),
            ),
          ],
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.settings_outlined, color: Colors.white),
          onPressed: () => Get.toNamed(AppRoutes.settings),
        ),
      ],
    );
  }

  Widget _buildStatsSection() {
    return Row(
      children: [
        Expanded(
          child: _buildSimpleStatCard(
            'rating'.tr,
            '${controller.userData['rating'] ?? 0.0} ⭐',
            Icons.star_rounded,
            Colors.amber,
          ),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: _buildSimpleStatCard(
            'clients'.tr,
            '${controller.userData['totalConsultations'] ?? 0}',
            Icons.people_rounded,
            Colors.blue,
          ),
        ),
      ],
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
        children: [
          Icon(icon, color: color, size: 24.sp),
          SizedBox(height: 8.h),
          Text(value, style: AppTextStyles.h3),
          Text(label, style: AppTextStyles.caption),
        ],
      ),
    );
  }

  Widget _buildMenuSection() {
    return Column(
      children: [
        _buildMenuItem(
          Icons.edit_note_rounded,
          'edit_profile',
          () => Get.toNamed(AppRoutes.editProfile),
        ),
        _buildMenuItem(
          Icons.favorite_rounded,
          'My Followers',
          () => Get.to(() => const FollowersListPage()),
        ),
        _buildMenuItem(
          Icons.reviews_rounded,
          'user_reviews',
          () => Get.toNamed(AppRoutes.reviews),
        ),
        _buildMenuItem(
          Icons.stars_rounded,
          'My Subscription',
          () => Get.toNamed(AppRoutes.subscription),
        ),
        _buildMenuItem(
          Icons.brightness_7_rounded,
          'Puja Orders',
          () => Get.toNamed(AppRoutes.pujaOrders),
        ),
        _buildMenuItem(
          Icons.logout_rounded,
          'logout',
          controller.logout,
          isDestructive: true,
        ),
      ],
    );
  }

  Widget _buildMenuItem(
    IconData icon,
    String title,
    VoidCallback onTap, {
    bool isDestructive = false,
  }) {
    return PremiumCard(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      onTap: onTap,
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(10.w),
            decoration: BoxDecoration(
              color: isDestructive
                  ? Colors.red.withValues(alpha: 0.1)
                  : AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Icon(
              icon,
              color: isDestructive ? Colors.red : AppColors.primary,
              size: 22.sp,
            ),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Text(
              title.tr,
              style: AppTextStyles.bodyLarge.copyWith(
                fontWeight: FontWeight.w600,
                color: isDestructive ? Colors.red : AppColors.textPrimary,
              ),
            ),
          ),
          Icon(
            Icons.chevron_right_rounded,
            color: AppColors.textHint,
            size: 20.sp,
          ),
        ],
      ),
    );
  }
}
