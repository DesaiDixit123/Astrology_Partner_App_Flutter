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
  final biographyController = TextEditingController();
  final addressController = TextEditingController();
  final cityController = TextEditingController();
  final experienceController = TextEditingController();
  final RxString selectedGender = ''.obs;
  final RxList selectedLanguages = [].obs;
  final RxList selectedSkills = [].obs;
  final RxList selectedCategories = [].obs;

  final RxList allLanguages = [].obs;
  final RxList allSkills = [].obs;
  final RxList allCategories = [].obs;

  final Rx<File?> imageFile = Rx<File?>(null);
  final ImagePicker _picker = ImagePicker();

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
    biographyController.dispose();
    addressController.dispose();
    cityController.dispose();
    experienceController.dispose();
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
        nameController.text = data['name'] ?? '';
        emailController.text = data['email'] ?? '';
        final mobile = (data['mobile'] ?? '').toString();
        final countryCode = (data['country_code'] ?? '').toString();
        phoneController.text = mobile.isEmpty
            ? ''
            : '$countryCode $mobile'.trim();
        biographyController.text =
            data['other_details']?['long_bio'] ?? data['biography'] ?? '';
        addressController.text = data['address'] ?? '';
        cityController.text =
            data['personal_details']?['city'] ?? data['city'] ?? '';
        experienceController.text =
            (data['skill_details']?['experience_years'] ??
                    data['experience'] ??
                    '')
                .toString();
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
      'experience': experienceController.text.trim(),
      'gender': selectedGender.value,
      'languages': sanitizeIds(selectedLanguages, allLanguages),
      'skills': sanitizeIds(selectedSkills, allSkills),
      'categories': sanitizeIds(selectedCategories, allCategories),
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
    final XFile? image = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 50,
    );
    if (image != null) {
      imageFile.value = File(image.path);
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
