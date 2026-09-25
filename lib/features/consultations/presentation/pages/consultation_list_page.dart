import 'package:astrology_partner/core/theme/app_colors.dart';
import 'package:astrology_partner/core/theme/app_text_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../../config/routes/app_routes.dart';
import '../controllers/consultation_controller.dart';

class ConsultationListPage extends GetView<ConsultationController> {
  const ConsultationListPage({super.key});

  // Null-safe helper to extract user name from consultation
  String _userName(Map c) {
    final u = c['user'];
    if (u is Map) return u['name'] as String? ?? 'User';
    return c['userName'] as String? ?? 'User';
  }

  String _type(Map c) => c['type'] as String? ?? 'Chat';

  String _formatDate(dynamic raw) {
    if (raw == null) return '';
    try {
      final dt = DateTime.parse(raw.toString()).toLocal();
      return '${dt.day}/${dt.month}/${dt.year}';
    } catch (_) {
      return raw.toString();
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: Text('consultations'.tr),
          bottom: TabBar(
            onTap: (index) => controller.selectedTab.value = index,
            labelColor: AppColors.primary,
            unselectedLabelColor: AppColors.textSecondary,
            indicatorColor: AppColors.primary,
            tabs: [
              Tab(text: 'pending'.tr),
              Tab(text: 'online'.tr),
              Tab(text: 'completed'.tr),
            ],
          ),
        ),
        body: Obx(() {
          if (controller.isLoading.value) {
            return const Center(child: CircularProgressIndicator());
          }

          return TabBarView(
            children: [
              _buildPendingList(),
              _buildActiveList(),
              _buildCompletedList(),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildPendingList() {
    return Obx(() {
      if (controller.pendingConsultations.isEmpty) {
        return _buildEmptyState('No pending consultations');
      }

      return RefreshIndicator(
        onRefresh: controller.loadConsultations,
        child: ListView.builder(
          padding: EdgeInsets.all(16.w),
          itemCount: controller.pendingConsultations.length,
          itemBuilder: (context, index) {
            final consultation = Map.from(
              controller.pendingConsultations[index],
            );
            return _buildPendingCard(consultation);
          },
        ),
      );
    });
  }

  Widget _buildActiveList() {
    return Obx(() {
      if (controller.activeConsultations.isEmpty) {
        return _buildEmptyState('No active consultations');
      }

      return ListView.builder(
        padding: EdgeInsets.all(16.w),
        itemCount: controller.activeConsultations.length,
        itemBuilder: (context, index) {
          final consultation = Map.from(controller.activeConsultations[index]);
          return _buildActiveCard(consultation);
        },
      );
    });
  }

  Widget _buildCompletedList() {
    return Obx(() {
      if (controller.completedConsultations.isEmpty) {
        return _buildEmptyState('No completed consultations');
      }

      return ListView.builder(
        padding: EdgeInsets.all(16.w),
        itemCount: controller.completedConsultations.length,
        itemBuilder: (context, index) {
          final consultation = Map.from(
            controller.completedConsultations[index],
          );
          return _buildCompletedCard(consultation);
        },
      );
    });
  }

  Widget _buildPendingCard(Map consultation) {
    final userName = _userName(consultation);
    final type = _type(consultation);
    final id = consultation['_id'] ?? consultation['id'] ?? '';

    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 24.r,
                backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                child: Icon(Icons.person, color: AppColors.primary),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      userName,
                      style: AppTextStyles.bodyMedium.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      '$type • ${_formatDate(consultation['createdAt'])}',
                      style: AppTextStyles.caption,
                    ),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: AppColors.warning.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(4.r),
                ),
                child: Text(
                  'Pending',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.warning,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => controller.rejectConsultation(id),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppColors.error),
                    foregroundColor: AppColors.error,
                  ),
                  child: const Text('Reject'),
                ),
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: ElevatedButton(
                  onPressed: () async {
                    await controller.acceptConsultation(id);
                    // Open chat if type is Chat
                    if (type == 'Chat') {
                      Get.toNamed(
                        AppRoutes.partnerChat,
                        arguments: consultation,
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.success,
                  ),
                  child: const Text('Accept & Chat'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActiveCard(Map consultation) {
    final userName = _userName(consultation);
    final type = _type(consultation);
    final startTime = _formatDate(
      consultation['startTime'] ?? consultation['createdAt'],
    );

    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColors.success, width: 2),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 24.r,
            backgroundColor: AppColors.success.withValues(alpha: 0.1),
            child: Icon(Icons.person, color: AppColors.success),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  userName,
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  '$type • Started $startTime',
                  style: AppTextStyles.caption,
                ),
              ],
            ),
          ),
          ElevatedButton.icon(
            onPressed: () =>
                Get.toNamed(AppRoutes.partnerChat, arguments: consultation),
            icon: const Icon(Icons.chat, size: 16),
            label: const Text('Join Chat'),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.success),
          ),
        ],
      ),
    );
  }

  Widget _buildCompletedCard(Map consultation) {
    final userName = _userName(consultation);
    final type = _type(consultation);
    final duration = consultation['duration'] ?? 0;
    final cost = consultation['cost'] ?? 0;
    final date = _formatDate(
      consultation['endTime'] ??
          consultation['updatedAt'] ??
          consultation['createdAt'],
    );

    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 24.r,
            backgroundColor: AppColors.primary.withValues(alpha: 0.1),
            child: Icon(Icons.person, color: AppColors.primary),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  userName,
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text('$type • ${duration}s', style: AppTextStyles.caption),
                Text(date, style: AppTextStyles.caption),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '₹$cost',
                style: AppTextStyles.bodyLarge.copyWith(
                  color: AppColors.accent,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text('Earned', style: AppTextStyles.caption),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.people_outline, size: 64.sp, color: AppColors.textHint),
          SizedBox(height: 16.h),
          Text(message, style: AppTextStyles.bodyMedium),
        ],
      ),
    );
  }
}
