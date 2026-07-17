import 'package:astrology_partner/features/profile/presentation/controllers/profile_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

class ReviewsPage extends GetView<ProfileController> {
  const ReviewsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('my_reviews'.tr),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Get.back(),
        ),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        final summary = controller.reviewsSummary;
        final rating = summary['averageRating']?.toString() ?? '0.0';
        final totalReviews = summary['totalReviews']?.toString() ?? '0';
        final reviews = controller.reviews;

        return RefreshIndicator(
          onRefresh: () => controller.loadProfile(),
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.all(16.w),
                  child: Column(
                    children: [
                      Text(
                        rating,
                        style: TextStyle(
                          fontSize: 48.sp,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(
                          5,
                          (index) {
                            double starRating = double.tryParse(rating) ?? 0;
                            return Icon(
                              index < starRating.floor()
                                  ? Icons.star
                                  : (index < starRating ? Icons.star_half : Icons.star_border),
                              color: Colors.amber,
                              size: 24.sp,
                            );
                          },
                        ),
                      ),
                      SizedBox(height: 8.h),
                      Text(
                        '${'based_on'.tr} $totalReviews ${'reviews'.tr}',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                      SizedBox(height: 24.h),
                      const Divider(),
                    ],
                  ),
                ),
              ),
              if (reviews.isEmpty)
                SliverFillRemaining(
                  child: Center(
                    child: Text('no_reviews_yet'.tr, style: AppTextStyles.bodyMedium),
                  ),
                )
              else
                SliverPadding(
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate((context, index) {
                      final review = reviews[index];
                      final customer = review['customer_id'] as Map? ?? {};
                      final customerName = customer['name'] ?? 'User';
                      final rating = (review['rating'] ?? 0).toDouble();
                      final comment = review['comment'] ?? '';
                      final createdAt = review['createdAt'] != null 
                          ? DateTime.parse(review['createdAt']) 
                          : DateTime.now();
                      
                      return Padding(
                        padding: EdgeInsets.only(bottom: 16.h),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  customerName,
                                  style: AppTextStyles.bodyMedium.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Text(
                                  DateFormat.yMMMd().format(createdAt),
                                  style: AppTextStyles.caption,
                                ),
                              ],
                            ),
                            SizedBox(height: 4.h),
                            Row(
                              children: List.generate(5, (starIndex) {
                                return Icon(
                                  Icons.star,
                                  color: starIndex < rating
                                      ? Colors.amber
                                      : Colors.grey[300],
                                  size: 16.sp,
                                );
                              }),
                            ),
                            if (comment.isNotEmpty) ...[
                              SizedBox(height: 8.h),
                              Text(
                                comment,
                                style: AppTextStyles.bodyMedium,
                              ),
                            ],
                          ],
                        ),
                      );
                    }, childCount: reviews.length),
                  ),
                ),
            ],
          ),
        );
      }),
    );
  }
}
