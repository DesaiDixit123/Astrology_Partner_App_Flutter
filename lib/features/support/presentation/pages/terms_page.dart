import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

class TermsPage extends StatelessWidget {
  const TermsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.deepCosmic,
      appBar: AppBar(
        title: Text(
          'terms_conditions'.tr,
          style: AppTextStyles.h3.copyWith(color: Colors.white),
        ),
        backgroundColor: AppColors.deepCosmic,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
          onPressed: () => Get.back(),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(16.r),
                border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  Icon(Icons.gavel_rounded, color: AppColors.primaryLight, size: 28.sp),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Text(
                      'terms_conditions'.tr,
                      style: AppTextStyles.h4.copyWith(color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20.h),
            _buildSection(
              title: '1. Acceptance of Partner Terms',
              content:
                  'By registering as an astrologer partner on our platform, you agree to be bound by these Terms & Conditions. If you do not agree with any part of these terms, you must cease using the partner portal immediately.',
            ),
            _buildSection(
              title: '2. Professional Conduct & Ethics',
              content:
                  'Partners must maintain professional, respectful, and polite conduct during all user interactions. Asking for off-platform payments, personal contact details, or using abusive language is strictly prohibited and grounds for immediate termination.',
            ),
            _buildSection(
              title: '3. Consultations & Billing Rates',
              content:
                  'Voice calls, video calls, and chat consultations are billed on a per-minute basis. Partners must adhere to their set per-minute charges and deliver genuine astrological guidance.',
            ),
            _buildSection(
              title: '4. Earnings Settlement & Payouts',
              content:
                  'Partner earnings accrued from consultations, e-puja services, and reports are settled according to the platform payout schedule directly into your registered bank account after verification.',
            ),
            _buildSection(
              title: '5. Account Verification & Deactivation',
              content:
                  'The platform reserves the right to review partner profiles, request updated credentials, or suspend accounts found in violation of code of conduct or fraudulent activity.',
            ),
            _buildSection(
              title: '6. Modifications to Terms',
              content:
                  'We reserve the right to update these terms as platform policies evolve. Continued use of the partner app following modifications constitutes your acceptance of the updated terms.',
            ),
            SizedBox(height: 32.h),
          ],
        ),
      ),
    );
  }

  Widget _buildSection({required String title, required String content}) {
    return Padding(
      padding: EdgeInsets.only(bottom: 20.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.primaryLight,
              fontWeight: FontWeight.bold,
              fontSize: 15.sp,
            ),
          ),
          SizedBox(height: 6.h),
          Text(
            content,
            style: AppTextStyles.bodySmall.copyWith(
              color: Colors.white70,
              height: 1.5,
              fontSize: 13.sp,
            ),
          ),
        ],
      ),
    );
  }
}
