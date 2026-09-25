import 'dart:io';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:dio/dio.dart' as dio;
import '../../../../core/network/api_service.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/utils/snackbar_util.dart';
import '../../../../core/utils/image_picker_util.dart';

class BlogController extends GetxController {
  final RxList blogs = [].obs;
  final RxBool isLoading = false.obs;
  final RxBool isSubmitting = false.obs;
  final Rx<File?> thumbnail = Rx<File?>(null);
  
  final _api = ApiService.instance;
  final _picker = ImagePicker();

  @override
  void onInit() {
    super.onInit();
    fetchMyBlogs();
  }

  Future<void> fetchMyBlogs() async {
    isLoading.value = true;
    final res = await _api.get(ApiConstants.myBlogs);
    isLoading.value = false;

    if (ApiService.isSuccess(res)) {
      final data = ApiService.getData(res);
      blogs.value = List.from(data?['docs'] ?? []);
    }
  }

  Future<void> pickThumbnail([ImageSource? source]) async {
    final selectedSource = source ?? await ImagePickerUtil.showImageSourceBottomSheet();
    if (selectedSource == null) return;
    final XFile? image = await _picker.pickImage(
      source: selectedSource,
      imageQuality: 50,
    );
    if (image != null) {
      thumbnail.value = File(image.path);
    }
  }

  Future<void> createBlog(String title, String content) async {
    if (thumbnail.value == null) {
      SnackbarUtil.error('Please select a thumbnail image');
      return;
    }
    if (title.isEmpty || content.isEmpty) {
      SnackbarUtil.error('Title and Content are required');
      return;
    }

    isSubmitting.value = true;
    try {
      // 1. Upload thumbnail
      final String fileName = thumbnail.value!.path.split('/').last;
      final dio.FormData formData = dio.FormData.fromMap({
        'file': await dio.MultipartFile.fromFile(thumbnail.value!.path, filename: fileName),
      });

      final uploadRes = await _api.post(ApiConstants.upload, data: formData);
      
      if (ApiService.isSuccess(uploadRes)) {
        final uploadData = ApiService.getData(uploadRes);
        final imageUrl = uploadData['upload_url'];

        // 2. Create blog
        final blogRes = await _api.post(ApiConstants.createBlog, data: {
          'title': title,
          'content': content,
          'image': imageUrl,
        });

        if (ApiService.isSuccess(blogRes)) {
          SnackbarUtil.success('Blog created successfully! It will be visible after admin approval.');
          thumbnail.value = null;
          fetchMyBlogs();
          Get.back();
        } else {
          SnackbarUtil.error(ApiService.getMessage(blogRes));
        }
      } else {
        SnackbarUtil.error('Failed to upload thumbnail');
      }
    } catch (e) {
      SnackbarUtil.error('Error: $e');
    } finally {
      isSubmitting.value = false;
    }
  }

  Future<void> deleteBlog(String id) async {
    final res = await _api.delete('${ApiConstants.createBlog}/$id');
    if (ApiService.isSuccess(res)) {
      SnackbarUtil.success('Blog deleted successfully');
      fetchMyBlogs();
    } else {
      SnackbarUtil.error(ApiService.getMessage(res));
    }
  }
}
