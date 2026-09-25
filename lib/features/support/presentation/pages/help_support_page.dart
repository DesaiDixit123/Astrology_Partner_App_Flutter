import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

class HelpSupportPage extends StatelessWidget {
  const HelpSupportPage({super.key});

  static const String supportPhone = '9904755099';
  static const String supportEmail = 'admin@thekhushiempire.com';

  Future<void> _makePhoneCall() async {
    final Uri phoneUri = Uri(scheme: 'tel', path: supportPhone);
    try {
      if (await canLaunchUrl(phoneUri)) {
        await launchUrl(phoneUri);
      } else {
        _copyToClipboard(supportPhone, 'Phone number copied to clipboard');
      }
    } catch (_) {
      _copyToClipboard(supportPhone, 'Phone number copied to clipboard');
    }
  }

  Future<void> _sendEmail() async {
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: supportEmail,
      queryParameters: {'subject': 'Astrologer Partner Support Request'},
    );
    try {
      if (await canLaunchUrl(emailUri)) {
        await launchUrl(emailUri);
      } else {
        _copyToClipboard(supportEmail, 'Support email copied to clipboard');
      }
    } catch (_) {
      _copyToClipboard(supportEmail, 'Support email copied to clipboard');
    }
  }

  void _copyToClipboard(String text, String message) {
    Clipboard.setData(ClipboardData(text: text));
    Get.snackbar(
      'Copied',
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: AppColors.primary,
      colorText: Colors.white,
      duration: const Duration(seconds: 2),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
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
            Text('contact_us'.tr, style: AppTextStyles.h4.copyWith(fontWeight: FontWeight.bold)),
            SizedBox(height: 16.h),
            _buildContactCard(
              icon: Icons.phone_in_talk_rounded,
              title: 'call_support'.tr,
              subtitle: '+91 $supportPhone',
              actionText: 'call_now'.tr,
              color: const Color(0xFF2E7D32),
              onTap: _makePhoneCall,
            ),
            SizedBox(height: 12.h),
            _buildContactCard(
              icon: Icons.mark_email_read_rounded,
              title: 'email_support'.tr,
              subtitle: supportEmail,
              actionText: 'send_email'.tr,
              color: const Color(0xFFC62828),
              onTap: _sendEmail,
            ),
            SizedBox(height: 32.h),
            Text('faqs'.tr, style: AppTextStyles.h4.copyWith(fontWeight: FontWeight.bold)),
            SizedBox(height: 16.h),
            _buildFaqItem(
              'How do I go online for calls/chats?',
              'Toggle the "Online" switch on your Dashboard screen to start receiving instant call and chat requests.',
            ),
            _buildFaqItem(
              'How can I check my earnings and payouts?',
              'Go to Earnings / Wallet section on your profile tab to view daily history and request bank payouts.',
            ),
            _buildFaqItem(
              'How do I update my consultation charges?',
              'Contact admin via support phone (+91 9904755099) or email (admin@thekhushiempire.com) to request rate adjustments.',
            ),
            _buildFaqItem(
              'What should I do if a call gets disconnected?',
              'If technical issues occur, wait 1 minute. The session will automatically save elapsed time and update your earnings wallet.',
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
    required Color color,
    required VoidCallback onTap,
  }) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Icon(icon, color: color, size: 26.sp),
          ),
          SizedBox(width: 14.w),
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
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 13.sp,
                      color: const Color(0xFF1F110B),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 6.w),
          ElevatedButton(
            onPressed: onTap,
            style: ElevatedButton.styleFrom(
              backgroundColor: color,
              foregroundColor: Colors.white,
              elevation: 0,
              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.r),
              ),
            ),
            child: Text(
              actionText,
              style: TextStyle(fontSize: 11.sp, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFaqItem(String question, String answer) {
    return Container(
      margin: EdgeInsets.only(bottom: 10.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: AppColors.border),
      ),
      child: Theme(
        data: Theme.of(Get.context!).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 2.h),
          childrenPadding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 14.h),
          title: Text(
            question,
            style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w600, fontSize: 13.sp),
          ),
          children: [
            Text(
              answer,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
                height: 1.5,
                fontSize: 12.sp,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
