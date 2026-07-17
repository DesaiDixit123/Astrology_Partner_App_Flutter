import 'dart:io';
import 'package:astrology_partner/config/routes/app_routes.dart';
import 'package:dio/dio.dart' as dio;
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/network/api_service.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/utils/snackbar_util.dart';
import '../../../../core/services/notification_service.dart';
import '../../../calls/presentation/controllers/partner_call_controller.dart';

class AuthController extends GetxController {
  final phoneController = TextEditingController();
  final List<TextEditingController> otpControllers = List.generate(
    6,
    (i) => TextEditingController(),
  );
  final List<FocusNode> otpFocusNodes = List.generate(6, (i) => FocusNode());

  // Registration step controllers
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final dobController = TextEditingController();
  final biographyController = TextEditingController();
  final panController = TextEditingController();
  final accountNoController = TextEditingController();
  final accountHolderController = TextEditingController();
  final ifscController = TextEditingController();
  final addressController = TextEditingController();
  final cityController = TextEditingController();
  final stateController = TextEditingController();
  final countryController = TextEditingController(text: 'India');
  final pincodeController = TextEditingController();
  final whatsappController = TextEditingController();
  final astrologerVideoController = TextEditingController();
  final aadharController = TextEditingController();

  // Bank details extensions
  final bankBranchController = TextEditingController();
  final accountTypeController = TextEditingController();
  final upiIdController = TextEditingController();

  // Other details
  final onboardReasonController = TextEditingController();
  final interviewTimeController = TextEditingController();
  final mainSourceOfBusinessController = TextEditingController();
  final highestQualificationId = ''.obs;
  final degreeDiplomaId = ''.obs;
  final collegeSchoolController = TextEditingController();
  final learnAstrologyFromController = TextEditingController();
  final instagramController = TextEditingController();
  final facebookController = TextEditingController();
  final linkedinController = TextEditingController();
  final youtubeController = TextEditingController();
  final websiteController = TextEditingController();
  final referredByController = TextEditingController();
  final minEarningController = TextEditingController(text: '0');
  final maxEarningController = TextEditingController(text: '0');
  final fullTimeJobController = TextEditingController();
  final goodQualitiesController = TextEditingController();
  final biggestChallengeController = TextEditingController();
  final customerQueryResponseController = TextEditingController();
  final videoChargeController = TextEditingController(text: '0');
  final voiceChargeController = TextEditingController(text: '0');
  final reportChargeController = TextEditingController(text: '0');
  final dailyContributionController = TextEditingController(text: '0');
  final hearAboutUsController = TextEditingController();
  final bankNameController = TextEditingController();

  final RxMap availability = {}.obs;

  final RxBool isLoading = false.obs;
  final RxString phoneNumber = ''.obs;
  final RxString serverOtp = ''.obs;
  final RxString selectedGender = ''.obs;
  final RxInt registrationStep = 0.obs;
  final RxList selectedLanguages = [].obs;
  final RxList selectedCategories = [].obs;
  final RxList selectedSkills = [].obs;
  final RxInt experience = 0.obs;
  final RxString accountType = 'saving'.obs;
  final RxString mainSourceOfBusiness = 'own_business'.obs;
  final RxBool isFullTimeJob = false.obs;
  final RxBool isWorkingOnOtherPlatform = false.obs;

  // Image handling
  final RxString profileImageUrl = ''.obs;
  final Rxn<File> profileImage = Rxn<File>();

  final RxString aadhaarImageUrl = ''.obs;
  final Rxn<File> aadhaarImage = Rxn<File>();

  final RxString panCardImageUrl = ''.obs;
  final Rxn<File> panCardImage = Rxn<File>();

  final RxString certificateImageUrl = ''.obs;
  final Rxn<File> certificateImage = Rxn<File>();

  final RxList<String> otherDocsUrls = <String>[].obs;
  final RxList<File> otherDocsImages = <File>[].obs;

