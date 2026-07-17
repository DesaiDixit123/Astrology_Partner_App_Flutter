import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

class DocumentsPage extends StatelessWidget {
  const DocumentsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('my_documents'.tr),
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
            Text('id_proof'.tr, style: AppTextStyles.h4),
            SizedBox(height: 12.h),
            _buildDocumentCard(
              title: 'aadhaar'.tr,
              status: 'verified'.tr,
              isVerified: true,
              icon: Icons.badge_outlined,
            ),
            SizedBox(height: 12.h),
            _buildDocumentCard(
              title: 'pan_card'.tr,
              status: 'verified'.tr,
              isVerified: true,
              icon: Icons.credit_card,
            ),
            SizedBox(height: 24.h),
            Text('astro_certs'.tr, style: AppTextStyles.h4),
            SizedBox(height: 12.h),
            _buildDocumentCard(
              title: 'Vedic Astrology Certificate',
              status: 'verified'.tr,
              isVerified: true,
              icon: Icons.workspace_premium_outlined,
            ),
            SizedBox(height: 12.h),
            _buildDocumentCard(
              title: 'Tarot Reading Certificate',
              status: 'pending_verification'.tr,
              isVerified: false,
              icon: Icons.workspace_premium_outlined,
            ),
            SizedBox(height: 24.h),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {
                  // Upload new doc
                },
                icon: const Icon(Icons.upload_file),
                label: Text('upload_new_doc'.tr),
                style: OutlinedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 16.h),
                  side: BorderSide(color: AppColors.primary),
                  foregroundColor: AppColors.primary,
                  textStyle: AppTextStyles.buttonSmall,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDocumentCard({
    required String title,
    required String status,
    required bool isVerified,
    required IconData icon,
  }) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
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
                Text(
                  status,
                  style: AppTextStyles.caption.copyWith(
                    color: isVerified ? Colors.green : Colors.orange,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: Icon(Icons.remove_red_eye, color: AppColors.textSecondary),
            onPressed: () {},
          ),
        ],
      ),
    );
  }
}
