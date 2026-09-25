import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../config/routes/app_routes.dart';
import '../../../../core/utils/image_picker_util.dart';
import '../controllers/live_controller.dart';

class GoLivePrepPage extends StatefulWidget {
  const GoLivePrepPage({super.key});

  @override
  State<GoLivePrepPage> createState() => _GoLivePrepPageState();
}

class _GoLivePrepPageState extends State<GoLivePrepPage> {
  final _titleController = TextEditingController();
  final _topicController = TextEditingController();
  File? _thumbnailFile;

  LiveController get _liveController => Get.find<LiveController>();

  @override
  void dispose() {
    _titleController.dispose();
    _topicController.dispose();
    super.dispose();
  }

  Future<void> _startLive() async {
    final title = _titleController.text.trim();
    String thumbnailUrl = '';

    if (_thumbnailFile != null) {
      final uploadedUrl = await _liveController.uploadThumbnail(_thumbnailFile!);
      if (uploadedUrl != null) {
        thumbnailUrl = uploadedUrl;
      } else {
        return; // Stop if upload failed
      }
    }

    await _liveController.startLive(title: title, thumbnail: thumbnailUrl);
    if (_liveController.isLive.value) {
      // Navigate to the broadcast screen; show 3-2-1 countdown there.
      Get.offNamed(
        AppRoutes.live,
        arguments: {
          ..._liveController.activeStream,
          'title': title,
          'topic': _topicController.text.trim(),
          'startCountdown': true,
        },
      );
    }
  }

  Future<void> _pickThumbnail() async {
    final file = await ImagePickerUtil.pickImage();
    if (file != null) {
      setState(() {
        _thumbnailFile = file;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('go_live'.tr),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Get.back(),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: GestureDetector(
                onTap: _pickThumbnail,
                child: Container(
                  width: 160.w,
                  height: 100.w,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(color: AppColors.primary, width: 1),
                    image: _thumbnailFile != null
                        ? DecorationImage(
                            image: FileImage(_thumbnailFile!),
                            fit: BoxFit.cover,
                          )
                        : null,
                  ),
                  child: _thumbnailFile == null
                      ? Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.add_photo_alternate_outlined,
                              size: 32.sp,
                              color: AppColors.primary,
                            ),
                            SizedBox(height: 4.h),
                            Text(
                              'add_thumbnail'.tr,
                              style: AppTextStyles.caption.copyWith(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        )
                      : const SizedBox.shrink(),
                ),
              ),
            ),
            SizedBox(height: 16.h),
            if (_thumbnailFile != null)
              Center(
                child: TextButton.icon(
                  onPressed: _pickThumbnail,
                  icon: const Icon(Icons.edit, size: 16),
                  label: Text('change_thumbnail'.tr),
                ),
              ),
            SizedBox(height: 32.h),
            _buildTextField(
              label: 'live_session_title'.tr,
              hint: 'live_session_hint'.tr,
              controller: _titleController,
            ),
            SizedBox(height: 16.h),
            _buildTextField(
              label: 'topic_optional'.tr,
              hint: 'topic_hint'.tr,
              controller: _topicController,
            ),
            SizedBox(height: 32.h),
            Obx(() {
              final isLoading = _liveController.isLoading.value;
              return SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: isLoading ? null : _startLive,
                  icon: isLoading
                      ? SizedBox(
                          width: 18.sp,
                          height: 18.sp,
                          child: const CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : const Icon(Icons.video_call),
                  label: Text('start_live_session'.tr, style: AppTextStyles.button),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: EdgeInsets.symmetric(vertical: 16.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required String hint,
    required TextEditingController controller,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.bodyMedium),
        SizedBox(height: 8.h),
        TextField(
          controller: controller,
          style: AppTextStyles.bodyLarge,
          decoration: InputDecoration(
            hintText: hint,
            contentPadding: EdgeInsets.symmetric(
              horizontal: 16.w,
              vertical: 12.h,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide(color: AppColors.border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide(color: AppColors.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide(color: AppColors.primary),
            ),
          ),
        ),
      ],
    );
  }
}
