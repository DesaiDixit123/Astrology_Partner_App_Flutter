import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../../config/routes/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../controllers/blog_controller.dart';

class BlogListPage extends GetView<BlogController> {
  const BlogListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('my_blogs'.tr),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline),
            onPressed: () => Get.toNamed(AppRoutes.createBlog),
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value && controller.blogs.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.blogs.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.article_outlined, size: 80.sp, color: AppColors.textHint),
                SizedBox(height: 16.h),
                Text('no_blogs'.tr, style: AppTextStyles.h4),
                SizedBox(height: 8.h),
                ElevatedButton(
                  onPressed: () => Get.toNamed(AppRoutes.createBlog),
                  child: Text('write_first_blog'.tr),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: controller.fetchMyBlogs,
          child: ListView.builder(
            padding: EdgeInsets.all(16.w),
            itemCount: controller.blogs.length,
            itemBuilder: (context, index) {
              final blog = controller.blogs[index];
              return _buildBlogCard(blog);
            },
          ),
        );
      }),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Get.toNamed(AppRoutes.createBlog),
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildBlogCard(Map blog) {
    final status = blog['status'] ?? 'pending';
    final title = blog['title'] ?? 'No Title';
    final imageUrl = blog['image'] ?? '';
    
    Color statusColor;
    switch (status) {
      case 'approved':
        statusColor = AppColors.success;
        break;
      case 'rejected':
        statusColor = AppColors.error;
        break;
      default:
        statusColor = AppColors.warning;
    }

    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.vertical(top: Radius.circular(12.r)),
            child: imageUrl.isNotEmpty
                ? Image.network(
                    imageUrl.startsWith('http') ? imageUrl : 'https://hrms-khushi.s3.ap-south-1.amazonaws.com/$imageUrl',
                    height: 150.h,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      height: 150.h,
                      color: AppColors.surfaceVariant,
                      child: const Icon(Icons.image_not_supported),
                    ),
                  )
                : Container(
                    height: 150.h,
                    color: AppColors.surfaceVariant,
                    child: const Icon(Icons.image),
                  ),
          ),
          Padding(
            padding: EdgeInsets.all(12.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                      decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4.r),
                      ),
                      child: Text(
                        status.tr.toUpperCase(),
                        style: AppTextStyles.caption.copyWith(
                          color: statusColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline, color: AppColors.error),
                      onPressed: () => _showDeleteDialog(blog['_id']),
                    ),
                  ],
                ),
                SizedBox(height: 8.h),
                Text(
                  title,
                  style: AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.bold),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(String id) {
    Get.defaultDialog(
      title: 'delete_blog'.tr,
      middleText: 'delete_blog_confirm'.tr,
      textConfirm: 'delete'.tr,
      textCancel: 'cancel'.tr,
      confirmTextColor: Colors.white,
      onConfirm: () {
        controller.deleteBlog(id);
        Get.back();
      },
    );
  }
}
