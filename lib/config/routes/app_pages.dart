import 'package:get/get.dart';
import '../../features/splash/presentation/pages/splash_page.dart';
import '../../features/splash/presentation/controllers/splash_controller.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/otp_page.dart';
import '../../features/auth/presentation/pages/register_page.dart';
import '../../features/auth/presentation/controllers/auth_controller.dart';
import '../../features/dashboard/presentation/pages/dashboard_page.dart';
import '../../features/dashboard/presentation/controllers/dashboard_controller.dart';
import '../../features/earnings/presentation/pages/withdrawal_page.dart';
import '../../features/earnings/presentation/pages/transactions_page.dart';
import '../../features/profile/presentation/pages/availability_page.dart';
import '../../features/profile/presentation/pages/bank_details_page.dart';
import '../../features/profile/presentation/pages/documents_page.dart';
import '../../features/profile/presentation/pages/reviews_page.dart';
import '../../features/profile/presentation/pages/settings_page.dart';
import '../../features/profile/presentation/pages/edit_profile_page.dart';
import '../../features/live/presentation/pages/live_dashboard_page.dart';
import '../../features/live/presentation/pages/go_live_prep_page.dart';
import '../../features/live/presentation/controllers/live_controller.dart';
import '../../features/support/presentation/pages/help_support_page.dart';
import '../../features/support/presentation/pages/about_page.dart';
import '../../features/earnings/presentation/controllers/earnings_controller.dart';
import '../../features/profile/presentation/controllers/profile_controller.dart';
import '../../features/profile/presentation/controllers/boost_controller.dart';
import '../../features/profile/presentation/pages/boost_history_page.dart';
import '../../features/home/presentation/controllers/home_controller.dart';
import '../../features/chat/presentation/pages/partner_chat_page.dart';
import '../../features/chat/presentation/pages/chat_inbox_page.dart';
import '../../features/chat/presentation/pages/blog_list_page.dart';
import '../../features/chat/presentation/pages/create_blog_page.dart';
import '../../features/chat/presentation/controllers/partner_chat_controller.dart';
import '../../features/chat/presentation/controllers/chat_inbox_controller.dart';
import '../../features/chat/presentation/controllers/blog_controller.dart';
import '../../features/chat/presentation/pages/chat_request_page.dart';
import '../../features/chat/presentation/controllers/chat_request_controller.dart';
import '../../features/calls/presentation/pages/voice_call_page.dart';
import '../../features/calls/presentation/pages/video_call_page.dart';
import '../../features/calls/presentation/pages/incoming_call_overlay.dart';
import '../../features/calls/presentation/controllers/partner_call_controller.dart';
import '../../features/profile/presentation/pages/puja_orders_list_page.dart';
import '../../features/profile/presentation/pages/puja_order_detail_page.dart';
import '../../features/profile/presentation/controllers/puja_controller.dart';
import '../../features/profile/presentation/controllers/subscription_controller.dart';
import '../../features/profile/presentation/pages/subscription_screen.dart';
import 'app_routes.dart';

