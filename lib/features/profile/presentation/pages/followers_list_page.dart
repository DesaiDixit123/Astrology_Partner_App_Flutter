import 'package:astrology_partner/core/constants/api_constants.dart';
import 'package:astrology_partner/core/theme/app_colors.dart';
import 'package:astrology_partner/core/theme/app_text_styles.dart';
import 'package:astrology_partner/features/profile/presentation/controllers/profile_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class FollowersListPage extends GetView<ProfileController> {
  const FollowersListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'My Followers',
          style: AppTextStyles.h3.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        elevation: 0,
        backgroundColor: AppColors.deepCosmic,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Get.back(),
        ),
      ),
      body: Obx(() {
        if (controller.isLoadingFollowers.value && controller.followersList.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        final followers = controller.followersList;
        final int parsedCount = int.tryParse(controller.userData['followers_count']?.toString() ?? '') ??
            int.tryParse(controller.userData['followers']?.toString() ?? '') ??
            0;
        final int displayCount = followers.isNotEmpty ? followers.length : parsedCount;

        return RefreshIndicator(
          onRefresh: () => controller.fetchFollowers(),
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(
                child: Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(vertical: 24.h, horizontal: 20.w),
                  decoration: const BoxDecoration(
                    gradient: AppColors.cosmicGradient,
                  ),
                  child: Column(
                    children: [
                      Icon(
                        Icons.favorite_rounded,
                        color: Colors.white,
                        size: 38.sp,
                      ),
                      SizedBox(height: 8.h),
                      Text(
                        '$displayCount',
                        style: AppTextStyles.h1.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Total Followers',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: Colors.white.withValues(alpha: 0.85),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              if (followers.isEmpty)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.people_outline_rounded,
                          size: 64.sp,
                          color: AppColors.textSecondary.withValues(alpha: 0.4),
                        ),
                        SizedBox(height: 16.h),
                        Text(
                          'No Followers Yet',
                          style: AppTextStyles.h3.copyWith(color: AppColors.textPrimary),
                        ),
                        SizedBox(height: 6.h),
                        Text(
                          'Users who follow you will appear here.',
                          style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  ),
                )
              else
                SliverPadding(
                  padding: EdgeInsets.all(16.w),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final item = followers[index];
                        final customer = item['customer'] is Map ? item['customer'] : {};
                        final name = customer['name'] ?? 'User';
                        final profilePic = customer['profile_pic'] as String? ?? '';
                        final fullPicUrl = ApiConstants.resolveImage(profilePic);

                        return Container(
                          margin: EdgeInsets.only(bottom: 12.h),
                          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16.r),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.04),
                                blurRadius: 10,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              CircleAvatar(
                                radius: 24.r,
                                backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                                backgroundImage: fullPicUrl.isNotEmpty
                                    ? NetworkImage(fullPicUrl)
                                    : null,
                                child: fullPicUrl.isEmpty
                                    ? Icon(
                                        Icons.person,
                                        color: AppColors.primary,
                                        size: 24.sp,
                                      )
                                    : null,
                              ),
                              SizedBox(width: 14.w),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      name,
                                      style: AppTextStyles.bodyLarge.copyWith(
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.textPrimary,
                                      ),
                                    ),
                                    SizedBox(height: 4.h),
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.favorite_rounded,
                                          size: 14.sp,
                                          color: AppColors.primary,
                                        ),
                                        SizedBox(width: 4.w),
                                        Text(
                                          'Following you',
                                          style: AppTextStyles.caption.copyWith(
                                            color: AppColors.primary,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                      childCount: followers.length,
                    ),
                  ),
                ),
            ],
          ),
        );
      }),
    );
  }
}
