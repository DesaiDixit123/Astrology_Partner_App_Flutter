import 'dart:io';
import 'package:dio/dio.dart' as dio;
import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../config/routes/app_routes.dart';
import '../../../../core/network/api_service.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/utils/snackbar_util.dart';
import '../../../../core/utils/image_picker_util.dart';

class ProfileController extends GetxController {
  final RxMap profile = {}.obs;
  final RxList reviews = [].obs;
  final RxList followersList = [].obs;
  final RxMap reviewsSummary = {}.obs;
  final RxList notifications = [].obs;
  final RxBool isLoading = false.obs;
  final RxBool isLoadingFollowers = false.obs;
  final RxBool isSaving = false.obs;

  // ── Compat aliases for existing pages ───────────────────
  RxMap get userData => profile;
  RxString selectedAvatarUrl = ''.obs;
  RxList avatars = [].obs;
  void selectAvatar(String url) => selectedAvatarUrl.value = url;
  TextEditingController get bioController => biographyController;

  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final whatsappController = TextEditingController();
  final biographyController = TextEditingController();
  final addressController = TextEditingController();
  final cityController = TextEditingController();
  final stateController = TextEditingController();
  final countryController = TextEditingController();
  final pincodeController = TextEditingController();
  final dobController = TextEditingController();
  final experienceController = TextEditingController();
  final chatChargeController = TextEditingController();
  final voiceChargeController = TextEditingController();
  final videoChargeController = TextEditingController();
  final reportChargeController = TextEditingController();
  final dailyContributionController = TextEditingController();
  final collegeController = TextEditingController();
  final learnAstrologyFromController = TextEditingController();
  final bankAccountController = TextEditingController();
  final ifscController = TextEditingController();
  final accountHolderController = TextEditingController();
  final upiController = TextEditingController();
  final panController = TextEditingController();
  final aadharController = TextEditingController();

  final RxString selectedGender = ''.obs;
  final RxList selectedLanguages = [].obs;
  final RxList selectedSkills = [].obs;
  final RxList selectedCategories = [].obs;

  final RxList allLanguages = [].obs;
  final RxList allSkills = [].obs;
  final RxList allCategories = [].obs;

  final Rx<File?> imageFile = Rx<File?>(null);

  final _api = ApiService.instance;

  @override
  void onInit() {
    super.onInit();
    loadProfile();
  }

  @override
  void onClose() {
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    whatsappController.dispose();
    biographyController.dispose();
    addressController.dispose();
    cityController.dispose();
    stateController.dispose();
    countryController.dispose();
    pincodeController.dispose();
    dobController.dispose();
    experienceController.dispose();
    chatChargeController.dispose();
    voiceChargeController.dispose();
    videoChargeController.dispose();
    reportChargeController.dispose();
    dailyContributionController.dispose();
    collegeController.dispose();
    learnAstrologyFromController.dispose();
    bankAccountController.dispose();
    ifscController.dispose();
    accountHolderController.dispose();
    upiController.dispose();
    panController.dispose();
    aadharController.dispose();
    super.onClose();
  }

  Future<void> loadProfile() async {
    isLoading.value = true;
    await Future.wait([
      _fetchProfile(),
      _fetchReviews(),
      fetchFollowers(),
      _fetchReviewsSummary(),
      _fetchNotifications(),
      _fetchMasterData(),
    ]);
    isLoading.value = false;
  }

  Future<void> fetchFollowers() async {
    isLoadingFollowers.value = true;
    final res = await _api.get(ApiConstants.myFollowers);
    if (ApiService.isSuccess(res)) {
      final data = ApiService.getData(res);
      if (data is List) {
        followersList.value = data;
      }
    }
    isLoadingFollowers.value = false;
  }

