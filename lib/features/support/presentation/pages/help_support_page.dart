import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

class HelpSupportPage extends StatelessWidget {
  const HelpSupportPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('help_support'.tr),
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
            Text('contact_us'.tr, style: AppTextStyles.h4),
            SizedBox(height: 16.h),
            _buildContactCard(
              icon: Icons.headset_mic_outlined,
              title: 'call_support'.tr,
              subtitle: '1800-123-4567',
              actionText: 'call_now'.tr,
              onTap: () {},
            ),
            SizedBox(height: 12.h),
            _buildContactCard(
              icon: Icons.email_outlined,
              title: 'email_support'.tr,
              subtitle: 'partner.support@astrology.com',
              actionText: 'send_email'.tr,
              onTap: () {},
            ),
            SizedBox(height: 32.h),
            Text('faqs'.tr, style: AppTextStyles.h4),
            SizedBox(height: 16.h),
            _buildFaqItem(
              'faq_1_q'.tr,
              'faq_1_a'.tr,
            ),
            _buildFaqItem(
              'faq_2_q'.tr,
              'faq_2_a'.tr,
            ),
            _buildFaqItem(
              'faq_3_q'.tr,
              'faq_3_a'.tr,
            ),
            _buildFaqItem(
              'faq_4_q'.tr,
              'faq_4_a'.tr,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContactCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required String actionText,
    required VoidCallback onTap,
  }) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: AppColors.primary, size: 24.sp),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(subtitle, style: AppTextStyles.caption),
              ],
            ),
          ),
          SizedBox(
            height: 36.h,
            child: OutlinedButton(
              onPressed: onTap,
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: AppColors.primary),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20.r),
                ),
                padding: EdgeInsets.symmetric(horizontal: 16.w),
              ),
              child: Text(
                actionText,
                style: AppTextStyles.caption.copyWith(color: AppColors.primary),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFaqItem(String question, String answer) {
    return Theme(
      data: Theme.of(Get.context!).copyWith(dividerColor: Colors.transparent),
      child: ExpansionTile(
        tilePadding: EdgeInsets.zero,
        title: Text(
          question,
          style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w600),
        ),
        children: [
          Padding(
            padding: EdgeInsets.only(bottom: 16.h),
            child: Text(
              answer,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
