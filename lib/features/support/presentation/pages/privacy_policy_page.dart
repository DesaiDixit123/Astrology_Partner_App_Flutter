import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

class PrivacyPolicyPage extends StatelessWidget {
  const PrivacyPolicyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.deepCosmic,
      appBar: AppBar(
        title: Text(
          'privacy_policy'.tr,
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
                  Icon(Icons.shield_outlined, color: AppColors.primaryLight, size: 28.sp),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Text(
                      'privacy_policy'.tr,
                      style: AppTextStyles.h4.copyWith(color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20.h),
            _buildSection(
              title: '1. Information We Collect',
              content:
                  'We collect personal details essential for astrologer partner verification and service delivery, including your Full Name, Mobile Number, Email Address, Astrological Qualifications, Certificates, Bank Account Details, and Government Identification (PAN & Aadhaar).',
            ),
            _buildSection(
              title: '2. How We Use Your Information',
              content:
                  'Your professional credentials and consultation records are strictly used to verify your identity, calculate Gun/Kundli predictions, display your partner profile to users, and process weekly/monthly earnings directly into your bank account.',
            ),
            _buildSection(
              title: '3. Data Security & Confidentiality',
              content:
                  'We employ enterprise-grade SSL encryption, protected servers, and secure token authentication to safeguard your personal, financial, and consultation data. Private user-partner interactions are kept 100% confidential.',
            ),
            _buildSection(
              title: '4. Financial & Payout Security',
              content:
                  'Earnings payout calculations and transaction processing are handled through PCI-DSS compliant payment infrastructures. Full card details or net banking credentials are never stored on our servers.',
            ),
            _buildSection(
              title: '5. Account Rights & Deletion',
              content:
                  'You have the right to request access to your profile data or request account deactivation and data deletion at any time via the Settings menu or by contacting partner support.',
            ),
            _buildSection(
              title: '6. Support & Inquiries',
              content:
                  'If you have questions regarding this Privacy Policy or partner data practices, please reach out to our partner support team via the Help & Support section.',
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
