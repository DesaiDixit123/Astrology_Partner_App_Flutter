import 'dart:ui';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/chat_request_controller.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/constants/api_constants.dart';

class ChatRequestPage extends GetView<ChatRequestController> {
  const ChatRequestPage({super.key});

  @override
  Widget build(BuildContext context) {
    if (Get.arguments is Map && (Get.arguments as Map).isNotEmpty) {
      final argMap = Get.arguments as Map;
      final argId = argMap['session_id'] ?? (argMap['session'] is Map ? argMap['session']['_id'] : null);
      if (!controller.hasRequest.value || (argId != null && controller.sessionId != argId.toString())) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          controller.setIncomingRequest(argMap);
        });
      }
    }

    return Obx(() {
      if (!controller.hasRequest.value) {
        return _buildEmptyState();
      }

      final rawPic = controller.userPic;
      final resolvedPic = rawPic.isNotEmpty ? ApiConstants.resolveImage(rawPic) : '';

      return Scaffold(
        backgroundColor: const Color(0xFF0F172A),
        body: Stack(
          children: [
            // Background - Gradient + Optional Blurred Customer Profile
            Positioned.fill(
              child: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Color(0xFF1E293B), // Midnight slate
                      Color(0xFF0F172A), // Dark slate
                      Color(0xFF020617), // Deep dark
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
                child: resolvedPic.isNotEmpty
                    ? CachedNetworkImage(
                        imageUrl: resolvedPic,
                        fit: BoxFit.cover,
                        errorWidget: (context, url, error) => const SizedBox.shrink(),
                        imageBuilder: (context, imageProvider) => Container(
                          decoration: BoxDecoration(
                            image: DecorationImage(
                              image: imageProvider,
                              fit: BoxFit.cover,
                            ),
                          ),
                          child: BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 25, sigmaY: 25),
                            child: Container(
                              color: Colors.black.withOpacity(0.55),
                            ),
                          ),
                        ),
                      )
                    : null,
              ),
            ),

            // Content
            SafeArea(
              child: Column(
                children: [
                  const SizedBox(height: 100),

                  // Request label
                  Text(
                    'incoming_chat_request'.tr.toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 3,
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Customer Avatar with Glow Effect
                  Center(
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Container(
                          width: 140,
                          height: 140,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: AppColors.primary.withOpacity(0.4),
                              width: 2,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primary.withOpacity(0.2),
                                blurRadius: 24,
                                spreadRadius: 4,
                              ),
                            ],
                          ),
                        ),
                        CircleAvatar(
                          radius: 56,
                          backgroundColor: Colors.white12,
                          child: resolvedPic.isNotEmpty
                              ? ClipOval(
                                  child: CachedNetworkImage(
                                    imageUrl: resolvedPic,
                                    width: 112,
                                    height: 112,
                                    fit: BoxFit.cover,
                                    placeholder: (context, url) => const CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white70,
                                    ),
                                    errorWidget: (context, url, error) => const Icon(
                                      Icons.person,
                                      size: 56,
                                      color: Colors.white70,
                                    ),
                                  ),
                                )
                              : const Icon(
                                  Icons.person,
                                  size: 56,
                                  color: Colors.white70,
                                ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Customer Name
                  Text(
                    controller.userName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 8),

                  const Text(
                    'is waiting for you...',
                    style: TextStyle(
                      color: Colors.white60,
                      fontSize: 16,
                      fontStyle: FontStyle.italic,
                    ),
                  ),

                  if (controller.pricePerMinute > 0) ...[
                    const SizedBox(height: 14),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.white24),
                      ),
                      child: Text(
                        '₹${controller.pricePerMinute.toStringAsFixed(0)} / min',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],

                  const Spacer(),

                  // Action Buttons
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 60),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        // Reject Button
                        _buildAction(
                          icon: Icons.close,
                          color: Colors.redAccent,
                          label: 'cancel'.tr.toUpperCase(),
                          onTap: controller.rejectChat,
                        ),

                        // Accept Button
                        _buildAction(
                          icon: Icons.chat_bubble,
                          color: Colors.greenAccent.shade700,
                          label: 'accept'.tr.toUpperCase(),
                          onTap: controller.acceptChat,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildEmptyState() {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Text(
          'requests'.tr,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
        leading: (Get.context != null && Navigator.canPop(Get.context!))
            ? IconButton(
                icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
                onPressed: () => Get.back(),
              )
            : null,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.mark_chat_unread_outlined,
                size: 50,
                color: AppColors.primary.withOpacity(0.7),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'no_pending_requests'.tr,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Your incoming chat requests will appear here.',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAction({
    required IconData icon,
    required Color color,
    required String label,
    required VoidCallback onTap,
  }) {
    return Column(
      children: [
        GestureDetector(
          onTap: onTap,
          child: Container(
            height: 80,
            width: 80,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.4),
                  blurRadius: 20,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Icon(icon, color: Colors.white, size: 36),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.bold,
            letterSpacing: 1,
          ),
        ),
      ],
    );
  }
}
