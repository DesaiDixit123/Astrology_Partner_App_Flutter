import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../controllers/puja_controller.dart';

class PujaOrderDetailPage extends StatefulWidget {
  const PujaOrderDetailPage({super.key});

  @override
  State<PujaOrderDetailPage> createState() => _PujaOrderDetailPageState();
}

class _PujaOrderDetailPageState extends State<PujaOrderDetailPage> {
  final PujaController controller = Get.find<PujaController>();
  late Map order;
  final TextEditingController _broadcastLinkCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    order = Get.arguments as Map? ?? {};
    _broadcastLinkCtrl.text = order['broadcast_link']?.toString() ?? '';
  }

  @override
  void dispose() {
    _broadcastLinkCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (order.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Puja Detail')),
        body: const Center(child: Text('Order not found')),
      );
    }

    final customer = order['customer_id'] is Map ? order['customer_id'] : {};
    final customerName = customer['name'] as String? ?? 'User';
    final customerPhone = customer['phone'] as String? ?? 'Not Available';

    final puja = order['puja_id'] is Map ? order['puja_id'] : {};
    final pujaName = puja['name'] as String? ?? 'Puja';
    final pujaDesc = puja['description'] as String? ?? '';

    final package = order['package_id'] is Map ? order['package_id'] : {};
    final packageName = package['name'] as String? ?? 'Standard Package';
    final packageDesc = package['description'] as String? ?? '';

    final amount = order['amount'] ?? 0;
    final mode = (order['mode']?.toString() ?? 'offline').toUpperCase();
    final bookingDate = order['booking_date']?.toString() ?? '';
    final status = (order['status']?.toString() ?? 'pending').toUpperCase();
    final orderId = order['order_id']?.toString() ?? '';

    final shipping = order['shipping_details'] is Map ? order['shipping_details'] : {};
    final hasShipping = shipping.isNotEmpty;

    final isOnline = mode == 'ONLINE';
    final isActive = status == 'PENDING' || status == 'PLACED';

    return Scaffold(
      appBar: AppBar(
        title: Text('puja_order_details'.tr),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Order ID & Status Banner
            Container(
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.05),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('order_id'.tr, style: AppTextStyles.caption),
                      Text(orderId, style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.bold)),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text('status'.tr, style: AppTextStyles.caption),
                      Text(
                        status,
                        style: AppTextStyles.bodyMedium.copyWith(
                          fontWeight: FontWeight.bold,
                          color: status == 'COMPLETED'
                              ? AppColors.success
                              : (status == 'CANCELLED' || status == 'REFUNDED')
                                  ? AppColors.error
                                  : AppColors.warning,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(height: 20.h),

            // Puja & Package Info
            Text('puja_info'.tr, style: AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.bold)),
            SizedBox(height: 8.h),
            Card(
              margin: EdgeInsets.zero,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
              child: Padding(
                padding: EdgeInsets.all(16.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(pujaName, style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.bold)),
                    if (pujaDesc.isNotEmpty) ...[
                      SizedBox(height: 4.h),
                      Text(pujaDesc, style: AppTextStyles.bodySmall.copyWith(color: Colors.grey.shade600)),
                    ],
                    const Divider(),
                    Text('selected_package'.trParams({'package': packageName}), style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w600)),
                    if (packageDesc.isNotEmpty) ...[
                      SizedBox(height: 4.h),
                      Text(packageDesc, style: AppTextStyles.bodySmall.copyWith(color: Colors.grey.shade600)),
                    ],
                    SizedBox(height: 12.h),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('total_amount_paid'.tr, style: AppTextStyles.bodyMedium),
                        Text(
                          '₹$amount',
                          style: AppTextStyles.bodyLarge.copyWith(color: AppColors.primary, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 20.h),

            // Customer Details
            Text('customer_details'.tr, style: AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.bold)),
            SizedBox(height: 8.h),
            Card(
              margin: EdgeInsets.zero,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
              child: Padding(
                padding: EdgeInsets.all(16.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _infoRow(Icons.person_outline, 'full_name'.tr, customerName),
                    _infoRow(Icons.phone_android_outlined, 'phone_number'.tr, customerPhone),
                    _infoRow(Icons.mode_of_travel_outlined, 'Puja Mode', mode),
                    _infoRow(Icons.calendar_month_outlined, 'dob'.tr, bookingDate),
                  ],
                ),
              ),
            ),
            SizedBox(height: 20.h),

            // Shipping Details (if offline)
            if (hasShipping) ...[
              Text('shipping_address_prasad'.tr, style: AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.bold)),
              SizedBox(height: 8.h),
              Card(
                margin: EdgeInsets.zero,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                child: Padding(
                  padding: EdgeInsets.all(16.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(shipping['name'] ?? '', style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.bold)),
                      SizedBox(height: 4.h),
                      Text('${'phone_number'.tr}: ${shipping['phone'] ?? ''}', style: AppTextStyles.bodySmall),
                      SizedBox(height: 4.h),
                      Text(
                        '${shipping['flat_no'] ?? ''}, ${shipping['locality'] ?? ''}, ${shipping['landmark'] ?? ''}, ${shipping['city'] ?? ''}, ${shipping['state'] ?? ''} - ${shipping['pincode'] ?? ''}',
                        style: AppTextStyles.bodySmall.copyWith(color: Colors.grey.shade700),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 20.h),
            ],

            // Broadcast Link (For Online Pujas)
            if (isOnline) ...[
              Text('live_broadcast_link'.tr, style: AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.bold)),
              SizedBox(height: 8.h),
              Card(
                margin: EdgeInsets.zero,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                child: Padding(
                  padding: EdgeInsets.all(16.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Add video stream URL (e.g. YouTube Live, Zoom, etc.) for the customer to watch the live puja.',
                        style: AppTextStyles.caption,
                      ),
                      SizedBox(height: 12.h),
                      TextField(
                        controller: _broadcastLinkCtrl,
                        decoration: const InputDecoration(
                          hintText: 'Enter live stream link',
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        ),
                        enabled: isActive,
                      ),
                      if (isActive) ...[
                        SizedBox(height: 12.h),
                        Obx(() => SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: controller.isSubmitting.value
                                ? null
                                : () async {
                                    final success = await controller.updateBroadcastLink(
                                      order['_id'] ?? order['id'] ?? '',
                                      _broadcastLinkCtrl.text,
                                    );
                                    if (success) {
                                      // Update local copy
                                      order['broadcast_link'] = _broadcastLinkCtrl.text;
                                    }
                                  },
                            child: controller.isSubmitting.value
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                                  )
                                : Text('save_link'.tr),
                          ),
                        )),
                      ],
                    ],
                  ),
                ),
              ),
              SizedBox(height: 24.h),
            ],

            // Action Buttons
            if (isActive) ...[
              Obx(() => SizedBox(
                width: double.infinity,
                height: 48.h,
                child: ElevatedButton(
                  onPressed: controller.isSubmitting.value
                      ? null
                      : () async {
                          final confirm = await Get.dialog<bool>(
                            AlertDialog(
                              title: Text('complete_puja'.tr),
                              content: Text('complete_puja_confirm'.tr),
                              actions: [
                                TextButton(onPressed: () => Get.back(result: false), child: Text('cancel'.tr)),
                                ElevatedButton(onPressed: () => Get.back(result: true), child: Text('submit'.tr)),
                              ],
                            ),
                          );
                          if (confirm == true) {
                            final success = await controller.updatePujaStatus(
                              order['_id'] ?? order['id'] ?? '',
                              'completed',
                            );
                            if (success) {
                              Get.back(); // Return to list page
                            }
                          }
                        },
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.success),
                  child: controller.isSubmitting.value
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Text('mark_as_completed'.tr),
                ),
              )),
              SizedBox(height: 12.h),
            ],
          ],
        ),
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.h),
      child: Row(
        children: [
          Icon(icon, size: 20.sp, color: AppColors.primary),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: AppTextStyles.caption),
                Text(value, style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w500)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
