import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../controllers/boost_controller.dart';

class BoostDialog extends StatelessWidget {
  const BoostDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<BoostController>();

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
      child: Padding(
        padding: EdgeInsets.all(20.w),
        child: Obx(() {
          if (controller.isLoading.value) {
            return SizedBox(
              height: 200.h,
              child: const Center(child: CircularProgressIndicator()),
            );
          }

          return Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.auto_awesome, color: Colors.blue, size: 20.sp),
                  SizedBox(width: 8.w),
                  Text('Confirm Profile Boost', style: AppTextStyles.h4),
                ],
              ),
              SizedBox(height: 16.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildCommissionItem(Icons.chat_outlined, 'Chat Commission', '${controller.chatCommission}%'),
                  _buildCommissionItem(Icons.call_outlined, 'Call Commission', '${controller.callCommission}%'),
                ],
              ),
              SizedBox(height: 12.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildCommissionItem(Icons.videocam_outlined, 'Video Call Commission', '${controller.videoCommission}%'),
                  _buildCommissionItem(Icons.bolt, 'Remaining Boosts', '${controller.remainingBoosts}', isAccent: true),
                ],
              ),
              SizedBox(height: 20.h),
              Container(
                padding: EdgeInsets.all(12.w),
                decoration: BoxDecoration(
                  color: Colors.blue.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.star, color: Colors.blue, size: 16.sp),
                        SizedBox(width: 8.w),
                        Text('Profile Boost Benefits:', style: AppTextStyles.bodyMedium.copyWith(color: Colors.blue, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    SizedBox(height: 12.h),
                    ...controller.benefits.map((benefit) => Padding(
                      padding: EdgeInsets.only(bottom: 8.h),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            margin: EdgeInsets.only(top: 6.h),
                            width: 6.w,
                            height: 6.h,
                            decoration: const BoxDecoration(color: Colors.black54, shape: BoxShape.circle),
                          ),
                          SizedBox(width: 10.w),
                          Expanded(
                            child: Text(benefit, style: AppTextStyles.bodySmall.copyWith(color: Colors.black87, height: 1.4)),
                          ),
                        ],
                      ),
                    )),
                  ],
                ),
              ),
              SizedBox(height: 24.h),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Get.back(),
                      child: const Text('Cancel'),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Obx(() => ElevatedButton(
                      onPressed: controller.isApplying.value ? null : () async {
                        final success = await controller.applyBoost();
                        if (success) Get.back();
                      },
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                      child: controller.isApplying.value 
                        ? SizedBox(height: 20.h, width: 20.h, child: const CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                        : Text('Boost Now 🚀', style: TextStyle(fontSize: 14.sp)),
                    )),
                  ),
                ],
              ),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildCommissionItem(IconData icon, String label, String value, {bool isAccent = false}) {
    return Expanded(
      child: Row(
        children: [
          Icon(icon, size: 16.sp, color: isAccent ? Colors.orange : Colors.grey[700]),
          SizedBox(width: 8.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: AppTextStyles.caption.copyWith(color: Colors.grey[700], fontSize: 10.sp)),
                Text(value, style: AppTextStyles.bodySmall.copyWith(fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
