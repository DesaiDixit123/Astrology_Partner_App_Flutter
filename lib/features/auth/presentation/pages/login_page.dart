import 'package:animate_do/animate_do.dart';
import 'package:astrology_partner/core/theme/app_colors.dart';
import 'package:astrology_partner/core/theme/app_text_styles.dart';
import 'package:astrology_partner/shared/widgets/premium_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../../shared/widgets/custom_button.dart';
import '../../../../shared/widgets/custom_text_field.dart';
import '../controllers/auth_controller.dart';

class LoginPage extends GetView<AuthController> {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: AppColors.cosmicGradient,
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: EdgeInsets.symmetric(horizontal: 24.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 60.h),

                FadeInDown(
                  child: Center(
                    child: Container(
                      padding: EdgeInsets.all(20.w),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.2),
                        ),
                      ),
                      child: Icon(
                        Icons.auto_awesome,
                        size: 60.sp,
                        color: AppColors.gold,
                      ),
                    ),
                  ),
                ),

                SizedBox(height: 48.h),

                FadeInLeft(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'welcome_back'.tr,
                        style: AppTextStyles.h1.copyWith(
                          color: Colors.white,
                          fontSize: 32.sp,
                          height: 1.2,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      SizedBox(height: 12.h),
                      Text(
                        'login_subtitle'.tr,
                        style: AppTextStyles.bodyLarge.copyWith(
                          color: Colors.white70,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 48.h),

                FadeInUp(
                  duration: const Duration(milliseconds: 800),
                  child: PremiumCard(
                    padding: EdgeInsets.all(24.w),
                    borderRadius: 30,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'phone_number'.tr,
                          style: AppTextStyles.h4.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        SizedBox(height: 24.h),
                        CustomTextField(
                          controller: controller.phoneController,
                          hintText: 'enter_mobile'.tr,
                          prefixIcon: Icons.phone_android_rounded,
                          keyboardType: TextInputType.phone,
                        ),
                        SizedBox(height: 32.h),
                        Obx(
                          () => CustomButton(
                            text: 'send_otp'.tr,
                            onPressed: controller.sendOTP,
                            isLoading: controller.isLoading.value,
                            gradient: AppColors.primaryGradient,
                            borderRadius: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                SizedBox(height: 40.h),

                FadeIn(
                  delay: const Duration(seconds: 1),
                  child: Center(
                    child: TextButton(
                      onPressed: () {},
                      child: Text(
                        'need_assistance'.tr,
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: Colors.white70,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
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
}
