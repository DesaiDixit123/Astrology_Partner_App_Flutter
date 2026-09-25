import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../config/routes/app_routes.dart';
import '../controllers/puja_controller.dart';

class PujaOrdersListPage extends GetView<PujaController> {
  const PujaOrdersListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text('puja_orders'.tr),
          bottom: TabBar(
            labelColor: AppColors.primary,
            unselectedLabelColor: AppColors.textSecondary,
            indicatorColor: AppColors.primary,
            tabs: [
              Tab(text: 'active_new'.tr),
              Tab(text: 'history'.tr),
            ],
          ),
        ),
        body: Obx(() {
          if (controller.isLoading.value) {
            return const Center(child: CircularProgressIndicator());
          }

          return TabBarView(
            children: [
              _buildList(controller.activePujaOrders, 'no_active_puja_orders'.tr),
              _buildList(controller.completedPujaOrders, 'no_past_puja_orders'.tr),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildList(RxList orders, String emptyMsg) {
    return Obx(() {
      if (orders.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.brightness_7_outlined, size: 64.sp, color: AppColors.textHint),
              SizedBox(height: 16.h),
              Text(emptyMsg, style: AppTextStyles.bodyMedium),
            ],
          ),
        );
      }

      return RefreshIndicator(
        onRefresh: controller.loadPujaOrders,
        child: ListView.builder(
          padding: EdgeInsets.all(16.w),
          itemCount: orders.length,
          itemBuilder: (context, index) {
            final order = Map.from(orders[index]);
            return _buildOrderCard(order);
          },
        ),
      );
    });
  }

  Widget _buildOrderCard(Map order) {
    final customer = order['customer_id'] is Map ? order['customer_id'] : {};
    final customerName = customer['name'] as String? ?? 'User';
    
    final puja = order['puja_id'] is Map ? order['puja_id'] : {};
    final pujaName = puja['name'] as String? ?? 'Puja';

    final package = order['package_id'] is Map ? order['package_id'] : {};
    final packageName = package['name'] as String? ?? 'Standard Package';

    final amount = order['amount'] ?? 0;
    final mode = (order['mode']?.toString() ?? 'offline').toUpperCase();
    final bookingDate = order['booking_date']?.toString() ?? '';
    final status = (order['status']?.toString() ?? 'pending').toUpperCase();

    final statusColor = status == 'COMPLETED'
        ? AppColors.success
        : (status == 'CANCELLED' || status == 'REFUNDED')
            ? AppColors.error
            : AppColors.warning;

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
      child: InkWell(
        onTap: () => Get.toNamed(AppRoutes.pujaOrderDetail, arguments: order),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    pujaName,
                    style: AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.bold),
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4.r),
                  ),
                  child: Text(
                    status,
                    style: AppTextStyles.caption.copyWith(color: statusColor, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            SizedBox(height: 6.h),
            Text(
              'Package: $packageName',
              style: AppTextStyles.bodyMedium.copyWith(color: Colors.grey.shade700),
            ),
            SizedBox(height: 8.h),
            const Divider(),
            SizedBox(height: 4.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Customer: $customerName', style: AppTextStyles.bodySmall),
                    SizedBox(height: 2.h),
                    Text('Date: $bookingDate', style: AppTextStyles.bodySmall),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '₹$amount',
                      style: AppTextStyles.bodyLarge.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      mode,
                      style: AppTextStyles.caption.copyWith(
                        color: mode == 'ONLINE' ? Colors.blue : Colors.brown,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
