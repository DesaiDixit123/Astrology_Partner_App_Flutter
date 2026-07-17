import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../controllers/blog_controller.dart';

class CreateBlogPage extends StatefulWidget {
  const CreateBlogPage({super.key});

  @override
  State<CreateBlogPage> createState() => _CreateBlogPageState();
}

class _CreateBlogPageState extends State<CreateBlogPage> {
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  final controller = Get.find<BlogController>();

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('create_blog'.tr),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Thumbnail Selection
            GestureDetector(
              onTap: () => _showImageSourceOptions(),
              child: Obx(() => Container(
                height: 200.h,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: AppColors.surfaceVariant,
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(color: AppColors.border),
                  image: controller.thumbnail.value != null
                      ? DecorationImage(
                          image: FileImage(controller.thumbnail.value!),
                          fit: BoxFit.cover,
                        )
                      : null,
                ),
                child: controller.thumbnail.value == null
                    ? Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.add_photo_alternate_outlined, size: 40.sp, color: AppColors.textHint),
                          SizedBox(height: 8.h),
                          Text('add_thumbnail'.tr, style: AppTextStyles.caption),
                        ],
                      )
                    : null,
              )),
            ),
            SizedBox(height: 24.h),

            // Title Input
            Text('blog_title'.tr, style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.bold)),
            SizedBox(height: 8.h),
            TextField(
              controller: _titleController,
              decoration: InputDecoration(
                hintText: 'enter_title'.tr,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.r)),
              ),
            ),
            SizedBox(height: 20.h),

            // Content Input
            Text('blog_content'.tr, style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.bold)),
            SizedBox(height: 8.h),
            TextField(
              controller: _contentController,
              maxLines: 15,
              decoration: InputDecoration(
                hintText: 'share_wisdom'.tr,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.r)),
              ),
            ),
            SizedBox(height: 32.h),

            // Submit Button
            SizedBox(
              width: double.infinity,
              height: 50.h,
              child: Obx(() => ElevatedButton(
                onPressed: controller.isSubmitting.value
                    ? null
                    : () => controller.createBlog(_titleController.text, _contentController.text),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
                ),
                child: controller.isSubmitting.value
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Text(
                        'submit_review'.tr,
                        style: AppTextStyles.button.copyWith(color: Colors.white),
                      ),
              )),
            ),
            SizedBox(height: 20.h),
          ],
        ),
      ),
    );
  }

  void _showImageSourceOptions() {
    Get.bottomSheet(
      Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(16.r)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('select_img_source'.tr, style: AppTextStyles.h4),
            SizedBox(height: 16.h),
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: Text('camera'.tr),
              onTap: () {
                Get.back();
                controller.pickThumbnail(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: Text('gallery'.tr),
              onTap: () {
                Get.back();
                controller.pickThumbnail(ImageSource.gallery);
              },
            ),
          ],
        ),
      ),
    );
  }
}
