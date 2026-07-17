import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:image_picker/image_picker.dart';
import 'package:get/get.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/constants/api_constants.dart';
import '../controllers/partner_chat_controller.dart';

class PartnerChatPage extends GetView<PartnerChatController> {
  const PartnerChatPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() => PopScope(
      canPop: controller.isReadOnly.value || controller.isEnded.value,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        if (controller.isReadOnly.value) {
          Navigator.pop(context);
          return;
        }
        if (!controller.isEnded.value) {
          controller.endChat();
        }
      },
      child: Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        title: Obx(() {
          final customer = controller.customer;
          final userName = customer['name'] ?? 'user'.tr;
          final userPic = customer['profile_pic']?.toString() ?? customer['profile_image']?.toString() ?? '';

          return Row(
            children: [
              CircleAvatar(
                radius: 18.r,
                backgroundColor: Colors.white,
                backgroundImage: userPic.isNotEmpty
                    ? CachedNetworkImageProvider(ApiConstants.resolveImage(userPic))
                    : null,
                child: userPic.isEmpty
                    ? const Icon(Icons.person, color: Colors.grey, size: 18)
                    : null,
              ),
              SizedBox(width: 10.w),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    userName,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    controller.isReadOnly.value ? 'chat_history'.tr : _formatSeconds(controller.chatDuration.value),
                    style: AppTextStyles.caption.copyWith(
                      color: Colors.white70,
                      fontSize: 11.sp,
                    ),
                  ),
                ],
              ),
            ],
          );
        }),
        actions: [
          if (!controller.isReadOnly.value)
          TextButton(
            onPressed: () => controller.endChat(),
            child: Text(
              'end'.tr,
              style: AppTextStyles.bodySmall.copyWith(color: Colors.white),
            ),
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        return Column(
          children: [
            Expanded(child: _buildMessageList()),
            if (!controller.isReadOnly.value) _buildInputBar(),
          ],
        );
      }),
      ),
    ));
  }

  Widget _buildMessageList() {
    return Obx(() {
      if (controller.messages.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.chat_bubble_outline,
                size: 48.sp,
                color: Colors.grey.shade300,
              ),
              SizedBox(height: 12.h),
              Text(
                'no_messages'.tr,
                style: AppTextStyles.bodySmall.copyWith(color: Colors.grey),
              ),
            ],
          ),
        );
      }

      return ListView.builder(
        controller: controller.scrollController,
        padding: EdgeInsets.all(16.w),
        itemCount: controller.messages.length + (controller.isOtherTyping.value ? 1 : 0),
        itemBuilder: (ctx, i) {
          if (i == controller.messages.length && controller.isOtherTyping.value) {
            return _buildTypingIndicator();
          }
          return _buildBubble(controller.messages[i]);
        },
      );
    });
  }

  Widget _buildTypingIndicator() {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.only(bottom: 8.h, top: 4.h),
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(16.r),
            topRight: Radius.circular(16.r),
            bottomLeft: const Radius.circular(4),
            bottomRight: Radius.circular(16.r),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Text(
          'typing'.tr,
          style: AppTextStyles.bodySmall.copyWith(
            color: Colors.black54,
            fontStyle: FontStyle.italic,
          ),
        ),
      ),
    );
  }

  Widget _buildBubble(Map msg) {
    final isMe = msg['sender_type'] == 'astrologer';
    final type = msg['message_type'] ?? 'text';
    final content = msg['text'] as String? ?? '';
    final rawImage = msg['image'] as String? ?? '';
    final imageUrl = ApiConstants.resolveImage(rawImage);
    final isImage = (type == 'image' || rawImage.isNotEmpty) && imageUrl.isNotEmpty && imageUrl.startsWith('http');
    final time = _formatTime(msg['createdAt']);

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.only(bottom: 8.h),
        constraints: BoxConstraints(maxWidth: 0.75.sw),
        padding: EdgeInsets.symmetric(horizontal: isImage ? 4.w : 14.w, vertical: isImage ? 4.h : 10.h),
        decoration: BoxDecoration(
          color: isMe ? AppColors.primary : Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(16.r),
            topRight: Radius.circular(16.r),
            bottomLeft: isMe ? Radius.circular(16.r) : const Radius.circular(4),
            bottomRight: isMe ? const Radius.circular(4) : Radius.circular(16.r),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            if (isImage)
              ClipRRect(
                borderRadius: BorderRadius.circular(12.r),
                child: CachedNetworkImage(
                  imageUrl: imageUrl,
                  width: 200.w,
                  placeholder: (context, url) => Container(
                    height: 150.h,
                    width: 200.w,
                    color: Colors.grey.shade200,
                    child: const Center(child: CircularProgressIndicator()),
                  ),
                  errorWidget: (context, url, error) => Container(
                    height: 150.h,
                    width: 200.w,
                    color: Colors.grey.shade200,
                    child: const Icon(Icons.broken_image, color: Colors.grey),
                  ),
                  fit: BoxFit.cover,
                ),
              )
            else if (type == 'image')
              ClipRRect(
                borderRadius: BorderRadius.circular(12.r),
                child: Container(
                  height: 150.h,
                  width: 200.w,
                  color: Colors.grey.shade200,
                  child: const Icon(Icons.broken_image, color: Colors.grey),
                ),
              )
            else
              Text(
                content,
                style: AppTextStyles.bodySmall.copyWith(
                  color: isMe ? Colors.white : Colors.black87,
                ),
              ),
            SizedBox(height: 4.h),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: type == 'image' ? 8.w : 0),
              child: Text(
                time,
                style: AppTextStyles.caption.copyWith(
                  fontSize: 10.sp,
                  color: isMe ? Colors.white60 : Colors.grey,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputBar() {
    if (controller.isEnded.value) return const SizedBox.shrink();

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            IconButton(
              icon: Icon(Icons.add_photo_alternate_outlined, color: AppColors.primary),
              onPressed: () => _showAttachmentOptions(Get.context!),
            ),
            Expanded(
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(24.r),
                ),
                child: TextField(
                  controller: controller.msgController,
                  decoration: InputDecoration(
                    hintText: 'type_reply'.tr,
                    border: InputBorder.none,
                    hintStyle: AppTextStyles.bodySmall.copyWith(color: Colors.grey),
                  ),
                  maxLines: null,
                  textCapitalization: TextCapitalization.sentences,
                  onChanged: controller.onMessageChanged,
                  onSubmitted: (_) {
                    if (controller.msgController.text.trim().isNotEmpty) {
                      controller.sendMessage(controller.msgController.text.trim());
                      controller.msgController.clear();
                    }
                  },
                ),
              ),
            ),
            SizedBox(width: 8.w),
            GestureDetector(
              onTap: () {
                if (controller.msgController.text.trim().isNotEmpty) {
                  controller.sendMessage(controller.msgController.text.trim());
                  controller.msgController.clear();
                }
              },
              child: Obx(() => Container(
                width: 44.w,
                height: 44.h,
                decoration: BoxDecoration(
                  color: (controller.isSending.value || controller.isUploading.value) ? Colors.grey : AppColors.primary,
                  shape: BoxShape.circle,
                ),
                child: (controller.isSending.value || controller.isUploading.value)
                    ? const Padding(
                        padding: EdgeInsets.all(10),
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.send, color: Colors.white, size: 20),
              )),
            ),
          ],
        ),
      ),
    );
  }

  void _showAttachmentOptions(BuildContext context) {
    Get.bottomSheet(
      Container(
        padding: EdgeInsets.all(20.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('send_image'.tr, style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.bold)),
            SizedBox(height: 20.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _attachmentItem(
                  icon: Icons.camera_alt,
                  label: 'camera'.tr,
                  onTap: () {
                    Get.back();
                    controller.pickAndSendImage(ImageSource.camera);
                  },
                ),
                _attachmentItem(
                  icon: Icons.photo_library,
                  label: 'gallery'.tr,
                  onTap: () {
                    Get.back();
                    controller.pickAndSendImage(ImageSource.gallery);
                  },
                ),
              ],
            ),
            SizedBox(height: 20.h),
          ],
        ),
      ),
    );
  }

  Widget _attachmentItem({required IconData icon, required String label, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: AppColors.primary, size: 28.sp),
          ),
          SizedBox(height: 8.h),
          Text(label, style: AppTextStyles.bodySmall),
        ],
      ),
    );
  }

  String _formatTime(dynamic raw) {
    if (raw == null) return '';
    try {
      final dt = DateTime.parse(raw.toString()).toLocal();
      return '${dt.hour}:${dt.minute.toString().padLeft(2, '0')}';
    } catch (_) {
      return '';
    }
  }

  String _formatSeconds(int s) {
    int m = s ~/ 60;
    int sec = s % 60;
    return '${m.toString().padLeft(2, '0')}:${sec.toString().padLeft(2, '0')}';
  }
}
