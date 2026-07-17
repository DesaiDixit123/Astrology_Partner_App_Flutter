import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../shared/widgets/premium_card.dart';
import '../../../profile/presentation/controllers/profile_controller.dart';
import '../controllers/earnings_controller.dart';
import '../../../../config/routes/app_routes.dart';

class WithdrawalPage extends StatefulWidget {
  const WithdrawalPage({super.key});

  @override
  State<WithdrawalPage> createState() => _WithdrawalPageState();
}

class _WithdrawalPageState extends State<WithdrawalPage> {
  final _amountController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final _earningsController = Get.find<EarningsController>();
  final _profileController = Get.find<ProfileController>();

  @override
  void initState() {
    super.initState();
    // Load fresh data
    _earningsController.loadAll();
    _profileController.loadProfile();
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  bool _checkHasBankDetails() {
    final bank = _profileController.profile['bank_details'] as Map? ?? {};
    final accNo = bank['account_no']?.toString() ?? '';
    final ifsc = bank['ifsc_code']?.toString() ?? '';
    return accNo.isNotEmpty && ifsc.isNotEmpty;
  }

  Future<void> _submitRequest() async {
    if (!_formKey.currentState!.validate()) return;
    
    final amt = double.tryParse(_amountController.text.trim()) ?? 0.0;
    final success = await _earningsController.requestWithdrawal(amt);
    if (success) {
      _amountController.clear();
      // Reload profile to reflect balance deduction
      await _profileController.loadProfile();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('withdraw_funds'.tr),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Get.back(),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await _earningsController.loadAll();
          await _profileController.loadProfile();
        },
        color: AppColors.primary,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.fromLTRB(16.w, 10.h, 16.w, 50.h),
          child: Obx(() {
            final hasBank = _checkHasBankDetails();
            final bank = _profileController.profile['bank_details'] as Map? ?? {};
            final balance = _earningsController.walletBalance.value;

            return Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Balance Card ───────────────────────────────────────
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(24.w),
                    decoration: BoxDecoration(
                      gradient: AppColors.primaryGradient,
                      borderRadius: BorderRadius.circular(16.r),
                    ),
                    child: Column(
                      children: [
                        Text(
                          'available_balance'.tr,
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: Colors.white70,
                          ),
                        ),
                        SizedBox(height: 8.h),
                        Text(
                          '₹${balance.toStringAsFixed(2)}',
                          style: AppTextStyles.h1.copyWith(color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 32.h),

                  if (!hasBank) ...[
                    // ── Bank Setup Prompt ──────────────────────────────
                    PremiumCard(
                      padding: EdgeInsets.all(20.w),
                      child: Column(
                        children: [
                          Icon(Icons.account_balance_outlined, color: Colors.orange, size: 48.sp),
                          SizedBox(height: 16.h),
                          Text(
                            'Please setup your bank details before you can withdraw your funds.',
                            style: AppTextStyles.bodyMedium,
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: 20.h),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () => Get.toNamed(AppRoutes.bankDetails),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                padding: EdgeInsets.symmetric(vertical: 14.h),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12.r),
                                ),
                              ),
                              child: Text('Setup Bank Details', style: AppTextStyles.button),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ] else ...[
                    // ── Amount Input ──────────────────────────────────
                    Text('amount_to_withdraw'.tr, style: AppTextStyles.h4),
                    SizedBox(height: 16.h),
                    TextFormField(
                      controller: _amountController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      style: AppTextStyles.h3,
                      validator: (value) {
                        if (value == null || value.isEmpty) return 'Enter amount';
                        final amt = double.tryParse(value) ?? 0.0;
                        if (amt <= 0) return 'Enter a valid amount';
                        if (amt > balance) return 'Insufficient balance';
                        return null;
                      },
                      decoration: InputDecoration(
                        prefixText: '₹ ',
                        prefixStyle: AppTextStyles.h3,
                        hintText: '0.00',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.r),
                          borderSide: BorderSide(color: AppColors.border),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.r),
                          borderSide: BorderSide(color: AppColors.primary, width: 2),
                        ),
                      ),
                    ),
                    SizedBox(height: 24.h),

                    // ── Bank Card Details ──────────────────────────────
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('select_bank_acc'.tr, style: AppTextStyles.h4),
                        TextButton(
                          onPressed: () => Get.toNamed(AppRoutes.bankDetails),
                          child: Text('Change', style: AppTextStyles.bodyMedium.copyWith(color: AppColors.primary)),
                        ),
                      ],
                    ),
                    SizedBox(height: 12.h),
                    PremiumCard(
                      padding: EdgeInsets.all(16.w),
                      border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
                      child: Row(
                        children: [
                          Icon(
                            Icons.account_balance,
                            color: AppColors.primary,
                            size: 32.sp,
                          ),
                          SizedBox(width: 16.w),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  bank['bank_name']?.toString() ?? 'Bank Name',
                                  style: AppTextStyles.bodyMedium.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Text(
                                  bank['account_no']?.toString() ?? 'Acc: ****',
                                  style: AppTextStyles.caption,
                                ),
                              ],
                            ),
                          ),
                          Icon(Icons.check_circle, color: AppColors.primary),
                        ],
                      ),
                    ),
                    SizedBox(height: 32.h),

                    // ── Withdraw Button ───────────────────────────────
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _earningsController.isWithdrawing.value ? null : _submitRequest,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          padding: EdgeInsets.symmetric(vertical: 16.h),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                        ),
                        child: _earningsController.isWithdrawing.value
                            ? SizedBox(
                                height: 20.h,
                                width: 20.h,
                                child: const CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                              )
                            : Text('request_withdrawal'.tr, style: AppTextStyles.button),
                      ),
                    ),
                  ],

                  // ── Withdrawal History ───────────────────────────────
                  if (_earningsController.withdrawals.isNotEmpty) ...[
                    SizedBox(height: 40.h),
                    Text('Withdrawal History', style: AppTextStyles.h4),
                    SizedBox(height: 16.h),
                    ..._earningsController.withdrawals.map((item) => _buildWithdrawalHistoryCard(item as Map)),
                  ]
                ],
              ),
            );
          }),
        ),
      ),
    );
  }

  Widget _buildWithdrawalHistoryCard(Map item) {
    final status = item['status']?.toString() ?? 'pending';
    final amount = item['amount'] ?? 0;
    final dateStr = item['createdAt']?.toString() ?? '';
    
    String formattedDate = '';
    if (dateStr.isNotEmpty) {
      try {
        final dt = DateTime.parse(dateStr);
        formattedDate = '${dt.day}/${dt.month}/${dt.year}';
      } catch (_) {}
    }

    Color statusColor = Colors.orange;
    if (status == 'paid') statusColor = Colors.green;
    if (status == 'rejected') statusColor = Colors.red;

    return PremiumCard(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(16.w),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Payout Request',
                style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 4.h),
              Text(
                formattedDate,
                style: AppTextStyles.caption,
              ),
              if (status == 'paid' && item['transaction_ref'] != null) ...[
                SizedBox(height: 4.h),
                Text(
                  'Txn Ref: ${item['transaction_ref']}',
                  style: AppTextStyles.caption.copyWith(color: Colors.green),
                ),
              ],
              if (status == 'rejected' && item['admin_note'] != null) ...[
                SizedBox(height: 4.h),
                Text(
                  'Reason: ${item['admin_note']}',
                  style: AppTextStyles.caption.copyWith(color: Colors.red),
                ),
              ]
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '₹$amount',
                style: AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 6.h),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 3.h),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8.r),
                  border: Border.all(color: statusColor.withValues(alpha: 0.2)),
                ),
                child: Text(
                  status.toUpperCase(),
                  style: AppTextStyles.caption.copyWith(
                    color: statusColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 10.sp,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
