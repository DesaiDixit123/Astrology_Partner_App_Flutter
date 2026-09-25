class ApiConstants {
  // ── Base URL ───────────────────────────────────────────────
  //static String baseUrl = 'http://192.168.1.10:3050';
  //static String baseUrl = 'http://192.168.1.6:3050';
  static String baseUrl = 'https://api.vedikvani.com/';

  static void updateBaseUrl(String url) {
    if (url.startsWith('http')) {
      baseUrl = url;
    } else {
      baseUrl = 'http://$url:3050';
    }
  }

  static const String imageBaseUrl =
      'https://hrms-khushi.s3.ap-south-1.amazonaws.com';

  static String resolveImage(String path) {
    if (path.isEmpty) return '';
    if (path.startsWith('http')) return path;
    return '$imageBaseUrl/$path'
        .replaceAll('//', '/')
        .replaceFirst('https:/', 'https://');
  }

  // ── Partner Auth ──────────────────────────────────────────
  static const String sendOtp = '/partner/send-otp';
  static const String verifyOtp = '/partner/verify-otp';
  static const String register = '/partner/register';
  static const String astrologerSave = '/admin/astrologer/save';

  // ── Dashboard ────────────────────────────────────────────
  static const String dashboard = '/partner/dashboard';
  static const String updateStatus = '/partner/status';
  static const String queue = '/partner/queue';

  // ── Earnings & Wallet ────────────────────────────────────
  static const String earnings = '/partner/earnings';
  static const String wallet = '/partner/wallet';
  static const String requestWithdrawal = '/partner/wallet/withdraw';
  static const String withdrawalHistory = '/partner/wallet/withdrawals';

  // ── Service Orders ───────────────────────────────────────
  static const String serviceOrders = '/partner/service-orders';
  static const String pujaOrders = '/partner/puja-orders';

  // ── My Services ──────────────────────────────────────────
  static const String myServices = '/partner/services';
  static const String assignService = '/partner/services/assign';

  // ── Blogs ─────────────────────────────────────────────────
  static const String createBlog = '/partner/blog';
  static const String myBlogs = '/partner/blogs';

  // ── Boost ──────────────────────────────────────────────────
  static const String boostCheckEligibility =
      '/partner/boost/check-eligibility';
  static const String boostApply = '/partner/boost/apply';
  static const String boostHistory = '/partner/boost/history';

  // ── Live Streaming ────────────────────────────────────────
  static const String startLive = '/partner/live/start';
  static const String endLive = '/partner/live/end';
  static const String liveRequests = '/partner/live/requests';

  // ── Profile ───────────────────────────────────────────────
  static const String profile = '/partner/profile';
  static const String myReviews = '/partner/reviews';
  static const String myFollowers = '/partner/followers';
  static const String reviewsSummary = '/partner/reviews-summary';
  static const String notifications = '/partner/notifications';

  // ── Predictions ───────────────────────────────────────────
  static const String horoscope = '/partner/horoscope';
  static const String panchang = '/partner/panchang';
  static const String kundli = '/partner/kundli';

  // ── Common ────────────────────────────────────────────────
  static const String faqs = '/api/common/faqs';
  static const String terms = '/api/common/terms';
  static const String upload = '/api/common/upload';
  static const String masters = '/api/common/masters';
  static const String languagesList = '/api/common/languages';
  static const String skillsList = '/api/common/skills';
  static const String categoriesList = '/api/common/categories';
  static const String qualificationsList = '/admin/qualifications/list/withoutpagination';
  static const String degreesList = '/admin/degrees/list/withoutpagination';
  static const String countries = '/admin/location/countries';
  static const String states = '/admin/location/states';
  static const String cities = '/admin/location/cities';

  // ── Calls ────────────────────────────────────────────────
  static const String partnerEndCall = '/partner/call/end';

  // ── Subscriptions ──────────────────────────────────────────
  static const String subscriptionActive = '/partner/subscription/active';
  static const String subscriptionPackages = '/partner/subscription/packages';
  static const String subscriptionPurchase = '/partner/subscription/purchase';
  static const String subscriptionCreateOrder = '/partner/subscription/create-order';

  // ── Razorpay ────────────────────────────────────────────────
  // Test Key from backend .env (switch to live key for production)
  static const String razorpayKeyId = 'rzp_live_T690exIdAcKXHs';
}
