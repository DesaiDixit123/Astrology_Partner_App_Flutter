import 'package:astrology_partner/core/theme/app_colors.dart';
import 'package:astrology_partner/core/theme/app_text_styles.dart';
import 'package:astrology_partner/shared/widgets/premium_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../../shared/widgets/custom_button.dart';
import '../../../../shared/widgets/custom_text_field.dart';
import '../controllers/profile_controller.dart';

class EditProfilePage extends GetView<ProfileController> {
  const EditProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('edit_profile'.tr)),
      body: Obx(
        () => controller.isLoading.value
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(20.w, 10.h, 20.w, 40.h),
                child: Column(
                  children: [
                    SizedBox(height: 10.h),
                    Center(
                      child: Stack(
                        children: [
                          Obx(
                            () => Container(
                              padding: EdgeInsets.all(4.w),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: AppColors.gold.withValues(alpha: 0.5),
                                  width: 2,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.gold.withValues(
                                      alpha: 0.1,
                                    ),
                                    blurRadius: 15,
                                    spreadRadius: 2,
                                  ),
                                ],
                              ),
                              child: CircleAvatar(
                                radius: 60.r,
                                backgroundColor: AppColors.surface,
                                backgroundImage:
                                    controller.imageFile.value != null
                                    ? FileImage(controller.imageFile.value!)
                                    : (controller.profileImageUrl.isNotEmpty
                                              ? NetworkImage(
                                                  controller.profileImageUrl,
                                                )
                                              : null)
                                          as ImageProvider?,
                                child:
                                    controller.imageFile.value == null &&
                                        controller.profileImageUrl.isEmpty
                                    ? Icon(
                                        Icons.person_rounded,
                                        size: 60.sp,
                                        color: AppColors.primary,
                                      )
                                    : null,
                              ),
                            ),
                          ),
                          Positioned(
                            bottom: 5,
                            right: 5,
                            child: GestureDetector(
                              onTap: controller.pickImage,
                              child: Container(
                                padding: EdgeInsets.all(10.w),
                                decoration: BoxDecoration(
                                  color: AppColors.gold,
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(
                                        alpha: 0.2,
                                      ),
                                      blurRadius: 8,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: Icon(
                                  Icons.camera_alt_rounded,
                                  size: 20.sp,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 32.h),
                    SizedBox(height: 24.h),
                    // 1. Personal Information Card
                    PremiumCard(
                      padding: EdgeInsets.all(16.w),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildCardTitle('Personal Details', Icons.person_rounded),
                          SizedBox(height: 16.h),
                          CustomTextField(
                            controller: controller.nameController,
                            hintText: 'enter_name'.tr,
                            labelText: 'full_name'.tr,
                            prefixIcon: Icons.person_outline_rounded,
                          ),
                          SizedBox(height: 16.h),
                          CustomTextField(
                            controller: controller.emailController,
                            hintText: 'enter_email'.tr,
                            labelText: 'email'.tr,
                            prefixIcon: Icons.email_outlined,
                            keyboardType: TextInputType.emailAddress,
                          ),
                          SizedBox(height: 16.h),
                          CustomTextField(
                            controller: controller.phoneController,
                            hintText: 'phone'.tr,
                            labelText: 'phone'.tr,
                            prefixIcon: Icons.phone_android_rounded,
                            keyboardType: TextInputType.phone,
                          ),
                          SizedBox(height: 16.h),
                          CustomTextField(
                            controller: controller.whatsappController,
                            hintText: 'WhatsApp / Alternate Phone',
                            labelText: 'WhatsApp / Alternate Phone',
                            prefixIcon: Icons.chat_rounded,
                            keyboardType: TextInputType.phone,
                          ),
                          SizedBox(height: 16.h),
                          Row(
                            children: [
                              Expanded(
                                child: CustomTextField(
                                  controller: controller.dobController,
                                  hintText: 'YYYY-MM-DD',
                                  labelText: 'Date of Birth',
                                  prefixIcon: Icons.calendar_today_rounded,
                                ),
                              ),
                              SizedBox(width: 12.w),
                              Expanded(
                                child: Container(
                                  height: 56.h,
                                  padding: EdgeInsets.symmetric(horizontal: 12.w),
                                  decoration: BoxDecoration(
                                    color: AppColors.surface,
                                    border: Border.all(color: AppColors.border),
                                    borderRadius: BorderRadius.circular(16.r),
                                  ),
                                  child: Obx(
                                    () => DropdownButtonHideUnderline(
                                      child: DropdownButton<String>(
                                        value: ['male', 'female', 'other'].contains(controller.selectedGender.value.toLowerCase())
                                            ? controller.selectedGender.value.toLowerCase()
                                            : null,
                                        hint: Text('gender'.tr, style: AppTextStyles.hint),
                                        isExpanded: true,
                                        icon: Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.textSecondary),
                                        items: ['male', 'female', 'other']
                                            .map((e) => DropdownMenuItem(value: e, child: Text(e.tr, style: AppTextStyles.bodyMedium)))
                                            .toList(),
                                        onChanged: (v) => controller.setGender(v ?? ''),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 20.h),

                    // 2. Address Details Card
                    PremiumCard(
                      padding: EdgeInsets.all(16.w),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildCardTitle('Address & Location', Icons.location_on_rounded),
                          SizedBox(height: 16.h),
                          CustomTextField(
                            controller: controller.addressController,
                            hintText: 'Full Address',
                            labelText: 'Address',
                            prefixIcon: Icons.home_work_outlined,
                          ),
                          SizedBox(height: 16.h),
                          Row(
                            children: [
                              Expanded(
                                child: CustomTextField(
                                  controller: controller.cityController,
                                  hintText: 'City',
                                  labelText: 'City',
                                  prefixIcon: Icons.location_city_rounded,
                                ),
                              ),
                              SizedBox(width: 12.w),
                              Expanded(
                                child: CustomTextField(
                                  controller: controller.stateController,
                                  hintText: 'State',
                                  labelText: 'State',
                                  prefixIcon: Icons.map_outlined,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 16.h),
                          Row(
                            children: [
                              Expanded(
                                child: CustomTextField(
                                  controller: controller.countryController,
                                  hintText: 'Country',
                                  labelText: 'Country',
                                  prefixIcon: Icons.flag_outlined,
                                ),
                              ),
                              SizedBox(width: 12.w),
                              Expanded(
                                child: CustomTextField(
                                  controller: controller.pincodeController,
                                  hintText: 'Pincode',
                                  labelText: 'Pincode',
                                  prefixIcon: Icons.pin_drop_outlined,
                                  keyboardType: TextInputType.number,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 20.h),

                    // 3. Skills & Biography Card
                    Obx(
                      () => PremiumCard(
                        padding: EdgeInsets.all(16.w),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildCardTitle('Skills & Specialization', Icons.auto_awesome_rounded),
                            SizedBox(height: 16.h),
                            _buildMultiSelectDropdown(
                              label: 'languages'.tr,
                              selectedItems: controller.allLanguages
                                  .where((l) => controller.selectedLanguages.contains(l['_id']))
                                  .map((l) => l['name'].toString())
                                  .toList(),
                              onTap: () => _showMultiSelectBottomSheet(
                                'languages'.tr,
                                controller.allLanguages,
                                controller.selectedLanguages,
                                (val) => controller.toggleLanguage(val),
                              ),
                            ),
                            SizedBox(height: 16.h),
                            _buildMultiSelectDropdown(
                              label: 'skills'.tr,
                              selectedItems: controller.allSkills
                                  .where((s) => controller.selectedSkills.contains(s['_id']))
                                  .map((s) => s['name'].toString())
                                  .toList(),
                              onTap: () => _showMultiSelectBottomSheet(
                                'skills'.tr,
                                controller.allSkills,
                                controller.selectedSkills,
                                (val) => controller.toggleSkill(val),
                              ),
                            ),
                            SizedBox(height: 16.h),
                            _buildMultiSelectDropdown(
                              label: 'categories'.tr,
                              selectedItems: controller.allCategories
                                  .where((c) => controller.selectedCategories.contains(c['_id']))
                                  .map((c) => c['name'].toString())
                                  .toList(),
                              onTap: () => _showMultiSelectBottomSheet(
                                'categories'.tr,
                                controller.allCategories,
                                controller.selectedCategories,
                                (val) => controller.toggleCategory(val),
                              ),
                            ),
                            SizedBox(height: 16.h),
                            CustomTextField(
                              controller: controller.experienceController,
                              hintText: 'exp_years'.tr,
                              labelText: 'Experience (Years)',
                              prefixIcon: Icons.work_history_outlined,
                              keyboardType: TextInputType.number,
                            ),
                            SizedBox(height: 16.h),
                            CustomTextField(
                              controller: controller.biographyController,
                              hintText: 'Bio / About your astrology background...',
                              labelText: 'Biography / About Me',
                              prefixIcon: Icons.info_outline_rounded,
                              maxLines: 4,
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 20.h),

                    // 4. Consultation Charges Card
                    PremiumCard(
                      padding: EdgeInsets.all(16.w),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildCardTitle('Consultation Charges & Availability', Icons.monetization_on_rounded),
                          SizedBox(height: 16.h),
                          Row(
                            children: [
                              Expanded(
                                child: CustomTextField(
                                  controller: controller.chatChargeController,
                                  hintText: 'Chat Fee (₹/min)',
                                  labelText: 'Chat Fee (₹/min)',
                                  prefixIcon: Icons.chat_bubble_outline_rounded,
                                  keyboardType: TextInputType.number,
                                ),
                              ),
                              SizedBox(width: 12.w),
                              Expanded(
                                child: CustomTextField(
                                  controller: controller.voiceChargeController,
                                  hintText: 'Voice Fee (₹/min)',
                                  labelText: 'Voice Fee (₹/min)',
                                  prefixIcon: Icons.phone_outlined,
                                  keyboardType: TextInputType.number,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 16.h),
                          Row(
                            children: [
                              Expanded(
                                child: CustomTextField(
                                  controller: controller.videoChargeController,
                                  hintText: 'Video Fee (₹/min)',
                                  labelText: 'Video Fee (₹/min)',
                                  prefixIcon: Icons.videocam_outlined,
                                  keyboardType: TextInputType.number,
                                ),
                              ),
                              SizedBox(width: 12.w),
                              Expanded(
                                child: CustomTextField(
                                  controller: controller.reportChargeController,
                                  hintText: 'Report Fee (₹)',
                                  labelText: 'Report Fee (₹)',
                                  prefixIcon: Icons.assignment_outlined,
                                  keyboardType: TextInputType.number,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 16.h),
                          CustomTextField(
                            controller: controller.dailyContributionController,
                            hintText: 'Daily Available Hours (e.g. 4-6)',
                            labelText: 'Daily Contribution Hours',
                            prefixIcon: Icons.access_time_rounded,
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 20.h),

                    // 5. Educational Details Card
                    PremiumCard(
                      padding: EdgeInsets.all(16.w),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildCardTitle('Education & Qualifications', Icons.school_rounded),
                          SizedBox(height: 16.h),
                          CustomTextField(
                            controller: controller.collegeController,
                            hintText: 'College / School / Institute Name',
                            labelText: 'College / Institute Name',
                            prefixIcon: Icons.account_balance_outlined,
                          ),
                          SizedBox(height: 16.h),
                          CustomTextField(
                            controller: controller.learnAstrologyFromController,
                            hintText: 'Where did you learn astrology?',
                            labelText: 'Learned Astrology From',
                            prefixIcon: Icons.menu_book_rounded,
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 20.h),

                    // 6. Bank & Document Verification Card
                    PremiumCard(
                      padding: EdgeInsets.all(16.w),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildCardTitle('Bank & Payout Details', Icons.account_balance_wallet_rounded),
                          SizedBox(height: 16.h),
                          CustomTextField(
                            controller: controller.accountHolderController,
                            hintText: 'Account Holder Name',
                            labelText: 'Account Holder Name',
                            prefixIcon: Icons.badge_outlined,
                          ),
                          SizedBox(height: 16.h),
                          CustomTextField(
                            controller: controller.bankAccountController,
                            hintText: 'Bank Account Number',
                            labelText: 'Bank Account Number',
                            prefixIcon: Icons.credit_card_rounded,
                            keyboardType: TextInputType.number,
                          ),
                          SizedBox(height: 16.h),
                          Row(
                            children: [
                              Expanded(
                                child: CustomTextField(
                                  controller: controller.ifscController,
                                  hintText: 'IFSC Code',
                                  labelText: 'IFSC Code',
                                  prefixIcon: Icons.code_rounded,
                                ),
                              ),
                              SizedBox(width: 12.w),
                              Expanded(
                                child: CustomTextField(
                                  controller: controller.upiController,
                                  hintText: 'UPI ID',
                                  labelText: 'UPI ID',
                                  prefixIcon: Icons.qr_code_2_rounded,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 16.h),
                          Row(
                            children: [
                              Expanded(
                                child: CustomTextField(
                                  controller: controller.panController,
                                  hintText: 'PAN Number',
                                  labelText: 'PAN Card No.',
                                  prefixIcon: Icons.subtitles_outlined,
                                ),
                              ),
                              SizedBox(width: 12.w),
                              Expanded(
                                child: CustomTextField(
                                  controller: controller.aadharController,
                                  hintText: 'Aadhar Number',
                                  labelText: 'Aadhar Card No.',
                                  prefixIcon: Icons.fingerprint_rounded,
                                  keyboardType: TextInputType.number,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 32.h),

                    CustomButton(
                      text: 'save_changes'.tr,
                      onPressed: controller.updateProfile,
                      gradient: AppColors.primaryGradient,
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildCardTitle(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 20.sp, color: AppColors.primary),
        SizedBox(width: 8.w),
        Text(
          title,
          style: AppTextStyles.h4.copyWith(
            fontSize: 16.sp,
            color: AppColors.primary,
          ),
        ),
      ],
    );
  }

  Widget _buildMultiSelectDropdown({
    required String label,
    required List<String> selectedItems,
    required VoidCallback onTap,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(label),
        GestureDetector(
          onTap: onTap,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
            decoration: BoxDecoration(
              color: AppColors.surface,
              border: Border.all(color: AppColors.border),
              borderRadius: BorderRadius.circular(16.r),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    selectedItems.isEmpty
                        ? 'select'.tr + ' ' + label.toLowerCase()
                        : selectedItems.join(', '),
                    style: selectedItems.isEmpty
                        ? AppTextStyles.hint
                        : AppTextStyles.bodyMedium,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Icon(
                  Icons.keyboard_arrow_down_rounded,
                  color: AppColors.textSecondary,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _showMultiSelectBottomSheet(
    String title,
    List<dynamic> allItems,
    RxList selectedIds,
    Function(dynamic) onToggle, {
    bool isIdBased = true,
  }) {
    Get.bottomSheet(
      Container(
        padding: EdgeInsets.all(20.w),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(30.r)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40.w,
              height: 4.h,
              margin: EdgeInsets.only(bottom: 20.h),
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(2.r),
              ),
            ),
            Text(
              'select'.tr + ' ' + title,
              style: AppTextStyles.h3.copyWith(color: AppColors.primary),
            ),
            SizedBox(height: 24.h),
            Flexible(
              child: SingleChildScrollView(
                child: Obx(
                  () => Wrap(
                    spacing: 10.w,
                    runSpacing: 10.h,
                    alignment: WrapAlignment.center,
                    children: allItems.map((item) {
                      final id = isIdBased ? item['_id'] : item['name'];
                      final isSelected = selectedIds.contains(id);
                      return _buildChip(
                        item['name'] ?? '',
                        isSelected,
                        () => onToggle(id),
                      );
                    }).toList(),
                  ),
                ),
              ),
            ),
            SizedBox(height: 32.h),
            CustomButton(
              text: 'done'.tr,
              onPressed: () => Get.back(),
              gradient: AppColors.primaryGradient,
            ),
            SizedBox(height: 10.h),
          ],
        ),
      ),
      isScrollControlled: true,
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12.h),
      child: Text(
        title,
        style: AppTextStyles.h4.copyWith(
          fontSize: 16.sp,
          color: AppColors.primary,
        ),
      ),
    );
  }

  Widget _buildChip(String label, bool isSelected, VoidCallback onSelected) {
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => onSelected(),
      backgroundColor: AppColors.surface,
      selectedColor: AppColors.primary.withValues(alpha: 0.15),
      checkmarkColor: AppColors.primary,
      labelStyle: AppTextStyles.bodySmall.copyWith(
        color: isSelected ? AppColors.primary : AppColors.textPrimary,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.r),
        side: BorderSide(
          color: isSelected ? AppColors.primary : AppColors.border,
          width: 1,
        ),
      ),
    );
  }
}