class AppPages {
  static final routes = [
    GetPage(
      name: AppRoutes.splash,
      page: () => const SplashPage(),
      binding: BindingsBuilder(() {
        Get.lazyPut<SplashController>(() => SplashController());
      }),
    ),
    GetPage(
      name: AppRoutes.login,
      page: () => const LoginPage(),
      binding: BindingsBuilder(() {
        if (!Get.isRegistered<AuthController>()) {
          Get.put<AuthController>(AuthController(), permanent: true);
        }
      }),
    ),
    GetPage(
      name: AppRoutes.otp,
      page: () => const OtpPage(),
      binding: BindingsBuilder(() {
        if (!Get.isRegistered<AuthController>()) {
          Get.put<AuthController>(AuthController(), permanent: true);
        }
      }),
    ),
    GetPage(
      name: AppRoutes.register,
      page: () => RegisterPage(),
      binding: BindingsBuilder(() {
        if (!Get.isRegistered<AuthController>()) {
          Get.put<AuthController>(AuthController(), permanent: true);
        }
      }),
    ),
    GetPage(
      name: AppRoutes.dashboard,
      page: () => const DashboardPage(),
      binding: BindingsBuilder(() {
        // permanent: true ensures these controllers survive sub-route navigation
        // (e.g. SubscriptionScreen → back → dashboard won't throw 'not found')
        if (!Get.isRegistered<DashboardController>()) {
          Get.put<DashboardController>(DashboardController(), permanent: true);
        }
        if (!Get.isRegistered<HomeController>()) {
          Get.put<HomeController>(HomeController(), permanent: true);
        }
        if (!Get.isRegistered<BoostController>()) {
          Get.put<BoostController>(BoostController(), permanent: true);
        }
        if (!Get.isRegistered<LiveController>()) {
          Get.put<LiveController>(LiveController(), permanent: true);
        }
        if (!Get.isRegistered<EarningsController>()) {
          Get.put<EarningsController>(EarningsController(), permanent: true);
        }
        if (!Get.isRegistered<ProfileController>()) {
          Get.put<ProfileController>(ProfileController(), permanent: true);
        }
        if (!Get.isRegistered<ChatInboxController>()) {
          Get.put<ChatInboxController>(ChatInboxController(), permanent: true);
        }
        if (!Get.isRegistered<ChatRequestController>()) {
          Get.put<ChatRequestController>(ChatRequestController(), permanent: true);
        }
      }),
    ),
    GetPage(
      name: AppRoutes.boostHistory,
      page: () => const BoostHistoryPage(),
      binding: BindingsBuilder(() {
        if (!Get.isRegistered<BoostController>()) {
          Get.lazyPut<BoostController>(() => BoostController());
        }
      }),
    ),
    GetPage(
      name: AppRoutes.withdrawal,
      page: () => const WithdrawalPage(),
      binding: BindingsBuilder(() {
        Get.lazyPut<EarningsController>(() => EarningsController());
      }),
    ),
    GetPage(
      name: AppRoutes.transactions,
      page: () => const TransactionsPage(),
      binding: BindingsBuilder(() {
        Get.lazyPut<EarningsController>(() => EarningsController());
      }),
    ),
    GetPage(
      name: AppRoutes.availability,
      page: () => const AvailabilityPage(),
      binding: BindingsBuilder(() {
        Get.lazyPut<ProfileController>(() => ProfileController());
      }),
    ),
    GetPage(
      name: AppRoutes.bankDetails,
      page: () => const BankDetailsPage(),
      binding: BindingsBuilder(() {
        Get.lazyPut<ProfileController>(() => ProfileController());
      }),
    ),
    GetPage(
      name: AppRoutes.documents,
      page: () => const DocumentsPage(),
      binding: BindingsBuilder(() {
        Get.lazyPut<ProfileController>(() => ProfileController());
      }),
    ),
    GetPage(
      name: AppRoutes.reviews,
      page: () => const ReviewsPage(),
      binding: BindingsBuilder(() {
        Get.lazyPut<ProfileController>(() => ProfileController());
      }),
    ),
    GetPage(
      name: AppRoutes.settings,
      page: () => const SettingsPage(),
      binding: BindingsBuilder(() {
        Get.lazyPut<ProfileController>(() => ProfileController());
      }),
    ),
    GetPage(
      name: AppRoutes.editProfile,
      page: () => const EditProfilePage(),
      binding: BindingsBuilder(() {
        Get.lazyPut<ProfileController>(() => ProfileController());
      }),
    ),
    GetPage(
      name: AppRoutes.live,
      page: () => const LiveDashboardPage(),
      binding: BindingsBuilder(() {
        if (!Get.isRegistered<LiveController>()) {
          Get.lazyPut<LiveController>(() => LiveController());
        }
      }),
    ),
    GetPage(
      name: AppRoutes.goLive,
      page: () => const GoLivePrepPage(),
      binding: BindingsBuilder(() {
        if (!Get.isRegistered<LiveController>()) {
          Get.lazyPut<LiveController>(() => LiveController());
        }
      }),
    ),
    GetPage(name: AppRoutes.help, page: () => const HelpSupportPage()),
    GetPage(name: AppRoutes.about, page: () => const AboutPage()),
    GetPage(
      name: AppRoutes.partnerChat,
      page: () => const PartnerChatPage(),
      binding: BindingsBuilder(() {
        Get.lazyPut<PartnerChatController>(() => PartnerChatController());
      }),
    ),
    GetPage(
      name: AppRoutes.chatInbox,
      page: () => const ChatInboxPage(),
      binding: BindingsBuilder(() {
        Get.lazyPut<ChatInboxController>(() => ChatInboxController());
      }),
    ),
    GetPage(
      name: AppRoutes.blogs,
      page: () => const BlogListPage(),
      binding: BindingsBuilder(() {
        Get.lazyPut<BlogController>(() => BlogController());
      }),
    ),
    GetPage(
      name: AppRoutes.createBlog,
      page: () => const CreateBlogPage(),
      binding: BindingsBuilder(() {
        if (!Get.isRegistered<BlogController>()) {
          Get.lazyPut<BlogController>(() => BlogController());
        }
      }),
    ),
    GetPage(
      name: AppRoutes.voiceCall,
      page: () => const VoiceCallPage(),
      binding: BindingsBuilder(() {
        if (!Get.isRegistered<PartnerCallController>()) {
          Get.put<PartnerCallController>(
            PartnerCallController(),
            permanent: true,
          );
        }
      }),
    ),
    GetPage(
      name: AppRoutes.videoCall,
      page: () => const VideoCallPage(),
      binding: BindingsBuilder(() {
        if (!Get.isRegistered<PartnerCallController>()) {
          Get.put<PartnerCallController>(
            PartnerCallController(),
            permanent: true,
          );
        }
      }),
    ),
    GetPage(
      name: '/incoming-call',
      page: () => const IncomingCallOverlay(),
      binding: BindingsBuilder(() {
        if (!Get.isRegistered<PartnerCallController>()) {
          Get.put<PartnerCallController>(
            PartnerCallController(),
            permanent: true,
          );
        }
      }),
    ),
    GetPage(
      name: AppRoutes.chatRequest,
      page: () => const ChatRequestPage(),
      binding: BindingsBuilder(() {
        Get.lazyPut<ChatRequestController>(() => ChatRequestController());
      }),
    ),
    GetPage(
      name: AppRoutes.pujaOrders,
      page: () => const PujaOrdersListPage(),
      binding: BindingsBuilder(() {
        Get.lazyPut<PujaController>(() => PujaController());
      }),
    ),
    GetPage(
      name: AppRoutes.pujaOrderDetail,
      page: () => const PujaOrderDetailPage(),
      binding: BindingsBuilder(() {
        if (!Get.isRegistered<PujaController>()) {
          Get.lazyPut<PujaController>(() => PujaController());
        }
      }),
    ),
    GetPage(
      name: AppRoutes.subscription,
      page: () => const SubscriptionScreen(),
      binding: BindingsBuilder(() {
        Get.lazyPut<SubscriptionController>(() => SubscriptionController());
      }),
    ),
  ];
}
