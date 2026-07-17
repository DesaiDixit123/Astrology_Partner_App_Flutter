import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../controllers/subscription_controller.dart';
import 'package:url_launcher/url_launcher_string.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/utils/snackbar_util.dart';

class SubscriptionScreen extends GetView<SubscriptionController> {
  const SubscriptionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.deepCosmic,
      appBar: AppBar(
        title: Text(
          'Subscriptions',
          style: AppTextStyles.h3.copyWith(color: Colors.white),
        ),
        backgroundColor: AppColors.deepCosmic,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
          onPressed: () => Get.back(),
        ),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        final activeSub = controller.activeSubscription;
        final hasActive = activeSub.isNotEmpty;

        return RefreshIndicator(
          onRefresh: controller.loadSubscriptionData,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (hasActive) ...[
                    FadeInDown(child: _buildActiveSubscriptionCard(activeSub)),
                    SizedBox(height: 30.h),
                  ],
                  FadeInUp(
                    child: Text(
                      hasActive
                          ? 'Upgrade or Renew Subscription'
                          : 'Available Subscription Packages',
                      style: AppTextStyles.h2.copyWith(color: Colors.white),
                    ),
                  ),
                  SizedBox(height: 16.h),
                  _buildPackagesList(),
                  SizedBox(height: 30.h),
                  // ── Payment History ──────────────────────────────────
                  Obx(() {
                    if (controller.subscriptionHistory.isEmpty) {
                      return const SizedBox.shrink();
                    }
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Payment History',
                          style: AppTextStyles.h2.copyWith(color: Colors.white),
                        ),
                        SizedBox(height: 16.h),
                        ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: controller.subscriptionHistory.length,
                          separatorBuilder: (_, __) =>
                              SizedBox(height: 12.h),
                          itemBuilder: (context, idx) {
                            final item = controller.subscriptionHistory[idx];
                            return _buildHistoryCard(item);
                          },
                        ),
                        SizedBox(height: 30.h),
                      ],
                    );
                  }),
                ],
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildActiveSubscriptionCard(Map activeSub) {
    final pkg = activeSub['package_id'] ?? {};
    DateTime? expiry;
    try {
      expiry = DateTime.parse(activeSub['expiry_date']);
    } catch (_) {
      expiry = null;
    }
    final diff = expiry != null ? expiry.difference(DateTime.now()).inDays : 0;
    final remainingDays = diff > 0 ? diff : 0;

    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        gradient: AppColors.cosmicGradient,
        borderRadius: BorderRadius.circular(24.r),
        border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'ACTIVE PACKAGE',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.primaryLight,
                      letterSpacing: 1.5,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    pkg['name'] ?? 'N/A',
                    style: AppTextStyles.h1.copyWith(color: Colors.white),
                  ),
                ],
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 6.h),
                decoration: BoxDecoration(
                  color: remainingDays > 7
                      ? Colors.greenAccent.withValues(alpha: 0.15)
                      : Colors.redAccent.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(
                    color: remainingDays > 7
                        ? Colors.greenAccent.withValues(alpha: 0.4)
                        : Colors.redAccent.withValues(alpha: 0.4),
                  ),
                ),
                child: Text(
                  remainingDays > 0
                      ? '$remainingDays Days Remaining'
                      : 'Expired',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: remainingDays > 0 ? Colors.greenAccent : Colors.redAccent,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          if (expiry != null)
            Text(
              'Expires on: ${expiry.day}/${expiry.month}/${expiry.year}',
              style: AppTextStyles.bodyMedium.copyWith(color: Colors.white70),
            ),
          Divider(color: Colors.white.withValues(alpha: 0.15), height: 30.h),
          Text(
            'Remaining Limits & Usage',
            style: AppTextStyles.bodyLarge
                .copyWith(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 16.h),
          _buildUsageItem('Calls', activeSub['calls_used'] ?? 0,
              pkg['call_limit'] ?? 0),
          _buildUsageItem('Chats', activeSub['chat_used'] ?? 0,
              pkg['chat_limit'] ?? 0),
          _buildUsageItem('Video Calls', activeSub['video_used'] ?? 0,
              pkg['video_call_limit'] ?? 0),
          _buildUsageItem('Reports', activeSub['report_used'] ?? 0,
              pkg['report_limit'] ?? 0),
          _buildUsageItem('Pujas', activeSub['puja_used'] ?? 0,
              pkg['puja_limit'] ?? 0),
        ],
      ),
    );
  }

  Widget _buildUsageItem(String label, int used, int limit) {
    if (limit == -1) {
      return Padding(
        padding: EdgeInsets.only(bottom: 12.h),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label,
                style: AppTextStyles.bodyMedium
                    .copyWith(color: Colors.white70)),
            Text(
              'Used: $used (Unlimited)',
              style: AppTextStyles.bodyMedium
                  .copyWith(color: Colors.greenAccent, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      );
    }

    final percent = limit > 0 ? used / limit : 0.0;
    final displayPct = percent > 1.0 ? 1.0 : percent;

    return Padding(
      padding: EdgeInsets.only(bottom: 12.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label,
                  style: AppTextStyles.bodyMedium
                      .copyWith(color: Colors.white70)),
              Text(
                '$used / $limit used',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: percent >= 0.9 ? Colors.redAccent : Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          SizedBox(height: 6.h),
          ClipRRect(
            borderRadius: BorderRadius.circular(10.r),
            child: LinearProgressIndicator(
              value: displayPct,
              backgroundColor: Colors.white24,
              color: percent >= 0.9 ? Colors.redAccent : AppColors.primaryLight,
              minHeight: 6.h,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryCard(Map item) {
    final pkg = item['package_id'] ?? {};
    final pkgName = pkg['name']?.toString() ?? 'Package';
    final paymentId = item['payment_id']?.toString() ?? '';
    final paymentMethod = item['payment_method']?.toString() ?? 'N/A';
    final amount = item['amount_paid'] ?? item['amount'] ?? 0;
    final status = item['status']?.toString() ?? 'completed';

    DateTime? purchasedAt;
    try {
      purchasedAt = DateTime.parse(item['purchased_at'] ?? item['createdAt']);
    } catch (_) {}

    final isSuccess = status.toLowerCase() == 'completed' ||
        status.toLowerCase() == 'active' ||
        status.toLowerCase() == 'success';

    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: const Color(0xFF152238),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  pkgName,
                  style: AppTextStyles.bodyLarge
                      .copyWith(color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
              Container(
                padding:
                    EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: isSuccess
                      ? Colors.greenAccent.withValues(alpha: 0.12)
                      : Colors.redAccent.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Text(
                  isSuccess ? 'Success' : status.capitalizeFirst ?? status,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: isSuccess ? Colors.greenAccent : Colors.redAccent,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 10.h),
          Divider(color: Colors.white10, height: 1.h),
          SizedBox(height: 10.h),
          Row(
            children: [
              Expanded(
                child: _buildHistoryDetail(
                  Icons.currency_rupee_rounded,
                  'Amount Paid',
                  '₹$amount',
                  Colors.greenAccent,
                ),
              ),
              Expanded(
                child: _buildHistoryDetail(
                  Icons.payment_rounded,
                  'Method',
                  paymentMethod.toUpperCase(),
                  AppColors.primaryLight,
                ),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          if (paymentId.isNotEmpty)
            _buildHistoryDetail(
              Icons.receipt_long_rounded,
              'Payment ID',
              paymentId,
              Colors.white54,
            ),
          if (purchasedAt != null) ...[
            SizedBox(height: 4.h),
            _buildHistoryDetail(
              Icons.access_time_rounded,
              'Purchased On',
              '${purchasedAt.day}/${purchasedAt.month}/${purchasedAt.year}  ${purchasedAt.hour.toString().padLeft(2, '0')}:${purchasedAt.minute.toString().padLeft(2, '0')}',
              Colors.white38,
            ),
          ],
          
          // Download Invoice row
          SizedBox(height: 12.h),
          InkWell(
            onTap: () async {
              final invoiceUrl = '${ApiConstants.baseUrl}partner/subscription/invoice/${item['_id']}'.replaceAll('//partner', '/partner');
              try {
                final launched = await launchUrlString(
                  invoiceUrl,
                  mode: LaunchMode.externalApplication,
                );
                if (!launched) {
                  SnackbarUtil.error('Could not open invoice URL.');
                }
              } catch (e) {
                SnackbarUtil.error('Failed to open invoice link: $e');
              }
            },
            borderRadius: BorderRadius.circular(8.r),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
              decoration: BoxDecoration(
                color: Colors.greenAccent.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8.r),
                border: Border.all(color: Colors.greenAccent.withValues(alpha: 0.2)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.download_rounded, color: Colors.greenAccent, size: 14.sp),
                  SizedBox(width: 6.w),
                  Text(
                    'Download Invoice',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: Colors.greenAccent,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryDetail(
    IconData icon,
    String label,
    String value,
    Color valueColor,
  ) {
    return Padding(
      padding: EdgeInsets.only(bottom: 4.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 13.sp, color: Colors.white30),
          SizedBox(width: 6.w),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style:
                      AppTextStyles.bodySmall.copyWith(color: Colors.white30)),
              SizedBox(height: 2.h),
              Text(value,
                  style: AppTextStyles.bodySmall
                      .copyWith(color: valueColor, fontWeight: FontWeight.w600)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPackagesList() {
    final pkgs = controller.packagesList;
    if (pkgs.isEmpty) {
      return Container(
        padding: EdgeInsets.all(40.h),
        alignment: Alignment.center,
        child: Text(
          'No packages available at the moment.',
          style: AppTextStyles.bodyLarge.copyWith(color: Colors.white70),
        ),
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: pkgs.length,
      separatorBuilder: (_, __) => SizedBox(height: 20.h),
      itemBuilder: (context, idx) {
        final pkg = pkgs[idx];
        return _buildPackageItemCard(pkg);
      },
    );
  }

  Widget _buildPackageItemCard(Map pkg) {
    final isPopular = pkg['popular'] == true;

    Color cardAccent;
    try {
      final colorHex = pkg['color']?.toString() ?? '#6C63FF';
      cardAccent = Color(int.parse(colorHex.replaceAll('#', '0xff')));
    } catch (_) {
      cardAccent = AppColors.primary;
    }

    final validityDays = pkg['validity_days'];
    final validityText = validityDays != null ? '$validityDays Days' : 'N/A';

    final hasTax = pkg['tax_amount'] != null &&
        (pkg['tax_amount'] as num) > 0;

    return Stack(
      children: [
        Container(
          padding: EdgeInsets.all(20.w),
          decoration: BoxDecoration(
            color: const Color(0xFF152238),
            borderRadius: BorderRadius.circular(20.r),
            border: Border.all(
              color: isPopular
                  ? cardAccent.withValues(alpha: 0.7)
                  : Colors.white.withValues(alpha: 0.1),
              width: isPopular ? 2.w : 1.w,
            ),
            boxShadow: isPopular
                ? [
                    BoxShadow(
                      color: cardAccent.withValues(alpha: 0.2),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    )
                  ]
                : null,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Package name + price ──────────────────────────────
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      pkg['name'] ?? '',
                      style: AppTextStyles.h2.copyWith(color: Colors.white),
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                    decoration: BoxDecoration(
                      color: cardAccent.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(10.r),
                      border: Border.all(color: cardAccent.withValues(alpha: 0.4)),
                    ),
                    child: Text(
                      '₹${pkg['price']}',
                      style: AppTextStyles.h3.copyWith(
                        color: cardAccent,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 6.h),
              Row(
                children: [
                  Icon(Icons.calendar_today_rounded,
                      color: Colors.white54, size: 13.sp),
                  SizedBox(width: 5.w),
                  Text(
                    'Valid for $validityText',
                    style: AppTextStyles.bodyMedium
                        .copyWith(color: Colors.white60),
                  ),
                ],
              ),

              // ── Description ───────────────────────────────────────
              if (pkg['description'] != null &&
                  pkg['description'].toString().isNotEmpty) ...[
                SizedBox(height: 10.h),
                Text(
                  pkg['description'],
                  style: AppTextStyles.bodyMedium.copyWith(color: Colors.white54),
                ),
              ],

              Divider(color: Colors.white10, height: 28.h),

              // ── Feature limits ────────────────────────────────────
              _buildFeatureLimitRow(
                  Icons.call_rounded, 'Voice Calls', pkg['call_limit']),
              _buildFeatureLimitRow(
                  Icons.chat_bubble_outline_rounded, 'Chats', pkg['chat_limit']),
              _buildFeatureLimitRow(
                  Icons.videocam_rounded, 'Video Calls', pkg['video_call_limit']),
              _buildFeatureLimitRow(
                  Icons.description_rounded, 'Reports', pkg['report_limit']),
              _buildFeatureLimitRow(
                  Icons.celebration_rounded, 'Puja Orders', pkg['puja_limit']),

              // ── GST breakdown ─────────────────────────────────────
              if (hasTax) ...[
                SizedBox(height: 14.h),
                Container(
                  padding: EdgeInsets.all(14.w),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.04),
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(
                        color: Colors.white.withValues(alpha: 0.08)),
                  ),
                  child: Column(
                    children: [
                      _buildPriceRow(
                        'Base Price',
                        '₹${pkg['price']}',
                        Colors.white60,
                        Colors.white70,
                      ),
                      SizedBox(height: 6.h),
                      _buildPriceRow(
                        '${pkg['tax_details']?['gst_name'] ?? 'GST'}',
                        '(+) ₹${pkg['tax_amount']}',
                        AppColors.primaryLight,
                        AppColors.primaryLight,
                      ),
                      Divider(color: Colors.white10, height: 14.h),
                      _buildPriceRow(
                        'Total Amount',
                        '₹${pkg['total_amount']}',
                        Colors.white,
                        Colors.greenAccent,
                        bold: true,
                      ),
                    ],
                  ),
                ),
              ],

              SizedBox(height: 20.h),

              // ── Buy Now button ────────────────────────────────────
              Obx(() => SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: controller.isPurchasing.value
                          ? null
                          : () => _showPurchaseDialog(
                                pkg['_id']?.toString() ?? '',
                                pkg['name']?.toString() ?? '',
                                pkg['total_amount'] ?? pkg['price'],
                                cardAccent,
                              ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            controller.isPurchasing.value
                                ? Colors.grey.shade700
                                : cardAccent,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(vertical: 16.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14.r),
                        ),
                        elevation: 4,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (controller.isPurchasing.value)
                            SizedBox(
                              width: 18.w,
                              height: 18.h,
                              child: const CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          else
                            Icon(Icons.shopping_cart_rounded, size: 18.sp),
                          SizedBox(width: 8.w),
                          Text(
                            controller.isPurchasing.value
                                ? 'Processing...'
                                : 'Buy Now',
                            style: AppTextStyles.button
                                .copyWith(color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                  )),
            ],
          ),
        ),

        // ── Popular badge ─────────────────────────────────────────
        if (isPopular)
          Positioned(
            top: 14.h,
            right: 14.w,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [cardAccent, cardAccent.withValues(alpha: 0.7)],
                ),
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Text(
                'POPULAR',
                style: AppTextStyles.bodySmall.copyWith(
                    color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildFeatureLimitRow(IconData icon, String title, dynamic limit) {
    final limitVal = limit is int ? limit : int.tryParse(limit?.toString() ?? '0') ?? 0;
    return Padding(
      padding: EdgeInsets.only(bottom: 8.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(icon, color: Colors.white38, size: 15.sp),
              SizedBox(width: 8.w),
              Text(title,
                  style:
                      AppTextStyles.bodyMedium.copyWith(color: Colors.white70)),
            ],
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 2.h),
            decoration: BoxDecoration(
              color: limitVal == -1
                  ? Colors.greenAccent.withValues(alpha: 0.12)
                  : Colors.white.withValues(alpha: 0.07),
              borderRadius: BorderRadius.circular(6.r),
            ),
            child: Text(
              limitVal == -1 ? '∞ Unlimited' : '$limitVal',
              style: AppTextStyles.bodyMedium.copyWith(
                color: limitVal == -1 ? Colors.greenAccent : Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPriceRow(
    String label,
    String value,
    Color labelColor,
    Color valueColor, {
    bool bold = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: AppTextStyles.bodySmall.copyWith(
              color: labelColor,
              fontWeight: bold ? FontWeight.bold : FontWeight.normal,
            )),
        Text(value,
            style: AppTextStyles.bodySmall.copyWith(
              color: valueColor,
              fontWeight: bold ? FontWeight.bold : FontWeight.normal,
            )),
      ],
    );
  }

  void _showPurchaseDialog(
    String id,
    String name,
    dynamic totalPrice,
    Color accentColor,
  ) {
    controller.isPurchasing.value = false;
    final displayPrice = totalPrice != null ? '₹$totalPrice' : '';

    Get.dialog(
      Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: EdgeInsets.symmetric(horizontal: 24.w),
        child: Container(
          padding: EdgeInsets.all(28.w),
          decoration: BoxDecoration(
            color: AppColors.deepCosmic,
            borderRadius: BorderRadius.circular(24.r),
            border: Border.all(color: accentColor.withValues(alpha: 0.3)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.5),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: EdgeInsets.all(16.w),
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.shopping_cart_rounded,
                  color: accentColor,
                  size: 32.sp,
                ),
              ),
              SizedBox(height: 16.h),
              Text(
                'Confirm Purchase',
                style: AppTextStyles.h3.copyWith(color: Colors.white),
              ),
              SizedBox(height: 10.h),
              Text(
                'You are about to subscribe to',
                style:
                    AppTextStyles.bodyMedium.copyWith(color: Colors.white60),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 4.h),
              Text(
                '"$name"',
                style: AppTextStyles.bodyLarge.copyWith(
                  color: accentColor,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              if (displayPrice.isNotEmpty) ...[
                SizedBox(height: 8.h),
                Container(
                  padding:
                      EdgeInsets.symmetric(horizontal: 16.w, vertical: 6.h),
                  decoration: BoxDecoration(
                    color: Colors.greenAccent.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10.r),
                    border: Border.all(
                        color: Colors.greenAccent.withValues(alpha: 0.3)),
                  ),
                  child: Text(
                    displayPrice,
                    style: AppTextStyles.h3.copyWith(
                        color: Colors.greenAccent,
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ],
              SizedBox(height: 24.h),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        controller.isPurchasing.value = false;
                        Get.back();
                      },
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.white38),
                        padding: EdgeInsets.symmetric(vertical: 14.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                      ),
                      child: Text(
                        'Cancel',
                        style: AppTextStyles.button
                            .copyWith(color: Colors.white70),
                      ),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Get.back();
                        controller.initiateRazorpayPayment(id);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: accentColor,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(vertical: 14.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                      ),
                      child: Text(
                        'Confirm',
                        style:
                            AppTextStyles.button.copyWith(color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      barrierDismissible: false,
    );
  }
}
