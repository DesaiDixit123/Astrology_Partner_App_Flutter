import 'package:animate_do/animate_do.dart';
import 'package:astrology_partner/core/theme/app_colors.dart';
import 'package:astrology_partner/core/theme/app_text_styles.dart';
import 'package:astrology_partner/shared/widgets/premium_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../../shared/widgets/custom_button.dart';
import '../controllers/auth_controller.dart';

class OtpPage extends GetView<AuthController> {
  const OtpPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(gradient: AppColors.cosmicGradient),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 24.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 12.h),
                IconButton(
                  padding: EdgeInsets.zero,
                  alignment: Alignment.centerLeft,
                  icon: const Icon(
                    Icons.arrow_back_ios_new_rounded,
                    color: Colors.white,
                  ),
                  onPressed: () => Get.back(),
                ),
                SizedBox(height: 24.h),

                FadeInDown(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'verification'.tr,
                        style: AppTextStyles.h1.copyWith(
                          color: Colors.white,
                          fontSize: 32.sp,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      SizedBox(height: 12.h),
                      Obx(
                        () => RichText(
                          text: TextSpan(
                            style: AppTextStyles.bodyLarge.copyWith(
                              color: Colors.white70,
                            ),
                            children: [
                              TextSpan(text: 'enter_code'.tr),
                              TextSpan(
                                text: ' ${controller.phoneNumber.value}',
                                style: AppTextStyles.bodyLarge.copyWith(
                                  color: AppColors.gold,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 40.h),

                // Demo OTP Indicator
                Obx(
                  () => controller.serverOtp.value.isNotEmpty
                      ? FadeIn(
                          child: Container(
                            margin: EdgeInsets.only(bottom: 32.h),
                            padding: EdgeInsets.all(16.w),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(16.r),
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.1),
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.info_outline_rounded,
                                  color: AppColors.gold,
                                  size: 20.sp,
                                ),
                                SizedBox(width: 12.w),
                                // Text(
                                //   '${'demo_otp'.tr}: ${controller.serverOtp.value}',
                                //   style: AppTextStyles.bodyMedium.copyWith(
                                //     color: AppColors.gold,
                                //     fontWeight: FontWeight.bold,
                                //   ),
                                // ),
                              ],
                            ),
                          ),
                        )
                      : const SizedBox.shrink(),
                ),

                FadeInUp(
                  delay: const Duration(milliseconds: 200),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: List.generate(6, (index) => _buildOTPBox(index)),
                  ),
                ),

                SizedBox(height: 48.h),

                FadeInUp(
                  delay: const Duration(milliseconds: 400),
                  child: Center(
                    child: Column(
                      children: [
                        Text(
                          "didnt_receive_code".tr,
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: Colors.white60,
                          ),
                        ),
                        TextButton(
                          onPressed: () =>
                              controller.sendOTP(navigateToOtp: false),
                          child: Text(
                            'resend_code'.tr,
                            style: AppTextStyles.buttonSmall.copyWith(
                              color: AppColors.gold,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 1,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                SizedBox(height: 48.h),

                FadeInUp(
                  delay: const Duration(milliseconds: 600),
                  child: Obx(
                    () => CustomButton(
                      text: 'verify_account'.tr,
                      onPressed: controller.verifyOTP,
                      isLoading: controller.isLoading.value,
                      gradient: AppColors.primaryGradient,
                    ),
                  ),
                ),
                SizedBox(height: 40.h),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOTPBox(int index) {
    return SizedBox(
      width: 48.w,
      height: 64.h,
      child: PremiumCard(
        padding: EdgeInsets.zero,
        borderRadius: 16,
        child: Center(
          child: TextField(
            controller: controller.otpControllers[index],
            focusNode: controller.otpFocusNodes[index],
            textAlign: TextAlign.center,
            keyboardType: TextInputType.number,
            maxLength: 1,
            showCursor: false,
            style: AppTextStyles.h2.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.w900,
            ),
            decoration: const InputDecoration(
              counterText: '',
              border: InputBorder.none,
              contentPadding: EdgeInsets.zero,
            ),
            onChanged: (value) {
              if (value.isNotEmpty) {
                if (index < 5) {
                  controller.otpFocusNodes[index + 1].requestFocus();
                } else {
                  controller.otpFocusNodes[index].unfocus();
                }
              }
              if (value.isEmpty && index > 0) {
                controller.otpFocusNodes[index - 1].requestFocus();
              }
            },
          ),
        ),
      ),
    );
  }
}