  Future<void> _fetchProfile() async {
    final res = await _api.get(ApiConstants.profile);
    if (ApiService.isSuccess(res)) {
      final data = ApiService.getData(res) as Map<String, dynamic>?;
      if (data != null) {
        profile.value = data;
        nameController.text = data['name'] ?? data['personal_details']?['name'] ?? '';
        emailController.text = data['email'] ?? data['personal_details']?['email'] ?? '';
        final mobile = (data['mobile'] ?? data['personal_details']?['contact_no'] ?? '').toString();
        final countryCode = (data['country_code'] ?? '').toString();
        phoneController.text = mobile.isEmpty
            ? ''
            : '$countryCode $mobile'.trim();
        whatsappController.text = (data['personal_details']?['alternate_number'] ?? data['alternate_number'] ?? '').toString();
        dobController.text = (data['skill_details']?['birth_date'] ?? data['dob'] ?? '').toString();
        biographyController.text =
            data['other_details']?['long_bio'] ?? data['biography'] ?? '';
        addressController.text = data['personal_details']?['address'] ?? data['address'] ?? '';
        cityController.text =
            data['personal_details']?['city'] ?? data['city'] ?? '';
        stateController.text =
            data['personal_details']?['state'] ?? data['state'] ?? '';
        countryController.text =
            data['personal_details']?['country'] ?? data['country'] ?? '';
        pincodeController.text =
            data['personal_details']?['pincode'] ?? data['pincode'] ?? '';

        experienceController.text =
            (data['skill_details']?['experience_years'] ??
                    data['experience'] ??
                    '')
                .toString();
        chatChargeController.text =
            (data['skill_details']?['charge_per_min_inr'] ??
                    data['charge_per_min'] ??
                    '')
                .toString();
        voiceChargeController.text =
            (data['skill_details']?['voice_call_charge_per_min_inr'] ??
                    data['voice_call_charge'] ??
                    '')
                .toString();
        videoChargeController.text =
            (data['skill_details']?['video_call_charge_per_min_inr'] ??
                    data['video_call_charge'] ??
                    '')
                .toString();
        reportChargeController.text =
            (data['skill_details']?['report_charge_inr'] ??
                    data['report_charge'] ??
                    '')
                .toString();
        dailyContributionController.text =
            (data['skill_details']?['daily_contribution_hours'] ??
                    data['daily_contribution'] ??
                    '')
                .toString();

        collegeController.text =
            (data['other_details']?['college_school'] ?? data['college_school'] ?? '').toString();
        learnAstrologyFromController.text =
            (data['other_details']?['learn_astrology_from'] ?? data['learn_astrology_from'] ?? '').toString();

        bankAccountController.text = (data['bank_details']?['account_no'] ?? '').toString();
        ifscController.text = (data['bank_details']?['ifsc_code'] ?? data['bank_details']?['ifsc'] ?? '').toString();
        accountHolderController.text = (data['bank_details']?['account_holder_name'] ?? data['bank_details']?['account_holder'] ?? '').toString();
        upiController.text = (data['bank_details']?['upi_id'] ?? '').toString();
        panController.text = (data['personal_details']?['pan_no'] ?? data['bank_details']?['pan_no'] ?? data['pan_no'] ?? '').toString();
        aadharController.text = (data['personal_details']?['aadhar_no'] ?? data['aadhar_no'] ?? '').toString();

        selectedGender.value =
            (data['skill_details']?['gender'] ?? data['gender'] ?? '')
                .toString()
                .toLowerCase();
        selectedLanguages.value = List.from(
          data['skill_details']?['language'] ?? data['languages'] ?? [],
        );
        selectedSkills.value =
            (data['skill_details']?['primary_skills'] as List?)
                ?.map((s) => s is Map ? s['_id'] : s)
                .toList() ??
            [];
        selectedCategories.value =
            (data['skill_details']?['category'] as List?)
                ?.map((c) => c is Map ? c['_id'] : c)
                .toList() ??
            [];
        selectedAvatarUrl.value =
            (data['personal_details']?['profile_image'] ??
                    data['profile_pic'] ??
                    '')
                .toString();
      }
    }
  }

  String get profileImageUrl {
    final value = profile['profile_pic'] ?? profile['profilePic'] ?? '';
    return ApiConstants.resolveImage(value.toString());
  }

  Future<void> _fetchReviews() async {
    final res = await _api.get(
      ApiConstants.myReviews,
      queryParameters: {'page': 1, 'limit': 20},
    );
    if (ApiService.isSuccess(res)) {
      reviews.value = List.from(ApiService.getData(res)?['docs'] ?? []);
    }
  }

  Future<void> _fetchReviewsSummary() async {
    final res = await _api.get(ApiConstants.reviewsSummary);
    if (ApiService.isSuccess(res)) {
      reviewsSummary.value = ApiService.getData(res) ?? {};
    }
  }

  Future<void> _fetchNotifications() async {
    final res = await _api.get(
      ApiConstants.notifications,
      queryParameters: {'page': 1, 'limit': 20},
    );
    if (ApiService.isSuccess(res)) {
      notifications.value = List.from(ApiService.getData(res)?['docs'] ?? []);
    }
  }

