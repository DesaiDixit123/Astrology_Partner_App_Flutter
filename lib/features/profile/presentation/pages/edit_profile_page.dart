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
                    PremiumCard(
                      padding: EdgeInsets.all(16.w),
                      child: Column(
                        children: [
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
                          Row(
                            children: [
                              Expanded(
                                child: CustomTextField(
                                  controller: controller.experienceController,
                                  hintText: 'exp_years'.tr,
                                  labelText: 'exp_years'.tr,
                                  prefixIcon: Icons.work_history_outlined,
                                  keyboardType: TextInputType.number,
                                ),
                              ),
                              SizedBox(width: 12.w),
                              Expanded(
                                child: Container(
                                  height: 56.h,
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 12.w,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.surface,
                                    border: Border.all(color: AppColors.border),
                                    borderRadius: BorderRadius.circular(16.r),
                                  ),
                                  child: Obx(
                                    () => DropdownButtonHideUnderline(
                                      child: DropdownButton<String>(
                                        value:
                                            [
                                              'male',
                                              'female',
                                              'other',
                                            ].contains(
                                              controller.selectedGender.value
                                                  .toLowerCase(),
                                            )
                                            ? controller.selectedGender.value
                                                  .toLowerCase()
                                            : null,
                                        hint: Text(
                                          'gender'.tr,
                                          style: AppTextStyles.hint,
                                        ),
                                        isExpanded: true,
                                        icon: Icon(
                                          Icons.keyboard_arrow_down_rounded,
                                          color: AppColors.textSecondary,
                                        ),
                                        items: ['male', 'female', 'other']
                                            .map(
                                              (e) => DropdownMenuItem(
                                                value: e,
                                                child: Text(
                                                  e.tr,
                                                  style:
                                                      AppTextStyles.bodyMedium,
                                                ),
                                              ),
                                            )
                                            .toList(),
                                        onChanged: (v) =>
                                            controller.setGender(v ?? ''),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 16.h),
                          CustomTextField(
                            controller: controller.biographyController,
                            hintText: 'expertise_hint'.tr,
                            labelText: 'short_bio'.tr,
                            prefixIcon: Icons.info_outline_rounded,
                            maxLines: 3,
                          ),
                          SizedBox(height: 16.h),
                          CustomTextField(
                            controller: controller.cityController,
                            hintText: 'city'.tr,
                            labelText: 'city'.tr,
                            prefixIcon: Icons.location_city_rounded,
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 24.h),
                    Obx(
                      () => PremiumCard(
                        padding: EdgeInsets.all(16.w),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildMultiSelectDropdown(
                              label: 'languages'.tr,
                              selectedItems: controller.allLanguages
                                  .where(
                                    (l) => controller.selectedLanguages
                                        .contains(l['_id']),
                                  )
                                  .map((l) => l['name'].toString())
                                  .toList(),
                              onTap: () => _showMultiSelectBottomSheet(
                                'languages'.tr,
                                controller.allLanguages,
                                controller.selectedLanguages,
                                (val) => controller.toggleLanguage(val),
                              ),
                            ),
                            SizedBox(height: 20.h),
                            _buildMultiSelectDropdown(
                              label: 'skills'.tr,
                              selectedItems: controller.allSkills
                                  .where(
                                    (s) => controller.selectedSkills.contains(
                                      s['_id'],
                                    ),
                                  )
                                  .map((s) => s['name'].toString())
                                  .toList(),
                              onTap: () => _showMultiSelectBottomSheet(
                                'skills'.tr,
                                controller.allSkills,
                                controller.selectedSkills,
                                (val) => controller.toggleSkill(val),
                              ),
                            ),
                            SizedBox(height: 20.h),
                            _buildMultiSelectDropdown(
                              label: 'categories'.tr,
                              selectedItems: controller.allCategories
                                  .where(
                                    (c) => controller.selectedCategories
                                        .contains(c['_id']),
                                  )
                                  .map((c) => c['name'].toString())
                                  .toList(),
                              onTap: () => _showMultiSelectBottomSheet(
                                'categories'.tr,
                                controller.allCategories,
                                controller.selectedCategories,
                                (val) => controller.toggleCategory(val),
                              ),
                            ),
                          ],
                        ),
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
