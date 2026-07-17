import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/network/api_service.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/utils/snackbar_util.dart';
import '../controllers/profile_controller.dart';

class BankDetailsPage extends StatefulWidget {
  const BankDetailsPage({super.key});

  @override
  State<BankDetailsPage> createState() => _BankDetailsPageState();
}

class _BankDetailsPageState extends State<BankDetailsPage> {
  final _formKey = GlobalKey<FormState>();
  
  late final TextEditingController _holderController;
  late final TextEditingController _bankNameController;
  late final TextEditingController _accNoController;
  late final TextEditingController _ifscController;
  late final TextEditingController _panController;
  
  bool _isLoading = false;
  final _profileController = Get.find<ProfileController>();

  @override
  void initState() {
    super.initState();
    final bank = _profileController.profile['bank_details'] as Map? ?? {};
    final personal = _profileController.profile['personal_details'] as Map? ?? {};
    
    _holderController = TextEditingController(text: bank['account_holder_name']?.toString() ?? '');
    _bankNameController = TextEditingController(text: bank['bank_name']?.toString() ?? '');
    _accNoController = TextEditingController(text: bank['account_no']?.toString() ?? '');
    _ifscController = TextEditingController(text: bank['ifsc_code']?.toString() ?? '');
    _panController = TextEditingController(text: personal['pan_no']?.toString() ?? _profileController.profile['pan_no']?.toString() ?? '');
  }

  @override
  void dispose() {
    _holderController.dispose();
    _bankNameController.dispose();
    _accNoController.dispose();
    _ifscController.dispose();
    _panController.dispose();
    super.dispose();
  }

  Future<void> _saveDetails() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final res = await ApiService.instance.put(
        ApiConstants.profile,
        data: {
          'bank_details': {
            'account_holder_name': _holderController.text.trim(),
            'bank_name': _bankNameController.text.trim(),
            'account_no': _accNoController.text.trim(),
            'ifsc_code': _ifscController.text.trim(),
            'account_type': 'Saving',
            'pan_no': _panController.text.trim(),
          }
        },
      );

      if (ApiService.isSuccess(res)) {
        SnackbarUtil.success('Bank details updated successfully!');
        await _profileController.loadProfile(); // refresh local profile
        Get.back();
      } else {
        SnackbarUtil.error(ApiService.getMessage(res));
      }
    } catch (e) {
      SnackbarUtil.error('Failed to update bank details. Please try again.');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasDetails = _accNoController.text.isNotEmpty && _ifscController.text.isNotEmpty;

    return Scaffold(
      appBar: AppBar(
        title: Text('bank_details'.tr),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Get.back(),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.w),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (hasDetails)
                Container(
                  padding: EdgeInsets.all(16.w),
                  decoration: BoxDecoration(
                    color: Colors.green.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(color: Colors.green.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.verified, color: Colors.green, size: 24.sp),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: Text(
                          'bank_verified_msg'.tr,
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: Colors.green,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              SizedBox(height: 24.h),
              _buildTextField(
                label: 'acc_holder'.tr,
                controller: _holderController,
                validator: (v) => v!.isEmpty ? 'Account holder name is required' : null,
              ),
              SizedBox(height: 16.h),
              _buildTextField(
                label: 'bank_name'.tr,
                controller: _bankNameController,
                validator: (v) => v!.isEmpty ? 'Bank name is required' : null,
              ),
              SizedBox(height: 16.h),
              _buildTextField(
                label: 'acc_no'.tr,
                controller: _accNoController,
                validator: (v) => v!.isEmpty ? 'Account number is required' : null,
              ),
              SizedBox(height: 16.h),
              _buildTextField(
                label: 'ifsc'.tr,
                controller: _ifscController,
                validator: (v) => v!.isEmpty ? 'IFSC Code is required' : null,
              ),
              SizedBox(height: 16.h),
              _buildTextField(
                label: 'pan_card_no'.tr,
                controller: _panController,
                validator: (v) => v!.isEmpty ? 'PAN Card number is required' : null,
              ),
              SizedBox(height: 32.h),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _saveDetails,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: EdgeInsets.symmetric(vertical: 16.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                  ),
                  child: _isLoading 
                      ? SizedBox(
                          height: 20.h,
                          width: 20.h,
                          child: const CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                        )
                      : Text('update_details'.tr, style: AppTextStyles.button),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.bodyMedium),
        SizedBox(height: 8.h),
        TextFormField(
          controller: controller,
          style: AppTextStyles.bodyLarge,
          validator: validator,
          decoration: InputDecoration(
            contentPadding: EdgeInsets.symmetric(
              horizontal: 16.w,
              vertical: 12.h,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide(color: AppColors.border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide(color: AppColors.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide(color: AppColors.primary),
            ),
          ),
        ),
      ],
    );
  }
}