  Future<void> updateProfile() async {
    if (nameController.text.isEmpty) {
      SnackbarUtil.error('Name is required');
      return;
    }
    isSaving.value = true;

    // Helper to sanitize IDs
    List<String> sanitizeIds(List<dynamic> selected, List<dynamic> master) {
      return selected
          .map((s) {
            final found = master.firstWhere(
              (m) => m['_id'] == s || m['name'] == s,
              orElse: () => null,
            );
            return found != null ? found['_id'].toString() : s.toString();
          })
          .where((s) => s.length == 24)
          .toList();
    }

    final Map<String, dynamic> data = {
      'name': nameController.text.trim(),
      'email': emailController.text.trim(),
      'biography': biographyController.text.trim(),
      'address': addressController.text.trim(),
      'city': cityController.text.trim(),
      'state': stateController.text.trim(),
      'country': countryController.text.trim(),
      'pincode': pincodeController.text.trim(),
      'dob': dobController.text.trim(),
      'whatsapp_no': whatsappController.text.trim(),
      'alternate_number': whatsappController.text.trim(),
      'experience': experienceController.text.trim(),
      'gender': selectedGender.value,
      'charge_per_min': chatChargeController.text.trim(),
      'voice_call_charge': voiceChargeController.text.trim(),
      'video_call_charge': videoChargeController.text.trim(),
      'report_charge': reportChargeController.text.trim(),
      'daily_contribution': dailyContributionController.text.trim(),
      'college_school': collegeController.text.trim(),
      'learn_astrology_from': learnAstrologyFromController.text.trim(),
      'pan_no': panController.text.trim(),
      'aadhar_no': aadharController.text.trim(),
      'languages': sanitizeIds(selectedLanguages, allLanguages),
      'skills': sanitizeIds(selectedSkills, allSkills),
      'categories': sanitizeIds(selectedCategories, allCategories),
      'bank_details': {
        'account_no': bankAccountController.text.trim(),
        'ifsc_code': ifscController.text.trim(),
        'account_holder_name': accountHolderController.text.trim(),
        'upi_id': upiController.text.trim(),
        'pan_no': panController.text.trim(),
      },
    };

    dynamic finalData;
    if (imageFile.value != null) {
      finalData = dio.FormData.fromMap(data);
      finalData.files.add(
        MapEntry(
          'profile_pic',
          await dio.MultipartFile.fromFile(imageFile.value!.path),
        ),
      );
    } else {
      finalData = data;
    }

    final res = await _api.put(ApiConstants.profile, data: finalData);
    isSaving.value = false;
    if (ApiService.isSuccess(res)) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(AppConstants.keyProfileComplete, true);
      await prefs.setString(
        AppConstants.keyUserName,
        nameController.text.trim(),
      );
      SnackbarUtil.success('Profile updated.');
      await _fetchProfile();
    } else {
      SnackbarUtil.error(ApiService.getMessage(res));
    }
  }

  Future<void> deleteAccount() async {
    isSaving.value = true;
    final res = await _api.delete(ApiConstants.profile);
    isSaving.value = false;
    if (ApiService.isSuccess(res)) {
      SnackbarUtil.success('Account deleted successfully.');
      await logout();
    } else {
      SnackbarUtil.error(ApiService.getMessage(res));
    }
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(AppConstants.keyToken);
    await prefs.remove(AppConstants.keyUserId);
    await prefs.remove(AppConstants.keyUserName);
    await prefs.remove(AppConstants.keyUserData);
    await prefs.remove(AppConstants.keyApprovalStatus);
    await prefs.remove(AppConstants.keyApprovalRejectionReason);
    await prefs.setBool(AppConstants.keyIsLoggedIn, false);
    await prefs.setBool(AppConstants.keyProfileComplete, false);
    Get.offAllNamed(AppRoutes.login);
  }

  void setGender(String gender) => selectedGender.value = gender;

  Future<void> _fetchMasterData() async {
    final res = await _api.get('/api/common/masters');
    if (ApiService.isSuccess(res)) {
      final data = ApiService.getData(res);
      allLanguages.value = List.from(data['languages'] ?? []);
      allSkills.value = List.from(data['skills'] ?? []);
      allCategories.value = List.from(data['categories'] ?? []);
    }
  }

  Future<void> pickImage() async {
    final file = await ImagePickerUtil.pickImage();
    if (file != null) {
      imageFile.value = file;
    }
  }

  void toggleLanguage(String lang) {
    if (selectedLanguages.contains(lang)) {
      selectedLanguages.remove(lang);
    } else {
      selectedLanguages.add(lang);
    }
  }

  void toggleSkill(String skillId) {
    if (selectedSkills.contains(skillId)) {
      selectedSkills.remove(skillId);
    } else {
      selectedSkills.add(skillId);
    }
  }

  void toggleCategory(String catId) {
    if (selectedCategories.contains(catId)) {
      selectedCategories.remove(catId);
    } else {
      selectedCategories.add(catId);
    }
  }
}
