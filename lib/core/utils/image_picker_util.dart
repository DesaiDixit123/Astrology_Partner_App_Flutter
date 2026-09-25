import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

class ImagePickerUtil {
  /// Displays a modal bottom sheet with 2 styled cards: Take Photo & Gallery
  static Future<ImageSource?> showImageSourceBottomSheet({BuildContext? context}) async {
    final ctx = context ?? Get.context;

    Widget buildSheetContent(BuildContext sheetCtx) {
      return Container(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.15),
              blurRadius: 20,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40.w,
                  height: 4.h,
                  decoration: BoxDecoration(
                    color: AppColors.border,
                    borderRadius: BorderRadius.circular(2.r),
                  ),
                ),
              ),
              SizedBox(height: 16.h),
              Text(
                'Select Image Source',
                style: AppTextStyles.h4.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              SizedBox(height: 4.h),
              Text(
                'Choose how you would like to pick your photo',
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              SizedBox(height: 20.h),
              Row(
                children: [
                  Expanded(
                    child: _buildOptionCard(
                      icon: Icons.camera_alt_rounded,
                      title: 'Take Photo',
                      subtitle: 'Use Camera',
                      onTap: () {
                        if (Navigator.canPop(sheetCtx)) {
                          Navigator.pop(sheetCtx, ImageSource.camera);
                        } else {
                          Get.back(result: ImageSource.camera);
                        }
                      },
                    ),
                  ),
                  SizedBox(width: 16.w),
                  Expanded(
                    child: _buildOptionCard(
                      icon: Icons.photo_library_rounded,
                      title: 'From Gallery',
                      subtitle: 'Choose File',
                      onTap: () {
                        if (Navigator.canPop(sheetCtx)) {
                          Navigator.pop(sheetCtx, ImageSource.gallery);
                        } else {
                          Get.back(result: ImageSource.gallery);
                        }
                      },
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16.h),
            ],
          ),
        ),
      );
    }

    if (ctx != null) {
      return await showModalBottomSheet<ImageSource>(
        context: ctx,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (bCtx) => buildSheetContent(bCtx),
      );
    }

    return await Get.bottomSheet<ImageSource>(
      buildSheetContent(Get.context!),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }

  static Widget _buildOptionCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
            color: AppColors.primary.withValues(alpha: 0.3),
            width: 1.5,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: EdgeInsets.all(14.w),
              decoration: BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Icon(
                icon,
                color: Colors.white,
                size: 28.sp,
              ),
            ),
            SizedBox(height: 12.h),
            Text(
              title,
              style: AppTextStyles.label.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 4.h),
            Text(
              subtitle,
              style: AppTextStyles.caption.copyWith(
                fontSize: 11.sp,
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  /// Utility to show bottom sheet and pick image
  static Future<File?> pickImage() async {
    final source = await showImageSourceBottomSheet();
    if (source == null) return null;

    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: source,
      maxWidth: 1200,
      maxHeight: 1200,
      imageQuality: 70,
    );
    if (pickedFile != null) {
      return File(pickedFile.path);
    }
    return null;
  }
}
