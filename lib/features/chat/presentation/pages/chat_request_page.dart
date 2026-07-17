import 'dart:ui';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/chat_request_controller.dart';
import '../../../../core/theme/app_colors.dart';

class ChatRequestPage extends GetView<ChatRequestController> {
  const ChatRequestPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (!controller.hasRequest.value) {
        return _buildEmptyState();
      }

      return Scaffold(
        body: Stack(
          children: [
            // Background - Blurred Customer Profile
            Container(
              width: double.infinity,
              height: double.infinity,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: CachedNetworkImageProvider(
                    controller.customer['profile_pic'] ??
                        'https://via.placeholder.com/150',
                  ),
                  fit: BoxFit.cover,
                ),
              ),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                child: Container(
                  color: Colors.black.withOpacity(0.75),
                ),
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

                  // Customer Avatar with Ringing Effect (simplified)
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
                              color: AppColors.primary.withOpacity(0.3),
                              width: 2,
                            ),
                          ),
                        ),
                        CircleAvatar(
                          radius: 60,
                          backgroundImage: CachedNetworkImageProvider(
                            controller.customer['profile_pic'] ??
                                'https://via.placeholder.com/150',
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

                  const Spacer(),

                  // Action Buttons
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 40, vertical: 60),
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
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.pending_actions_rounded,
              size: 80,
              color: Colors.grey.shade300,
            ),
            const SizedBox(height: 24),
            Text(
              'no_pending_requests'.tr,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Your incoming chat requests will appear here.',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade400,
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
