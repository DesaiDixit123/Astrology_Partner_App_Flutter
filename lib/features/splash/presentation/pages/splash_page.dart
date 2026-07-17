import 'package:animate_do/animate_do.dart';
import 'package:astrology_partner/core/theme/app_colors.dart';
import 'package:astrology_partner/core/theme/app_text_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../controllers/splash_controller.dart';

class SplashPage extends GetView<SplashController> {
  const SplashPage({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(SplashController());

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: AppColors.cosmicGradient,
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Background cosmic patterns overlay
            Opacity(opacity: 0.15, child: _buildCosmicPattern()),

            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Animated Pulsing Logo
                Pulse(
                  duration: const Duration(milliseconds: 1500),
                  infinite: true,
                  child: Container(
                    width: 130.w,
                    height: 130.w,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppColors.gold.withValues(alpha: 0.3),
                        width: 2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.gold.withValues(alpha: 0.2),
                          blurRadius: 30,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    child: Center(
                      child: ClipOval(
                        child: Image.asset(
                          'assets/icon.png',
                          width: 120.w,
                          height: 120.w,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 48.h),

                // Animated App Name
                FadeInDown(
                  child: Text(
                    'VEDIKVANI PARTNER',
                    style: AppTextStyles.h1.copyWith(
                      color: Colors.white,
                      fontSize: 28.sp,
                      letterSpacing: 4,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                SizedBox(height: 16.h),

                // Animated Subtitle
                FadeInUp(
                  delay: const Duration(milliseconds: 400),
                  child: Text(
                    'Empowering Cosmic Professionals',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: Colors.white70,
                      letterSpacing: 2,
                    ),
                  ),
                ),
              ],
            ),

            // Bottom Loading Area
            Positioned(
              bottom: 100.h,
              child: FadeIn(
                delay: const Duration(seconds: 1),
                child: Column(
                  children: [
                    SizedBox(
                      width: 24.w,
                      height: 24.w,
                      child: const CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(
                          AppColors.gold,
                        ),
                        strokeWidth: 2,
                      ),
                    ),
                    SizedBox(height: 20.h),
                    Text(
                      'SECURE ACCESS',
                      style: AppTextStyles.caption.copyWith(
                        color: Colors.white38,
                        letterSpacing: 3,
                        fontSize: 10.sp,
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
    );
  }

  Widget _buildCosmicPattern() {
    return Stack(
      children: List.generate(20, (index) {
        final double top = (index * 47) % 800 + 0.0;
        final double left = (index * 31) % 400 + 0.0;

        return Positioned(
          top: top.h,
          left: left.w,
          child: Icon(
            index % 3 == 0 ? Icons.star_rounded : Icons.brightness_1_rounded,
            size: (index % 5 + 2).sp,
            color: Colors.white,
          ),
        );
      }),
    );
  }
}
