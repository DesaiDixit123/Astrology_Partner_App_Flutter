import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../config/routes/app_routes.dart';
import '../controllers/live_controller.dart';

class LiveHomePage extends GetView<LiveController> {
  const LiveHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('live'.tr),
        actions: [
          IconButton(
            onPressed: () => controller.loadRequests(),
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        return RefreshIndicator(
          onRefresh: () async {
            await controller.loadRequests();
          },
          child: ListView(
            padding: EdgeInsets.all(16.w),
            children: [
              Obx(() {
                final isLive = controller.isLive.value;
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
                      Text(
                        isLive ? 'You are LIVE' : 'Go Live',
                        style: AppTextStyles.h4,
                      ),
                      SizedBox(height: 8.h),
                      Text(
                        isLive
                            ? 'Your stream is running. Open the live dashboard to manage mic/camera and chat.'
                            : 'Start a live session so users can watch and chat with you.',
                        style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
                      ),
                      SizedBox(height: 16.h),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            if (isLive) {
                              Get.toNamed(AppRoutes.live, arguments: {
                                ...controller.activeStream,
                                'startCountdown': false,
                              });
                            } else {
                              Get.toNamed(AppRoutes.goLive);
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: isLive ? Colors.black : AppColors.error,
                            padding: EdgeInsets.symmetric(vertical: 14.h),
                          ),
                          child: Text(isLive ? 'Open Live Dashboard' : 'Start Live'),
                        ),
                      ),
                    ],
                  ),
                );
              }),
              SizedBox(height: 20.h),
              Text('Requests', style: AppTextStyles.h4),
              SizedBox(height: 12.h),
              Obx(() {
                if (controller.liveRequests.isEmpty) {
                  return Padding(
                    padding: EdgeInsets.only(top: 12.h),
                    child: Text(
                      'No live requests yet.',
                      style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
                    ),
                  );
                }

                return Column(
                  children: [
                    for (final req in controller.liveRequests)
                      _RequestTile(
                        request: (req as Map).cast<String, dynamic>(),
                        onAccept: () => controller.acceptRequest(req['_id'].toString()),
                        onReject: () => controller.rejectRequest(req['_id'].toString()),
                      ),
                  ],
                );
              }),
              SizedBox(height: 80.h),
            ],
          ),
        );
      }),
    );
  }
}

class _RequestTile extends StatelessWidget {
  final Map<String, dynamic> request;
  final VoidCallback onAccept;
  final VoidCallback onReject;

  const _RequestTile({
    required this.request,
    required this.onAccept,
    required this.onReject,
  });

  @override
  Widget build(BuildContext context) {
    final customer = (request['customer_id'] as Map?)?.cast<String, dynamic>() ?? {};
    final type = request['type']?.toString() ?? 'call';

    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(12.w),
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
      child: Row(
        children: [
          CircleAvatar(
            radius: 18.r,
            backgroundColor: AppColors.primary.withValues(alpha: 0.12),
            child: Icon(Icons.person, color: AppColors.primary, size: 18.sp),
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  customer['name']?.toString() ?? 'Customer',
                  style: AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.w600),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 2.h),
                Text(
                  type == 'video_call' ? 'Video Call Request' : 'Call Request',
                  style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: onReject,
            icon: const Icon(Icons.close, color: Colors.red),
          ),
          IconButton(
            onPressed: onAccept,
            icon: const Icon(Icons.check, color: Colors.green),
          ),
        ],
      ),
    );
  }
}

