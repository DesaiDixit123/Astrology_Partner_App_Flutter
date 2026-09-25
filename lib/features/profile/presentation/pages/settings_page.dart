import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../../core/localization/app_language_controller.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../config/routes/app_routes.dart';
import '../controllers/profile_controller.dart';

class SettingsPage extends GetView<AppLanguageController> {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('settings'.tr),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Get.back(),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('app_settings'.tr, style: AppTextStyles.h4),
            SizedBox(height: 12.h),
            Obx(
              () => _buildSettingsItem(
                Icons.language,
                'language'.tr,
                value: controller.currentLanguageLabel,
                onTap: _showLanguageDialog,
              ),
            ),
            SizedBox(height: 24.h),
            Text('more'.tr, style: AppTextStyles.h4),
            SizedBox(height: 12.h),
            _buildSettingsItem(
              Icons.privacy_tip_outlined,
              'privacy_policy'.tr,
              onTap: () => Get.toNamed(AppRoutes.privacyPolicy),
            ),
            _buildSettingsItem(
              Icons.description_outlined,
              'terms_of_service'.tr,
              onTap: () => Get.toNamed(AppRoutes.terms),
            ),
            SizedBox(height: 32.h),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () {
                  Get.find<ProfileController>().logout();
                },
                style: OutlinedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 16.h),
                  foregroundColor: Colors.red,
                  side: const BorderSide(color: Colors.red),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                ),
                child: Text(
                  'log_out'.tr,
                  style: AppTextStyles.buttonSmall.copyWith(color: Colors.red),
                ),
              ),
            ),
            SizedBox(height: 16.h),
            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: () => _confirmDeleteAccount(),
                child: Text(
                  'delete_account'.tr,
                  style: AppTextStyles.buttonSmall.copyWith(color: Colors.red),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showLanguageDialog() {
    Get.dialog(
      AlertDialog(
        title: Text('select_language'.tr),
        content: Obx(
          () => Column(
            mainAxisSize: MainAxisSize.min,
            children: AppLanguageController.supportedLanguages.map((language) {
              final isSelected =
                  language.code == controller.currentLanguageCode;
              return ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(language.label),
                trailing: isSelected
                    ? Icon(Icons.check, color: AppColors.primary)
                    : null,
                onTap: () async {
                  await controller.changeLanguage(language.code);
                  Get.back();
                },
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  void _confirmDeleteAccount() {
    Get.dialog(
      AlertDialog(
        title: Text('delete_account_title'.tr),
        content: Text('delete_account_confirmation'.tr),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('cancel'.tr),
          ),
          TextButton(
            onPressed: () {
              Get.back();
              Get.find<ProfileController>().deleteAccount();
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: Text('delete'.tr),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsItem(
    IconData icon,
    String title, {
    String? value,
    required VoidCallback onTap,
  }) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Container(
        padding: EdgeInsets.all(10.w),
        decoration: BoxDecoration(
          color: AppColors.surface,
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: AppColors.primary, size: 24.sp),
      ),
      title: Text(title, style: AppTextStyles.bodyMedium),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (value != null) Text(value, style: AppTextStyles.caption),
          if (value != null) SizedBox(width: 8.w),
          Icon(
            Icons.arrow_forward_ios,
            size: 14.sp,
            color: AppColors.textSecondary,
          ),
        ],
      ),
      onTap: onTap,
    );
  }
}
