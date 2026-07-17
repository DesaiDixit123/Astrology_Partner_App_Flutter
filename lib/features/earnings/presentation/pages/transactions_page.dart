import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

import 'package:astrology_partner/features/earnings/presentation/controllers/earnings_controller.dart';

class TransactionsPage extends StatelessWidget {
  const TransactionsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<EarningsController>();

    return Scaffold(
      appBar: AppBar(
        title: Text('tx_history'.tr),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Get.back(),
        ),
      ),
      body: Obx(() {
        if (controller.isLoading.value && controller.earnings.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.earnings.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.history, size: 64.w, color: AppColors.textHint),
                SizedBox(height: 16.h),
                Text('no_tx_found'.tr, style: AppTextStyles.bodyMedium),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () => controller.refresh(),
          child: ListView.separated(
            padding: EdgeInsets.all(16.w),
            itemCount: controller.earnings.length,
            separatorBuilder: (context, index) => const Divider(),
            itemBuilder: (context, index) {
              final tx = controller.earnings[index];
              final isCredit = tx['type'] == 'credit';
              final amount = tx['amount']?.toString() ?? '0';
              final title = tx['description'] ?? 'transaction'.tr;
              // Backend might already format the date, otherwise use createdAt
              final date = tx['date'] ?? tx['createdAt']?.toString() ?? '';

              return ListTile(
                contentPadding: EdgeInsets.zero,
                leading: CircleAvatar(
                  backgroundColor: isCredit
                      ? Colors.green.withValues(alpha: 0.1)
                      : Colors.red.withValues(alpha: 0.1),
                  child: Icon(
                    isCredit ? Icons.arrow_downward : Icons.arrow_upward,
                    color: isCredit ? Colors.green : Colors.red,
                  ),
                ),
                title: Text(
                  title,
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                subtitle: Text(date, style: AppTextStyles.caption),
                trailing: Text(
                  '${isCredit ? '+' : '-'}₹$amount',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: isCredit ? Colors.green : AppColors.textPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              );
            },
          ),
        );
      }),
    );
  }
}

