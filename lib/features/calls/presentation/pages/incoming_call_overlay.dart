import 'dart:ui';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/partner_call_controller.dart';

class IncomingCallOverlay extends GetView<PartnerCallController> {
  const IncomingCallOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    final bool isVideo = Get.arguments?['isVideo'] ?? false;
    
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          // Background - Blurred Customer Profile
          Obx(() => Container(
                width: double.infinity,
                height: double.infinity,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: CachedNetworkImageProvider(
                      controller.customer['profile_pic'] ?? 'https://via.placeholder.com/150',
                    ),
                    fit: BoxFit.cover,
                  ),
                ),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                  child: Container(
                    color: Colors.black.withOpacity(0.7),
                  ),
                ),
              )),

          // Content
          SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 80),
                
                // Calling label
                Text(
                  isVideo ? 'Incoming Video Call' : 'Incoming Voice Call',
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 16,
                    letterSpacing: 1.2,
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // Customer Name
                Obx(() => Text(
                      controller.customer['name'] ?? 'Unknown Customer',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                    )),
                
                const SizedBox(height: 40),
                
                // Customer Avatar
                Obx(() => CircleAvatar(
                      radius: 70,
                      backgroundImage: CachedNetworkImageProvider(
                        controller.customer['profile_pic'] ?? 'https://via.placeholder.com/150',
                      ),
                    )),
                
                const Spacer(),
                
                // Action Buttons (WhatsApp Style)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 60),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Reject Button
                      _buildCallAction(
                        icon: Icons.call_end,
                        color: Colors.red,
                        label: 'Decline',
                        onTap: controller.rejectCall,
                      ),
                      
                      // Accept Button
                      _buildCallAction(
                        icon: isVideo ? Icons.videocam : Icons.call,
                        color: Colors.green,
                        label: 'Accept',
                        onTap: () => controller.acceptCall(isVideo: isVideo),
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
  }

  Widget _buildCallAction({
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
            height: 75,
            width: 75,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.3),
                  blurRadius: 15,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: Icon(icon, color: Colors.white, size: 35),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          label,
          style: const TextStyle(color: Colors.white, fontSize: 14),
        ),
      ],
    );
  }
}
