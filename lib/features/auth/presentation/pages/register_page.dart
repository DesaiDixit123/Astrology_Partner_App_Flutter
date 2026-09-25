import 'dart:io';
import 'package:astrology_partner/core/theme/app_colors.dart';
import 'package:astrology_partner/core/theme/app_text_styles.dart';
import 'package:astrology_partner/shared/widgets/premium_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../../shared/widgets/custom_button.dart';
import '../../../../shared/widgets/custom_text_field.dart';
import '../../../../shared/widgets/custom_searchable_dropdown.dart';
import '../controllers/auth_controller.dart';

class RegisterPage extends GetView<AuthController> {
  RegisterPage({super.key});

  final PageController _pageController = PageController();
  final RxInt _currentStep = 1.obs;

  final List<Map<String, String>> _steps = [
    {'title': 'skill_detail', 'subtitle': 'skills_expertise'},
    {'title': 'personal_detail', 'subtitle': 'basic_info_subtitle'},
    {'title': 'bank_details_title', 'subtitle': 'bank_details_subtitle'},
    {'title': 'other_details', 'subtitle': 'other_details_subtitle'},
    {'title': 'availability', 'subtitle': 'availability_subtitle'},
  ];

  @override
  Widget build(BuildContext context) {
    if (controller.languages.isEmpty || controller.qualifications.isEmpty) {
      controller.fetchMasters();
    }
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('complete_registration'.tr, style: AppTextStyles.appBarTitle),
        backgroundColor: AppColors.background,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: AppColors.textPrimary,
          ),
          onPressed: () {
            if (_currentStep.value > 1) {
              _pageController.previousPage(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
              );
              _currentStep.value--;
            } else {
              Get.back();
            }
          },
        ),
      ),
      body: Column(
        children: [
          _buildStepIndicator(),
          Expanded(
            child: PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _buildSkillStep(context),
                _buildPersonalStep(context),
                _buildBankStep(context),
                _buildOtherStep(context),
                _buildAvailabilityStep(context),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildStepIndicator() {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 20.w),
      color: AppColors.surface,
      child: Column(
        children: [
          Obx(
            () => Row(
              children: List.generate(_steps.length * 2 - 1, (index) {
                if (index.isOdd) {
                  return Expanded(
                    child: Container(
                      height: 2.h,
                      color: (index ~/ 2 + 1) < _currentStep.value
                          ? AppColors.primary
                          : AppColors.border,
                    ),
                  );
                }
                final stepIdx = index ~/ 2 + 1;
                final isActive = stepIdx == _currentStep.value;
                final isCompleted = stepIdx < _currentStep.value;

                return Container(
                  width: 32.w,
                  height: 32.w,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isCompleted || isActive
                        ? AppColors.primary
                        : AppColors.surface,
                    border: Border.all(
                      color: isCompleted || isActive
                          ? AppColors.primary
                          : AppColors.border,
                      width: 2,
                    ),
                  ),
                  child: Center(
                    child: isCompleted
                        ? Icon(Icons.check, color: Colors.white, size: 16.sp)
                        : Text(
                            '$stepIdx',
                            style: AppTextStyles.label.copyWith(
                              color: isActive || isCompleted
                                  ? Colors.white
                                  : AppColors.textSecondary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                );
              }),
            ),
          ),
          SizedBox(height: 8.h),
          Obx(
            () => Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: _steps.asMap().entries.map((entry) {
                final idx = entry.key + 1;
                return Expanded(
                  child: Text(
                    entry.value['title']!.tr.split(' ')[0],
                    textAlign: TextAlign.center,
                    style: AppTextStyles.caption.copyWith(
                      fontSize: 10.sp,
                      color: idx <= _currentStep.value
                          ? AppColors.textPrimary
                          : AppColors.textSecondary,
                      fontWeight: idx == _currentStep.value
                          ? FontWeight.bold
                          : FontWeight.normal,
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNav() {
    return SafeArea(
      top: false,
      bottom: true,
      child: Container(
        padding: EdgeInsets.all(20.w),
        decoration: BoxDecoration(
          color: AppColors.surface,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: Obx(
        () => Row(
          children: [
            if (_currentStep.value > 1) ...[
              Expanded(
                child: CustomButton(
                  text: 'back'.tr,
                  onPressed: () {
                    _pageController.previousPage(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                    _currentStep.value--;
                  },
                  backgroundColor: AppColors.surface,
                  textColor: AppColors.primary,
                  //borderSide: const BorderSide(color: AppColors.primary),
                ),
              ),
              SizedBox(width: 16.w),
            ],
            Expanded(
              child: CustomButton(
                text: _currentStep.value == 5 ? 'submit'.tr : 'next'.tr,
                onPressed: () async {
                  if (_currentStep.value < 5) {
                    final success = await controller.registerStep(
                      _currentStep.value,
                    );
                    if (success != false) {
                      _pageController.nextPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                      _currentStep.value++;
                    }
                  } else {
                    controller.register();
                  }
                },
                isLoading: controller.isLoading.value,
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

  Widget _buildSkillStep(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(20.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSection('specializations'.tr, [
            CustomMultiSelectDropdown(
              labelText: '',
              hintText: 'select_specialization'.tr,
              items: controller.categories,
              selectedIds: controller.selectedCategories,
              onToggle: controller.toggleCategory,
            ),
          ], isRequired: true),
          SizedBox(height: 24.h),
          _buildSection('skills'.tr, [
            CustomMultiSelectDropdown(
              labelText: '',
              hintText: 'select_skills'.tr,
              items: controller.skills,
              selectedIds: controller.selectedSkills,
              onToggle: controller.toggleSkill,
            ),
          ], isRequired: true),
          SizedBox(height: 24.h),
          _buildSection('languages'.tr, [
            CustomMultiSelectDropdown(
              labelText: '',
              hintText: 'select_languages'.tr,
              items: controller.languages,
              selectedIds: controller.selectedLanguages,
              onToggle: controller.toggleLanguage,
            ),
          ], isRequired: true),
          SizedBox(height: 24.h),
          _buildSection('experience_charges'.tr, [
            Row(
              children: [
                Expanded(
                  child: CustomTextField(
                    controller: controller.experienceController,
                    hintText: 'exp_years'.tr,
                    labelText: 'experience'.tr,
                    keyboardType: TextInputType.number,
                    isRequired: true,
                  ),
                ),
                SizedBox(width: 16.w),
                Expanded(
                  child: CustomTextField(
                    controller: controller.priceController,
                    hintText: 'fee_rupee'.tr,
                    labelText: 'chat_charge'.tr,
                    keyboardType: TextInputType.number,
                    isRequired: true,
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
                    hintText: 'fee_rupee'.tr,
                    labelText: 'video_charge'.tr,
                    keyboardType: TextInputType.number,
                    isRequired: true,
                  ),
                ),
                SizedBox(width: 16.w),
                Expanded(
                  child: CustomTextField(
                    controller: controller.voiceChargeController,
                    hintText: 'fee_rupee'.tr,
                    labelText: 'voice_charge'.tr,
                    keyboardType: TextInputType.number,
                    isRequired: true,
                  ),
                ),
              ],
            ),
            SizedBox(height: 16.h),
            Row(
              children: [
                Expanded(
                  child: CustomTextField(
                    controller: controller.reportChargeController,
                    hintText: 'fee_rupee'.tr,
                    labelText: 'report_charge'.tr,
                    keyboardType: TextInputType.number,
                    isRequired: true,
                  ),
                ),
                SizedBox(width: 16.w),
                Expanded(
                  child: CustomTextField(
                    controller: controller.dailyContributionController,
                    hintText: 'hours_per_day'.tr,
                    labelText: 'daily_contribution'.tr,
                    keyboardType: TextInputType.number,
                    isRequired: true,
                  ),
                ),
              ],
            ),
            SizedBox(height: 16.h),
            CustomTextField(
              controller: controller.hearAboutUsController,
              hintText: 'youtube_fb_etc'.tr,
              labelText: 'hear_about_us'.tr,
            ),
            SizedBox(height: 16.h),
            Obx(() => Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('working_on_other_platform'.tr, style: AppTextStyles.label),
                Switch(
                  value: controller.isWorkingOnOtherPlatform.value,
                  onChanged: (val) => controller.isWorkingOnOtherPlatform.value = val,
                  activeThumbColor: AppColors.primary,
                ),
              ],
            )),
          ], isRequired: true),
        ],
      ),
    );
  }

  Widget _buildPersonalStep(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(20.w),
      child: Column(
        children: [
          _buildProfileImage(),
          SizedBox(height: 32.h),
          _buildSection('basic_info'.tr, [
            CustomTextField(
              controller: controller.nameController,
              hintText: 'full_name'.tr,
              labelText: 'name'.tr,
              prefixIcon: Icons.person_outline_rounded,
              isRequired: true,
            ),
            SizedBox(height: 16.h),
            CustomTextField(
              controller: controller.emailController,
              hintText: 'email_addr'.tr,
              labelText: 'email'.tr,
              prefixIcon: Icons.email_outlined,
              keyboardType: TextInputType.emailAddress,
              isRequired: true,
            ),
            SizedBox(height: 16.h),
            _buildGenderSelector(),
            SizedBox(height: 16.h),
            GestureDetector(
              onTap: () => controller.selectDate(context),
              child: AbsorbPointer(
                child: CustomTextField(
                  controller: controller.dobController,
                  hintText: 'dob'.tr,
                  labelText: 'birth_date'.tr,
                  prefixIcon: Icons.calendar_today_rounded,
                  isRequired: true,
                ),
              ),
            ),
            SizedBox(height: 16.h),
            CustomTextField(
              controller: controller.phoneController,
              hintText: 'contact_no_hint'.tr,
              labelText: 'contact_no'.tr,
              prefixIcon: Icons.phone_android_rounded,
              keyboardType: TextInputType.phone,
              isRequired: true,
            ),
            SizedBox(height: 16.h),
            CustomTextField(
              controller: controller.whatsappController,
              hintText: 'whatsapp_no'.tr,
              labelText: 'whatsapp_number'.tr,
              prefixIcon: Icons.chat_bubble_outline_rounded,
              keyboardType: TextInputType.phone,
              isRequired: true,
            ),
          ], isRequired: true),
          SizedBox(height: 24.h),
          _buildSection('address'.tr, [
            CustomTextField(
              controller: controller.addressController,
              hintText: 'address'.tr,
              labelText: 'address'.tr,
              isRequired: true,
            ),
            SizedBox(height: 16.h),
            Obx(() => CustomSearchableDropdown(
              labelText: 'country'.tr,
              hintText: 'select_country'.tr,
              items: controller.countries,
              selectedValue: controller.selectedCountryIso.value,
              onChanged: controller.handleCountryChange,
              isRequired: true,
            )),
            SizedBox(height: 16.h),
            Obx(() => Row(
              children: [
                Expanded(
                  child: CustomSearchableDropdown(
                    labelText: 'state'.tr,
                    hintText: 'select_state'.tr,
                    items: controller.states,
                    selectedValue: controller.selectedStateIso.value,
                    onChanged: controller.handleStateChange,
                    isRequired: true,
                    readOnly: controller.selectedCountryIso.value.isEmpty,
                  ),
                ),
                SizedBox(width: 16.w),
                Expanded(
                  child: CustomSearchableDropdown(
                    labelText: 'city'.tr,
                    hintText: 'select_city'.tr,
                    items: controller.cities,
                    selectedValue: controller.selectedCityLabel.value,
                    onChanged: controller.handleCityChange,
                    isRequired: true,
                    readOnly: controller.selectedStateIso.value.isEmpty,
                  ),
                ),
              ],
            )),
            SizedBox(height: 16.h),
            CustomTextField(
              controller: controller.pincodeController,
              hintText: 'pincode'.tr,
              labelText: 'pincode'.tr,
              keyboardType: TextInputType.number,
              isRequired: true,
            ),
            SizedBox(height: 16.h),
            CustomTextField(
              controller: controller.panController,
              hintText: 'pan_no'.tr,
              labelText: 'pan_number'.tr,
              isRequired: true,
            ),
            SizedBox(height: 16.h),
            CustomTextField(
              controller: controller.aadharController,
              hintText: 'aadhar_no'.tr,
              labelText: 'aadhar_number'.tr,
              keyboardType: TextInputType.number,
              isRequired: true,
            ),
          ], isRequired: true),
          SizedBox(height: 24.h),
          _buildSection('documents'.tr, [
            _buildDocumentUpload(
              'Aadhaar Card Front *',
              controller.aadhaarImageUrl,
              controller.pickAadhaarImage,
              fileRx: controller.aadhaarImage,
            ),
            SizedBox(height: 16.h),
            _buildDocumentUpload(
              'Aadhaar Card Back *',
              controller.aadhaarBackImageUrl,
              controller.pickAadhaarBackImage,
              fileRx: controller.aadhaarBackImage,
            ),
            SizedBox(height: 16.h),
            _buildDocumentUpload(
              'PAN Card *',
              controller.panCardImageUrl,
              controller.pickPanCardImage,
              fileRx: controller.panCardImage,
            ),
            SizedBox(height: 16.h),
            _buildDocumentUpload(
              'Certificate',
              controller.certificateImageUrl,
              controller.pickCertificateImage,
              fileRx: controller.certificateImage,
            ),
          ], isRequired: true),
        ],
      ),
    );
  }

  Widget _buildBankStep(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(20.w),
      child: Column(
        children: [
          _buildSection('bank_account'.tr, [
            CustomTextField(
              controller: controller.accountHolderController,
              hintText: 'acc_holder'.tr,
              labelText: 'account_holder'.tr,
              isRequired: true,
            ),
            SizedBox(height: 16.h),
            CustomTextField(
              controller: controller.bankNameController,
              hintText: 'bank_name'.tr,
              labelText: 'bank_name'.tr,
              isRequired: true,
            ),
            SizedBox(height: 16.h),
            _buildSimpleDropdown(
              'account_type'.tr,
              ['saving', 'current'],
              controller.accountType,
              isRequired: true,
            ),
            SizedBox(height: 16.h),
            CustomTextField(
              controller: controller.accountNoController,
              hintText: 'acc_no'.tr,
              labelText: 'account_no'.tr,
              keyboardType: TextInputType.number,
              isRequired: true,
            ),
            SizedBox(height: 16.h),
            CustomTextField(
              controller: controller.ifscController,
              hintText: 'ifsc'.tr,
              labelText: 'ifsc_code'.tr,
              isRequired: true,
            ),
            SizedBox(height: 16.h),
            CustomTextField(
              controller: controller.bankBranchController,
              hintText: 'branch'.tr,
              labelText: 'bank_branch'.tr,
              isRequired: true,
            ),
            SizedBox(height: 16.h),
            CustomTextField(
              controller: controller.upiIdController,
              hintText: 'upi_id_hint'.tr,
              labelText: 'upi_id'.tr,
            ),
          ], isRequired: true),
        ],
      ),
    );
  }

  Widget _buildOtherStep(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(20.w),
      child: Column(
        children: [
          _buildSection('education_details'.tr, [
            _buildMasterDropdown(
              'qualification'.tr,
              controller.qualifications,
              controller.highestQualificationId,
              isRequired: true,
            ),
            SizedBox(height: 16.h),
            _buildMasterDropdown(
              'degree'.tr,
              controller.degrees,
              controller.degreeDiplomaId,
              isRequired: true,
            ),
            SizedBox(height: 16.h),
            CustomTextField(
              controller: controller.collegeSchoolController,
              hintText: 'college_hint'.tr,
              labelText: 'college_school'.tr,
            ),
            SizedBox(height: 16.h),
            CustomTextField(
              controller: controller.learnAstrologyFromController,
              hintText: 'learn_from_hint'.tr,
              labelText: 'learn_astrology_from'.tr,
            ),
          ], isRequired: true),
          SizedBox(height: 24.h),
          _buildSection('about_you'.tr, [
            CustomTextField(
              controller: controller.onboardReasonController,
              hintText: 'why_join'.tr,
              labelText: 'onboard_reason'.tr,
              maxLines: 2,
              isRequired: true,
            ),
            SizedBox(height: 16.h),
            CustomTextField(
              controller: controller.interviewTimeController,
              hintText: 'interview_time_hint'.tr,
              labelText: 'interview_time'.tr,
              isRequired: true,
            ),
            SizedBox(height: 16.h),
            _buildSimpleDropdown(
              'source_of_business'.tr,
              [
                'own_business',
                'job',
                'freelancer',
                'online_consultation'
              ],
              controller.mainSourceOfBusiness,
              isRequired: true,
            ),
            SizedBox(height: 16.h),
            Row(
              children: [
                Expanded(
                  child: CustomTextField(
                    controller: controller.minEarningController,
                    hintText: '0',
                    labelText: 'min_earning'.tr,
                    keyboardType: TextInputType.number,
                    isRequired: true,
                  ),
                ),
                SizedBox(width: 16.w),
                Expanded(
                  child: CustomTextField(
                    controller: controller.maxEarningController,
                    hintText: '0',
                    labelText: 'max_earning'.tr,
                    keyboardType: TextInputType.number,
                    isRequired: true,
                  ),
                ),
              ],
            ),
            SizedBox(height: 16.h),
            CustomTextField(
              controller: controller.biographyController,
              hintText: 'short_bio'.tr,
              labelText: 'biography'.tr,
              maxLines: 3,
              isRequired: true,
            ),
            SizedBox(height: 16.h),
            Obx(() => Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('full_time_job'.tr, style: AppTextStyles.label),
                Switch(
                  value: controller.isFullTimeJob.value,
                  onChanged: (val) => controller.isFullTimeJob.value = val,
                  activeThumbColor: AppColors.primary,
                ),
              ],
            )),
          ], isRequired: true),
          SizedBox(height: 24.h),
          _buildSection('social_profiles'.tr, [
            CustomTextField(
              controller: controller.instagramController,
              hintText: 'instagram_link'.tr,
              labelText: 'instagram'.tr,
            ),
            SizedBox(height: 12.h),
            CustomTextField(
              controller: controller.facebookController,
              hintText: 'facebook_link'.tr,
              labelText: 'facebook'.tr,
            ),
            SizedBox(height: 12.h),
            CustomTextField(
              controller: controller.linkedinController,
              hintText: 'linkedin_link'.tr,
              labelText: 'linkedin'.tr,
            ),
            SizedBox(height: 12.h),
            CustomTextField(
              controller: controller.youtubeController,
              hintText: 'youtube_link'.tr,
              labelText: 'youtube'.tr,
            ),
            SizedBox(height: 12.h),
            CustomTextField(
              controller: controller.websiteController,
              hintText: 'website_link'.tr,
              labelText: 'website'.tr,
            ),
          ]),
          SizedBox(height: 24.h),
          _buildSection('behavioral_questions'.tr, [
            CustomTextField(
              controller: controller.goodQualitiesController,
              hintText: 'qualities_hint'.tr,
              labelText: 'good_qualities'.tr,
              maxLines: 3,
              isRequired: true,
            ),
            SizedBox(height: 16.h),
            CustomTextField(
              controller: controller.biggestChallengeController,
              hintText: 'challenge_hint'.tr,
              labelText: 'biggest_challenge'.tr,
              maxLines: 3,
              isRequired: true,
            ),
            SizedBox(height: 16.h),
            CustomTextField(
              controller: controller.customerQueryResponseController,
              hintText: 'customer_query_hint'.tr,
              labelText: 'customer_query_response'.tr,
              maxLines: 3,
              isRequired: true,
            ),
            SizedBox(height: 16.h),
            CustomTextField(
              controller: controller.referredByController,
              hintText: 'referred_by_hint'.tr,
              labelText: 'referred_by'.tr,
            ),
          ], isRequired: true),
        ],
      ),
    );
  }

  Widget _buildAvailabilityStep(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(20.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('manage_availability'.tr, style: AppTextStyles.h4),
          SizedBox(height: 8.h),
          Text('availability_desc'.tr, style: AppTextStyles.caption),
          SizedBox(height: 24.h),
          ...[
            'sunday',
            'monday',
            'tuesday',
            'wednesday',
            'thursday',
            'friday',
            'saturday',
          ].map((day) {
            return _buildDayAvailability(day);
          }),
        ],
      ),
    );
  }

  Widget _buildDayAvailability(String day) {
    return Obx(() {
      final data = controller.availability[day] ?? {};
      final isAvailable = data['is_available'] ?? false;
      final timeRange = "${data['start_time'] ?? '09:00 AM'} - ${data['end_time'] ?? '09:00 PM'}";

      return Container(
        margin: EdgeInsets.only(bottom: 16.h),
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: isAvailable ? AppColors.surface : AppColors.surfaceVariant,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
            color: isAvailable ? AppColors.primary.withValues(alpha: 0.3) : AppColors.border,
            width: isAvailable ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Expanded(
              flex: 2,
              child: Text(
                day.tr,
                style: AppTextStyles.bodyLarge.copyWith(
                  fontWeight: FontWeight.bold,
                  color: isAvailable ? AppColors.textPrimary : AppColors.textSecondary,
                ),
              ),
            ),
            Expanded(
              flex: 3,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isAvailable ? timeRange : 'closed'.tr,
                    style: AppTextStyles.caption.copyWith(
                      color: isAvailable ? AppColors.primary : AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Switch(
              value: isAvailable,
              onChanged: (val) => controller.toggleDayAvailability(day, val),
              activeThumbColor: AppColors.primary,
            ),
          ],
        ),
      );
    });
  }

  Widget _buildSection(String title, List<Widget> children, {bool isRequired = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            text: title,
            style: AppTextStyles.h4.copyWith(
              fontWeight: FontWeight.w900,
              color: AppColors.primary,
            ),
            children: [
              if (isRequired)
                const TextSpan(
                  text: ' *',
                  style: TextStyle(
                    color: AppColors.error,
                    fontWeight: FontWeight.bold,
                  ),
                ),
            ],
          ),
        ),
        SizedBox(height: 16.h),
        PremiumCard(
          padding: EdgeInsets.all(16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: children,
          ),
        ),
      ],
    );
  }

  Widget _buildChipGrid(
    List<dynamic> items,
    List<dynamic> selectedIds,
    Function toggle,
  ) {
    return Obx(
      () => Wrap(
        spacing: 8.w,
        runSpacing: 8.h,
        children: items.map((item) {
          final isSelected = selectedIds.contains(item['_id']);
          return FilterChip(
            label: Text(item['name'] ?? ''),
            selected: isSelected,
            onSelected: (_) => toggle(item),
            selectedColor: AppColors.primary,
            labelStyle: AppTextStyles.caption.copyWith(
              color: isSelected ? Colors.white : AppColors.textPrimary,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
            backgroundColor: AppColors.surface,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20.r),
              side: BorderSide(
                color: isSelected ? AppColors.primary : AppColors.border,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildMasterDropdown(String label, RxList items, RxString selectedId, {bool isRequired = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            text: label,
            style: AppTextStyles.label,
            children: [
              if (isRequired)
                const TextSpan(
                  text: ' *',
                  style: TextStyle(
                    color: AppColors.error,
                    fontWeight: FontWeight.bold,
                  ),
                ),
            ],
          ),
        ),
        SizedBox(height: 8.h),
        Obx(
          () => Container(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(color: AppColors.border),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                isExpanded: true,
                value: selectedId.value.isEmpty ? null : selectedId.value,
                hint: Text('select'.tr),
                items: items.map((item) {
                  return DropdownMenuItem<String>(
                    value: item['_id'],
                    child: Text(item['qualification_name'] ??
                        item['degree_name'] ??
                        item['name'] ??
                        ''),
                  );
                }).toList(),
                onChanged: (val) => selectedId.value = val ?? '',
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSimpleDropdown(String label, List<String> options, RxString selectedValue, {bool isRequired = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            text: label,
            style: AppTextStyles.label,
            children: [
              if (isRequired)
                const TextSpan(
                  text: ' *',
                  style: TextStyle(
                    color: AppColors.error,
                    fontWeight: FontWeight.bold,
                  ),
                ),
            ],
          ),
        ),
        SizedBox(height: 8.h),
        Obx(
          () => Container(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(color: AppColors.border),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                isExpanded: true,
                value: selectedValue.value.isEmpty ? null : selectedValue.value,
                hint: Text('select'.tr),
                items: options.map((opt) {
                  String displayText = opt.tr;
                  if (displayText == opt) {
                    displayText = opt.replaceAll('_', ' ').split(' ').map((word) => word.capitalizeFirst ?? word).join(' ');
                  }
                  return DropdownMenuItem<String>(
                    value: opt,
                    child: Text(displayText),
                  );
                }).toList(),
                onChanged: (val) => selectedValue.value = val ?? '',
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDocumentUpload(
    String label,
    RxString url,
    VoidCallback onTap, {
    Rx<File?>? fileRx,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.label),
        SizedBox(height: 8.h),
        GestureDetector(
          onTap: onTap,
          child: Obx(
            () {
              final hasLocalFile = fileRx != null && fileRx.value != null;
              final hasUrl = url.value.isNotEmpty;

              return Container(
                height: 120.h,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(
                    color: (hasLocalFile || hasUrl)
                        ? AppColors.primary
                        : AppColors.border,
                    width: (hasLocalFile || hasUrl) ? 1.5 : 1.0,
                  ),
                ),
                child: (!hasLocalFile && !hasUrl)
                    ? Center(
                        child: Icon(
                          Icons.add_a_photo_outlined,
                          color: AppColors.primary,
                          size: 32.sp,
                        ),
                      )
                    : ClipRRect(
                        borderRadius: BorderRadius.circular(12.r),
                        child: hasLocalFile
                            ? Image.file(fileRx.value!, fit: BoxFit.cover)
                            : Image.network(url.value, fit: BoxFit.cover),
                      ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildProfileImage() {
    return Center(
      child: GestureDetector(
        onTap: controller.pickImage,
        child: Obx(
          () {
            final hasLocalFile = controller.profileImage.value != null;
            final hasUrl = controller.profileImageUrl.value.isNotEmpty;

            ImageProvider? imageProvider;
            if (hasLocalFile) {
              imageProvider = FileImage(controller.profileImage.value!);
            } else if (hasUrl) {
              imageProvider = NetworkImage(controller.profileImageUrl.value);
            }

            return Stack(
              children: [
                Container(
                  width: 100.w,
                  height: 100.w,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.surface,
                    border: Border.all(color: AppColors.primary, width: 2),
                    image: imageProvider != null
                        ? DecorationImage(
                            image: imageProvider,
                            fit: BoxFit.cover,
                          )
                        : null,
                  ),
                  child: (imageProvider == null)
                      ? Icon(
                          Icons.person_rounded,
                          size: 50.sp,
                          color: AppColors.textHint,
                        )
                      : null,
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    padding: EdgeInsets.all(8.w),
                    decoration: const BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.camera_alt_rounded,
                      size: 16.sp,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildGenderSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            text: 'gender'.tr,
            style: AppTextStyles.label,
            children: const [
              TextSpan(
                text: ' *',
                style: TextStyle(
                  color: AppColors.error,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 8.h),
        Obx(
          () => Row(
            children: ['male', 'female', 'other'].asMap().entries.map((entry) {
              final idx = entry.key;
              final g = entry.value;
              final isSelected = controller.selectedGender.value == g;
              return Expanded(
                child: GestureDetector(
                  onTap: () => controller.setGender(g),
                  child: Container(
                    margin: EdgeInsets.only(right: idx == 2 ? 0 : 8.w),
                    padding: EdgeInsets.symmetric(vertical: 12.h),
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.primary : Colors.white,
                      borderRadius: BorderRadius.circular(12.r),
                      border: Border.all(
                        color: isSelected
                            ? AppColors.primary
                            : AppColors.border,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        g.tr,
                        style: AppTextStyles.caption.copyWith(
                          color: isSelected
                              ? Colors.white
                              : AppColors.textPrimary,
                          fontWeight: isSelected
                              ? FontWeight.bold
                              : FontWeight.normal,
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}