  Future<void> pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 50,
    );
    if (pickedFile != null) {
      profileImage.value = File(pickedFile.path);
      await uploadImage();
    }
  }

  Future<void> uploadImage() async {
    if (profileImage.value == null) return;
    isLoading.value = true;
    try {
      final formData = dio.FormData.fromMap({
        'file': await dio.MultipartFile.fromFile(profileImage.value!.path),
      });
      final res = await _api.post(ApiConstants.upload, data: formData);
      if (ApiService.isSuccess(res)) {
        final data = ApiService.getData(res);
        profileImageUrl.value = data['full_url'] ?? '';
        SnackbarUtil.success('Profile image uploaded');
      } else {
        SnackbarUtil.error('Failed to upload profile image');
      }
    } catch (e) {
      SnackbarUtil.error('Error uploading image: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> pickAadhaarImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 50,
    );
    if (pickedFile != null) {
      aadhaarImage.value = File(pickedFile.path);
      await uploadAadhaarImage();
    }
  }

  Future<void> uploadAadhaarImage() async {
    if (aadhaarImage.value == null) return;
    isLoading.value = true;
    try {
      final formData = dio.FormData.fromMap({
        'file': await dio.MultipartFile.fromFile(aadhaarImage.value!.path),
      });
      final res = await _api.post(ApiConstants.upload, data: formData);
      if (ApiService.isSuccess(res)) {
        final data = ApiService.getData(res);
        aadhaarImageUrl.value = data['full_url'] ?? '';
        SnackbarUtil.success('Aadhaar document uploaded');
      } else {
        SnackbarUtil.error('Failed to upload Aadhaar document');
      }
    } catch (e) {
      SnackbarUtil.error('Error uploading Aadhaar: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> pickPanCardImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 50,
    );
    if (pickedFile != null) {
      panCardImage.value = File(pickedFile.path);
      await uploadPanCardImage();
    }
  }

  Future<void> uploadPanCardImage() async {
    if (panCardImage.value == null) return;
    isLoading.value = true;
    try {
      final formData = dio.FormData.fromMap({
        'file': await dio.MultipartFile.fromFile(panCardImage.value!.path),
      });
      final res = await _api.post(ApiConstants.upload, data: formData);
      if (ApiService.isSuccess(res)) {
        final data = ApiService.getData(res);
        panCardImageUrl.value = data['full_url'] ?? '';
        SnackbarUtil.success('PAN card document uploaded');
      } else {
        SnackbarUtil.error('Failed to upload PAN card');
      }
    } catch (e) {
      SnackbarUtil.error('Error uploading PAN card: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> pickCertificateImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 50,
    );
    if (pickedFile != null) {
      certificateImage.value = File(pickedFile.path);
      await uploadCertificateImage();
    }
  }

  Future<void> uploadCertificateImage() async {
    if (certificateImage.value == null) return;
    isLoading.value = true;
    try {
      final formData = dio.FormData.fromMap({
        'file': await dio.MultipartFile.fromFile(certificateImage.value!.path),
      });
      final res = await _api.post(ApiConstants.upload, data: formData);
      if (ApiService.isSuccess(res)) {
        final data = ApiService.getData(res);
        certificateImageUrl.value = data['full_url'] ?? '';
        SnackbarUtil.success('Certificate uploaded');
      } else {
        SnackbarUtil.error('Failed to upload certificate');
      }
    } catch (e) {
      SnackbarUtil.error('Error uploading certificate: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> pickOtherDocImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 50,
    );
    if (pickedFile != null) {
      final file = File(pickedFile.path);
      otherDocsImages.add(file);
      await uploadOtherDocImage(file);
    }
  }

  Future<void> uploadOtherDocImage(File file) async {
    isLoading.value = true;
    try {
      final formData = dio.FormData.fromMap({
        'file': await dio.MultipartFile.fromFile(file.path),
      });
      final res = await _api.post(ApiConstants.upload, data: formData);
      if (ApiService.isSuccess(res)) {
        final data = ApiService.getData(res);
        otherDocsUrls.add(data['full_url'] ?? '');
        SnackbarUtil.success('Document uploaded');
      } else {
        SnackbarUtil.error('Failed to upload document');
      }
    } catch (e) {
      SnackbarUtil.error('Error uploading document: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // ── Compat aliases for existing pages ───────────────────
  final experienceController = TextEditingController(text: '0');
  final priceController = TextEditingController(text: '0');
  final specializations = [].obs;
  final selectedSpecializations = [].obs;
  void toggleSpecialization(String val) => selectedSpecializations.contains(val)
      ? selectedSpecializations.remove(val)
      : selectedSpecializations.add(val);
  final languages = <Map<String, dynamic>>[].obs;
  final categories = <Map<String, dynamic>>[].obs;
  final skills = <Map<String, dynamic>>[].obs;
  final qualifications = <Map<String, dynamic>>[].obs;
  final degrees = <Map<String, dynamic>>[].obs;

  // Location States
  final countries = <Map<String, dynamic>>[].obs;
  final states = <Map<String, dynamic>>[].obs;
  final cities = <Map<String, dynamic>>[].obs;

  final selectedCountryLabel = ''.obs;
  final selectedCountryIso = ''.obs;
  final selectedStateLabel = ''.obs;
  final selectedStateIso = ''.obs;
  final selectedCityLabel = ''.obs;

  void toggleLanguage(Map<String, dynamic> val) =>
      selectedLanguages.contains(val['_id'])
      ? selectedLanguages.remove(val['_id'])
      : selectedLanguages.add(val['_id']);
  void toggleCategory(Map<String, dynamic> val) =>
      selectedCategories.contains(val['_id'])
      ? selectedCategories.remove(val['_id'])
      : selectedCategories.add(val['_id']);
  void toggleSkill(Map<String, dynamic> val) =>
      selectedSkills.contains(val['_id'])
      ? selectedSkills.remove(val['_id'])
      : selectedSkills.add(val['_id']);


  Future<void> fetchMasters() async {
    final res = await _api.get(ApiConstants.masters);
    if (ApiService.isSuccess(res)) {
      final data = ApiService.getData(res) as Map<String, dynamic>?;
      if (data != null) {
        languages.value = List<Map<String, dynamic>>.from(
          data['languages'] as List? ?? [],
        );
        categories.value = List<Map<String, dynamic>>.from(
          data['categories'] as List? ?? [],
        );
        skills.value = List<Map<String, dynamic>>.from(
          data['skills'] as List? ?? [],
        );
      }
    }

    final qRes = await _api.post(ApiConstants.qualificationsList, data: {});
    if (ApiService.isSuccess(qRes)) {
      final qData = ApiService.getData(qRes);
      qualifications.value = List<Map<String, dynamic>>.from(
        (qData is List ? qData : qData['Data'] as List?) ?? [],
      );
    }

    final dRes = await _api.post(ApiConstants.degreesList, data: {});
    if (ApiService.isSuccess(dRes)) {
      final dData = ApiService.getData(dRes);
      degrees.value = List<Map<String, dynamic>>.from(
        (dData is List ? dData : dData['Data'] as List?) ?? [],
      );
    }

    // Load countries on initialization
    fetchCountries();
  }

  Future<void> fetchCountries() async {
    final res = await _api.post(ApiConstants.countries, data: {});
    if (ApiService.isSuccess(res)) {
      final list = ApiService.getData(res);
      countries.value = List<Map<String, dynamic>>.from(list ?? []);
    }
  }

  Future<void> fetchStates(String countryIso) async {
    final res = await _api.post(ApiConstants.states, data: {'country_code': countryIso});
    if (ApiService.isSuccess(res)) {
      final list = ApiService.getData(res);
      states.value = List<Map<String, dynamic>>.from(list ?? []);
    }
  }

  Future<void> fetchCities(String countryIso, String stateIso) async {
    final res = await _api.post(ApiConstants.cities, data: {
      'country_code': countryIso,
      'state_code': stateIso,
    });
    if (ApiService.isSuccess(res)) {
      final list = ApiService.getData(res);
      cities.value = List<Map<String, dynamic>>.from(list ?? []);
    }
  }

  void handleCountryChange(Map<String, dynamic>? item) {
    if (item == null) return;
    
    final label = item['label']?.toString() ?? '';
    final iso = item['value']?.toString() ?? '';
    
    selectedCountryLabel.value = label;
    selectedCountryIso.value = iso;
    countryController.text = label;

    // Reset dependents
    selectedStateLabel.value = '';
    selectedStateIso.value = '';
    stateController.clear();
    states.clear();

    selectedCityLabel.value = '';
    cityController.clear();
    cities.clear();

    fetchStates(iso);
  }

  void handleStateChange(Map<String, dynamic>? item) {
    if (item == null) return;

    final label = item['label']?.toString() ?? '';
    final iso = item['value']?.toString() ?? '';

    selectedStateLabel.value = label;
    selectedStateIso.value = iso;
    stateController.text = label;

    // Reset dependents
    selectedCityLabel.value = '';
    cityController.clear();
    cities.clear();

    fetchCities(selectedCountryIso.value, iso);
  }

  void handleCityChange(Map<String, dynamic>? item) {
    if (item == null) return;

    final label = item['label']?.toString() ?? '';
    selectedCityLabel.value = label;
    cityController.text = label;
  }

  final _api = ApiService.instance;

  @override
  void onInit() {
    super.onInit();
    _initializeAvailability();
    fetchMasters();
  }

  void _initializeAvailability() {
    final days = [
      'sunday',
      'monday',
      'tuesday',
      'wednesday',
      'thursday',
      'friday',
      'saturday'
    ];
    for (var day in days) {
      availability[day] = {
        'is_available': true,
        'start_time': '09:00 AM',
        'end_time': '09:00 PM',
      };
    }
  }

  void toggleDayAvailability(String day, bool value) {
    if (availability.containsKey(day)) {
      final current = Map<String, dynamic>.from(availability[day]);
      current['is_available'] = value;
      availability[day] = current;
    }
  }

  @override
  void onClose() {
    phoneController.dispose();
    for (var c in otpControllers) {
      c.dispose();
    }
    for (var n in otpFocusNodes) {
      n.dispose();
    }
    nameController.dispose();
    emailController.dispose();
    dobController.dispose();
    biographyController.dispose();
    panController.dispose();
    accountNoController.dispose();
    accountHolderController.dispose();
    ifscController.dispose();
    addressController.dispose();
    cityController.dispose();
    stateController.dispose();
    pincodeController.dispose();
    whatsappController.dispose();
    astrologerVideoController.dispose();
    aadharController.dispose();
    experienceController.dispose();
    priceController.dispose();
    bankBranchController.dispose();
    onboardReasonController.dispose();
    videoChargeController.dispose();
    voiceChargeController.dispose();
    reportChargeController.dispose();
    dailyContributionController.dispose();
    hearAboutUsController.dispose();
    bankNameController.dispose();
    interviewTimeController.dispose();
    mainSourceOfBusinessController.dispose();
    collegeSchoolController.dispose();
    learnAstrologyFromController.dispose();
    instagramController.dispose();
    facebookController.dispose();
    linkedinController.dispose();
    youtubeController.dispose();
    websiteController.dispose();
    referredByController.dispose();
    minEarningController.dispose();
    maxEarningController.dispose();
    goodQualitiesController.dispose();
    biggestChallengeController.dispose();
    customerQueryResponseController.dispose();
    super.onClose();
  }

  Future<void> sendOTP({bool navigateToOtp = true}) async {
    if (phoneController.text.isEmpty || phoneController.text.length < 10) {
      SnackbarUtil.error('Please enter a valid phone number');
      return;
    }
    isLoading.value = true;
    try {
      final res = await _api.post(
        ApiConstants.sendOtp,
        data: {'mobile': phoneController.text.trim(), 'country_code': '+91'},
      );
      if (ApiService.isSuccess(res)) {
        final data = ApiService.getData(res) as Map<String, dynamic>?;
        phoneNumber.value = phoneController.text.trim();
        serverOtp.value = data?['otp']?.toString() ?? '';
        _clearOtpInputs();
        SnackbarUtil.success(ApiService.getMessage(res));
        if (navigateToOtp) {
          Get.toNamed(AppRoutes.otp);
        }
      } else {
        final message = ApiService.getMessage(res);
        // Detect account blocked
        if (message.toLowerCase().contains('block') ||
            message.toLowerCase().contains('blocked') ||
            message.toLowerCase().contains('suspended')) {
          _showAccountBlockedDialog(message);
        } else {
          SnackbarUtil.error(message);
        }
      }
    } catch (e) {
      SnackbarUtil.error('Failed to send OTP: $e');
    } finally {
      isLoading.value = false;
    }
  }

  void _showAccountBlockedDialog(String reason) {
    Get.dialog(
      _AccountBlockedDialog(reason: reason),
      barrierDismissible: false,
      barrierColor: Colors.black.withValues(alpha: 0.75),
    );
  }

  Future<void> verifyOTP() async {
    _unfocusOtpInputs();
    final otp = otpControllers.map((c) => c.text).join();
    if (otp.length < 6) {
      SnackbarUtil.error('Please enter a valid 6-digit OTP');
      return;
    }
    isLoading.value = true;
    try {
      final res = await _api.post(
        ApiConstants.verifyOtp,
        data: {'mobile': phoneNumber.value, 'otp': otp, 'country_code': '+91'},
      );
      if (ApiService.isSuccess(res)) {
        final data = ApiService.getData(res) as Map<String, dynamic>?;
        if (data != null) {
          final prefs = await SharedPreferences.getInstance();
          await prefs.clear();

          final astrologer = (data['astrologer'] as Map?)?.cast<String, dynamic>() ?? {};
          await prefs.setString(AppConstants.keyToken, data['accessToken'] ?? '');
          await prefs.setString(AppConstants.keyUserId, astrologer['_id']?.toString() ?? '');
          await prefs.setString(AppConstants.keyUserName, astrologer['name']?.toString() ?? '');
          await prefs.setBool(AppConstants.keyIsLoggedIn, true);

          final isNewUser = data['is_new_user'] == true;
          await prefs.setBool(AppConstants.keyProfileComplete, !isNewUser);

          if (isNewUser) {
            registrationStep.value = data['registration_step'] ?? 0;
            fetchMasters();
            Get.offAllNamed(AppRoutes.register);
          } else {
            _resetAuthState();
            Get.offAllNamed(AppRoutes.dashboard);
            NotificationService().syncToken();
            if (Get.isRegistered<PartnerCallController>()) {
              PartnerCallController.to.registerAfterLogin();
            }
          }
        }
      } else {
        SnackbarUtil.error(ApiService.getMessage(res));
      }
    } catch (e) {
      SnackbarUtil.error('OTP verification failed: $e');
    } finally {
      isLoading.value = false;
    }
  }

  /// Multi-step registration: validates locally
  Future<bool> registerStep(int step) async {
    if (step == 1) {
      if (selectedCategories.isEmpty) {
        SnackbarUtil.error('Please select at least one specialization');
        return false;
      }
    } else if (step == 2) {
      if (nameController.text.isEmpty || emailController.text.isEmpty) {
        SnackbarUtil.error('Name and Email are required');
        return false;
      }
    }
    return true;
  }

  /// Final registration: sends complete nested payload to Admin save API
  Future<void> register() async {
    isLoading.value = true;
    try {
      final prefs = await SharedPreferences.getInstance();
      final astrologerId = prefs.getString(AppConstants.keyUserId);

      final payload = {
        'astrologerid': astrologerId,
        'step': 4,
        'personal_details': {
          'name': nameController.text.trim(),
          'email': emailController.text.trim(),
          'contact_no': phoneController.text.trim(),
          'country': countryController.text.trim(),
          'state': stateController.text.trim(),
          'city': cityController.text.trim(),
          'address': addressController.text.trim(),
          'pincode': pincodeController.text.trim(),
          'whatsapp_no': whatsappController.text.trim().isEmpty 
              ? phoneController.text.trim() 
              : whatsappController.text.trim(),
          'aadhar_no': aadharController.text.trim(), 
          'pan_no': panController.text.trim(),
          'profile_image': profileImageUrl.value,
          'aadhar_card_img': aadhaarImageUrl.value,
          'pan_card_img': panCardImageUrl.value,
          'certificate_img': certificateImageUrl.value,
          'astrologer_video': astrologerVideoController.text.trim(),
        },
        'skill_details': {
          'gender': selectedGender.value.isEmpty ? 'Male' : selectedGender.value[0].toUpperCase() + selectedGender.value.substring(1),
          'birth_date': dobController.text.trim(),
          'category': List.from(selectedCategories),
          'primary_skills': List.from(selectedSkills),
          'all_skills': List.from(selectedSkills),
          'language': List.from(selectedLanguages),
          'charge_per_min_inr': double.tryParse(priceController.text) ?? 0,
          'video_charge_per_min_inr': double.tryParse(videoChargeController.text) ?? 0,
          'voice_charge_per_min_inr': double.tryParse(voiceChargeController.text) ?? 0,
          'report_charge_per_min_inr': double.tryParse(reportChargeController.text) ?? 0,
          'experience_years': int.tryParse(experienceController.text) ?? 0,
          'daily_contribution_hours': int.tryParse(dailyContributionController.text) ?? 0,
          'hear_about_us': hearAboutUsController.text.trim(),
          'working_on_other_platform': isWorkingOnOtherPlatform.value,
        },
        'bank_details': {
          'ifsc_code': ifscController.text.trim(),
          'bank_name': bankNameController.text.trim(),
          'bank_branch': bankBranchController.text.trim(),
          'account_type': accountType.value.isEmpty ? 'saving' : accountType.value,
          'account_no': accountNoController.text.trim(),
          'account_holder_name': accountHolderController.text.trim(),
          'upi_id': upiIdController.text.trim(),
        },
        'other_details': {
          'onboard_reason': onboardReasonController.text.trim(),
          'interview_time': interviewTimeController.text.trim(),
          'main_source_of_business': mainSourceOfBusiness.value.isEmpty ? 'own_business' : mainSourceOfBusiness.value,
          'highest_qualification': highestQualificationId.value,
          'degree_diploma': degreeDiplomaId.value,
          'college_school': collegeSchoolController.text.trim(),
          'learn_astrology_from': learnAstrologyFromController.text.trim(),
          'instagram_profile': instagramController.text.trim(),
          'facebook_profile': facebookController.text.trim(),
          'linkedin_profile': linkedinController.text.trim(),
          'youtube_profile': youtubeController.text.trim(),
          'website_profile': websiteController.text.trim(),
          'referred_by': referredByController.text.trim(),
          'min_earning_expectation': double.tryParse(minEarningController.text) ?? 0,
          'max_earning_expectation': double.tryParse(maxEarningController.text) ?? 0,
          'long_bio': biographyController.text.trim(),
          'full_time_job': isFullTimeJob.value ? 'Yes' : 'No',
          'good_qualities': goodQualitiesController.text.trim(),
          'biggest_challenge': biggestChallengeController.text.trim(),
          'customer_query_response': customerQueryResponseController.text.trim(),
          'availability': Map.from(availability),
        }
      };

      final res = await _api.post(ApiConstants.register, data: payload);
      if (ApiService.isSuccess(res)) {
        final dataRes = ApiService.getData(res) as Map<String, dynamic>?;
        await prefs.setBool(AppConstants.keyIsLoggedIn, true);
        await prefs.setBool(AppConstants.keyProfileComplete, true);
        
        final savedName = dataRes?['name']?.toString() ?? nameController.text.trim();
        if (savedName.isNotEmpty) {
          await prefs.setString(AppConstants.keyUserName, savedName);
        }
        
        SnackbarUtil.success('Registration completed successfully!');
        _resetAuthState();
        Get.offAllNamed(AppRoutes.dashboard);
        NotificationService().syncToken();
        if (Get.isRegistered<PartnerCallController>()) {
          PartnerCallController.to.registerAfterLogin();
        }
        _deleteSelf();
      } else {
        SnackbarUtil.error(ApiService.getMessage(res));
      }
    } catch (e) {
      SnackbarUtil.error('Registration failed: $e');
    } finally {
      isLoading.value = false;
    }
  }

  void setGender(String gender) => selectedGender.value = gender;

  Future<void> selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().subtract(const Duration(days: 365 * 25)),
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      dobController.text = '${picked.day}/${picked.month}/${picked.year}';
    }
  }

  void _clearOtpInputs() {
    for (final controller in otpControllers) {
      controller.clear();
    }
  }

  void _unfocusOtpInputs() {
    for (final node in otpFocusNodes) {
      if (node.hasFocus) node.unfocus();
    }
    FocusManager.instance.primaryFocus?.unfocus();
  }

  void _resetAuthState() {
    phoneController.clear();
    phoneNumber.value = '';
    serverOtp.value = '';
    _clearOtpInputs();
    nameController.clear();
    emailController.clear();
    dobController.clear();
    biographyController.clear();
    panController.clear();
    accountNoController.clear();
    accountHolderController.clear();
    ifscController.clear();
    addressController.clear();
    cityController.clear();
    stateController.clear();
    pincodeController.clear();
    whatsappController.clear();
    aadharController.clear();
    selectedGender.value = '';
    selectedLanguages.clear();
    selectedCategories.clear();
    selectedSkills.clear();
    experienceController.text = '0';
    priceController.text = '0';
    videoChargeController.text = '0';
    voiceChargeController.text = '0';
    reportChargeController.text = '0';
    dailyContributionController.text = '0';
    hearAboutUsController.clear();
    bankNameController.clear();
    registrationStep.value = 0;
    accountType.value = 'saving';
    mainSourceOfBusiness.value = 'own_business';
    isFullTimeJob.value = false;
    isWorkingOnOtherPlatform.value = false;
  }

  void _deleteSelf() {
    Future.delayed(const Duration(milliseconds: 300), () {
      if (Get.isRegistered<AuthController>()) {
        Get.delete<AuthController>(force: true);
      }
    });
  }
}

// ── Account Blocked Animated Popup ─────────────────────────────────────────
class _AccountBlockedDialog extends StatefulWidget {
  final String reason;
  const _AccountBlockedDialog({required this.reason});

  @override
  State<_AccountBlockedDialog> createState() => _AccountBlockedDialogState();
}

class _AccountBlockedDialogState extends State<_AccountBlockedDialog>
    with TickerProviderStateMixin {
  late AnimationController _shakeController;
  late AnimationController _scaleController;
  late AnimationController _pulseController;

  late Animation<double> _shakeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();

    // Scale in animation
    _scaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _scaleAnimation = CurvedAnimation(
      parent: _scaleController,
      curve: Curves.elasticOut,
    );

    // Shake animation
    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _shakeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _shakeController, curve: Curves.elasticOut),
    );

    // Pulse animation for icon
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 0.9, end: 1.1).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    // Start animations
    _scaleController.forward().then((_) => _shakeController.forward());
  }

  @override
  void dispose() {
    _shakeController.dispose();
    _scaleController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_scaleAnimation, _shakeAnimation]),
      builder: (context, child) {
        // Shake offset
        final shakeOffset = _shakeController.isAnimating
            ? 6.0 *
                (0.5 - (_shakeAnimation.value - 0.5).abs()) *
                (_shakeController.value < 0.5 ? 1 : -1)
            : 0.0;

        return Transform.translate(
          offset: Offset(shakeOffset, 0),
          child: Transform.scale(
            scale: _scaleAnimation.value,
            child: child,
          ),
        );
      },
      child: Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: EdgeInsets.symmetric(horizontal: 28.w),
        child: Container(
          padding: EdgeInsets.all(28.w),
          decoration: BoxDecoration(
            color: const Color(0xFF1A1035),
            borderRadius: BorderRadius.circular(28.r),
            border: Border.all(
              color: Colors.redAccent.withValues(alpha: 0.5),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.redAccent.withValues(alpha: 0.25),
                blurRadius: 32,
                spreadRadius: 4,
              ),
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.6),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // ── Pulsing Icon ──────────────────────────────────────
              AnimatedBuilder(
                animation: _pulseAnimation,
                builder: (_, child) => Transform.scale(
                  scale: _pulseAnimation.value,
                  child: child,
                ),
                child: Container(
                  width: 80.w,
                  height: 80.w,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.redAccent.withValues(alpha: 0.12),
                    border: Border.all(
                      color: Colors.redAccent.withValues(alpha: 0.5),
                      width: 2.w,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.redAccent.withValues(alpha: 0.3),
                        blurRadius: 20,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.block_rounded,
                    color: Colors.redAccent,
                    size: 40.sp,
                  ),
                ),
              ),

              SizedBox(height: 20.h),

              // ── Title ─────────────────────────────────────────────
              Text(
                'Account Blocked',
                style: TextStyle(
                  fontSize: 22.sp,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                  letterSpacing: 0.5,
                ),
                textAlign: TextAlign.center,
              ),

              SizedBox(height: 10.h),

              // ── Divider ───────────────────────────────────────────
              Container(
                height: 1.5.h,
                width: 60.w,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.transparent,
                      Colors.redAccent.withValues(alpha: 0.7),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),

              SizedBox(height: 14.h),

              // ── Reason from API ───────────────────────────────────
              Container(
                padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
                decoration: BoxDecoration(
                  color: Colors.redAccent.withValues(alpha: 0.07),
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(
                    color: Colors.redAccent.withValues(alpha: 0.2),
                  ),
                ),
                child: Text(
                  widget.reason.isNotEmpty
                      ? widget.reason
                      : 'Your account has been blocked.',
                  style: TextStyle(
                    fontSize: 13.5.sp,
                    color: Colors.white70,
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),

              SizedBox(height: 16.h),

              // ── Contact Admin note ────────────────────────────────
              Container(
                padding: EdgeInsets.all(14.w),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.04),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.support_agent_rounded,
                      color: const Color(0xFF9C8FFF),
                      size: 18.sp,
                    ),
                    SizedBox(width: 10.w),
                    Expanded(
                      child: Text(
                        'Please contact the admin to resolve this issue and get your account reinstated.',
                        style: TextStyle(
                          fontSize: 12.5.sp,
                          color: Colors.white54,
                          height: 1.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 24.h),

              // ── OK Button ─────────────────────────────────────────
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Get.back(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 14.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14.r),
                    ),
                    elevation: 6,
                    shadowColor: Colors.redAccent.withValues(alpha: 0.4),
                  ),
                  child: Text(
                    'OK, Got It',
                    style: TextStyle(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
