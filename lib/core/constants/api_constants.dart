class ApiConstants {
  // ── Base URL ───────────────────────────────────────────────
  static String baseUrl = 'https://api.vedikvani.com';
  // static String baseUrl = 'http://192.168.29.74:3050';

  static void updateBaseUrl(String url) {
    var cleaned = url.trim();
    while (cleaned.endsWith('/')) {
      cleaned = cleaned.substring(0, cleaned.length - 1);
    }
    if (cleaned.startsWith('http')) {
      baseUrl = cleaned;
    } else {
      baseUrl = 'http://$cleaned:3050';
    }
  }

  // ── Image Base URL (Dynamically Resolves to Local Backend or CDN) ──
  static String get imageBaseUrl => baseUrl;

  static String resolveImage(String path) {
    if (path.isEmpty) return '';

    // Clean nested/concatenated URLs if present
    if (path.contains('/http://') || path.contains('/https://')) {
      final idx = path.indexOf('http', 1);
      if (idx != -1) {
        path = path.substring(idx);
      }
    }

    if (path.startsWith('http://api.vedikvani.com')) {
      path = path.replaceFirst('http://api.vedikvani.com', 'https://api.vedikvani.com');
    }

    // Since the AWS S3 bucket hrms-khushi is private (403),
    // all S3 assets are mirrored in the local backend's /Common/ or /public/ directory.
    if (path.contains('hrms-khushi.s3.ap-south-1.amazonaws.com')) {
      path = path.replaceAll('https://hrms-khushi.s3.ap-south-1.amazonaws.com', baseUrl);
    }

    // Replace localhost or 127.0.0.1 with actual phone-reachable baseUrl host
    if (path.contains('localhost') || path.contains('127.0.0.1')) {
      final uri = Uri.tryParse(baseUrl);
      if (uri != null) {
        path = path.replaceAll('https://localhost:3050', baseUrl)
                   .replaceAll('http://localhost:3050', baseUrl)
                   .replaceAll('https://localhost', 'http://${uri.host}:${uri.port}')
                   .replaceAll('http://localhost', 'http://${uri.host}:${uri.port}')
                   .replaceAll('localhost', uri.host)
                   .replaceAll('127.0.0.1', uri.host);
      }
    }

    if (path.startsWith('http')) {
      return path;
    }
    final cleanPath = path.startsWith('/') ? path.substring(1) : path;
    return '$baseUrl/$cleanPath';
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
  static const String razorpayKeyId = 'rzp_live_TizoH6DpiW0jl7';

  // ── App Version & Force Update ─────────────────────────────
  static const String appVersionCheck = '/partner/app-version/check';
}
