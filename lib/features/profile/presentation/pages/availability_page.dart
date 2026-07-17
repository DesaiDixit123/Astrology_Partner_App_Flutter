import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

class AvailabilityPage extends StatefulWidget {
  const AvailabilityPage({super.key});

  @override
  State<AvailabilityPage> createState() => _AvailabilityPageState();
}

class _AvailabilityPageState extends State<AvailabilityPage> {
  bool isOnline = true;
  bool chatEnabled = true;
  bool callEnabled = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('my_availability'.tr),
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
            Container(
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16.r),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.shadow,
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('current_status'.tr, style: AppTextStyles.h4),
                      SizedBox(height: 4.h),
                      Text(
                        isOnline
                            ? 'online_msg'.tr
                            : 'offline_msg'.tr,
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: isOnline ? Colors.green : Colors.red,
                        ),
                      ),
                    ],
                  ),
                  Switch(
                    value: isOnline,
                    activeColor: Colors.green,
                    onChanged: (val) {
                      setState(() {
                        isOnline = val;
                      });
                    },
                  ),
                ],
              ),
            ),
            SizedBox(height: 24.h),
            Text('services_offered'.tr, style: AppTextStyles.h4),
            SizedBox(height: 12.h),
            _buildServiceToggle(
              'chat_consultation'.tr,
              Icons.chat_bubble_outline,
              chatEnabled,
              (val) {
                setState(() => chatEnabled = val);
              },
            ),
            SizedBox(height: 12.h),
            _buildServiceToggle(
              'voice_call'.tr,
              Icons.phone_outlined,
              callEnabled,
              (val) {
                setState(() => callEnabled = val);
              },
            ),
            SizedBox(height: 32.h),
            Text('working_hours'.tr, style: AppTextStyles.h4),
            SizedBox(height: 12.h),
            _buildTimeSlot('Monday - Friday', '09:00 AM - 06:00 PM'),
            _buildTimeSlot('Saturday - Sunday', '10:00 AM - 04:00 PM'),
            SizedBox(height: 24.h),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () {},
                style: OutlinedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 16.h),
                ),
                child: Text('edit_schedule'.tr, style: AppTextStyles.buttonSmall),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildServiceToggle(
    String name,
    IconData icon,
    bool value,
    Function(bool) onChanged,
  ) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primary),
          SizedBox(width: 16.w),
          Expanded(child: Text(name, style: AppTextStyles.bodyMedium)),
          Switch(
            value: value,
            activeColor: AppColors.primary,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }

  Widget _buildTimeSlot(String days, String time) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(days, style: AppTextStyles.bodyMedium),
          Text(
            time,
            style: AppTextStyles.bodyMedium.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
