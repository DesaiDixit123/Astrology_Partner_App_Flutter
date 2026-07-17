import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('about_us'.tr),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Get.back(),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: 32.h),
            Container(
              width: 100.w,
              height: 100.w,
              decoration: BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Icon(Icons.star, color: Colors.white, size: 50.sp),
              ),
            ),
            SizedBox(height: 16.h),
            Text('app_name_full'.tr, style: AppTextStyles.h2),
            SizedBox(height: 8.h),
            Text(
              'version'.tr + ' 1.0.0',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            SizedBox(height: 32.h),
            Text(
              'mission_statement'.tr,
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyLarge.copyWith(height: 1.5),
            ),
            SizedBox(height: 48.h),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Icon(
                Icons.description_outlined,
                color: AppColors.primary,
              ),
              title: Text(
                'terms_conditions'.tr,
                style: AppTextStyles.bodyMedium,
              ),
              trailing: Icon(
                Icons.arrow_forward_ios,
                size: 16.sp,
                color: AppColors.textSecondary,
              ),
              onTap: () {},
            ),
            const Divider(),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Icon(
                Icons.privacy_tip_outlined,
                color: AppColors.primary,
              ),
              title: Text('privacy_policy'.tr, style: AppTextStyles.bodyMedium),
              trailing: Icon(
                Icons.arrow_forward_ios,
                size: 16.sp,
                color: AppColors.textSecondary,
              ),
              onTap: () {},
            ),
            const Divider(),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Icon(Icons.update, color: AppColors.primary),
              title: Text('check_updates'.tr, style: AppTextStyles.bodyMedium),
              trailing: Icon(
                Icons.arrow_forward_ios,
                size: 16.sp,
                color: AppColors.textSecondary,
              ),
              onTap: () {},
            ),
          ],
        ),
      ),
    );
  }
}
