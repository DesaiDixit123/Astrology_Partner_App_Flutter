import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../controllers/boost_controller.dart';

class BoostHistoryPage extends GetView<BoostController> {
  const BoostHistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Boost History'),
      ),
      body: Obx(() {
        if (controller.isLoading.value && controller.history.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.history.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.rocket_launch_outlined, size: 64.sp, color: Colors.grey),
                SizedBox(height: 16.h),
                Text('No boost history found', style: AppTextStyles.bodyLarge),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: controller.fetchHistory,
          child: ListView.separated(
            padding: EdgeInsets.all(16.w),
            itemCount: controller.history.length,
            separatorBuilder: (context, index) => SizedBox(height: 12.h),
            itemBuilder: (context, index) {
              final item = controller.history[index];
              return _buildHistoryCard(item);
            },
          ),
        );
      }),
    );
  }

  Widget _buildHistoryCard(Map<String, dynamic> item) {
    final startTime = DateTime.parse(item['startTime']);
    final endTime = DateTime.parse(item['endTime']);
    final status = item['status'] ?? 'completed';
    final price = item['boostPrice'] ?? 0;

    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: (status == 'active' ? Colors.green : Colors.blue).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(4.r),
                ),
                child: Text(
                  status.toUpperCase(),
                  style: AppTextStyles.caption.copyWith(
                    color: status == 'active' ? Colors.green : Colors.blue,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Text(
                '₹$price',
                style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Row(
            children: [
              Icon(Icons.calendar_today, size: 14.sp, color: Colors.grey),
              SizedBox(width: 8.w),
              Text(
                'Started: ${DateFormat('dd MMM yyyy, hh:mm a').format(startTime)}',
                style: AppTextStyles.bodySmall,
              ),
            ],
          ),
          SizedBox(height: 4.h),
          Row(
            children: [
              Icon(Icons.timer_outlined, size: 14.sp, color: Colors.grey),
              SizedBox(width: 8.w),
              Text(
                'Ends: ${DateFormat('dd MMM yyyy, hh:mm a').format(endTime)}',
                style: AppTextStyles.bodySmall,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
