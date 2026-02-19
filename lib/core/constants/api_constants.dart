class ApiConstants {
  // ── Base URL ─────────────────────────────────────────────────────────────
  static const baseUrl = 'http://10.0.116.12:8080/api';

  // ── Auth ─────────────────────────────────────────────────────────────────
  static const register      = '/auth/register';
  static const login         = '/auth/login';
  static const firebaseToken = '/auth/firebase-token';
  static const me            = '/auth/me';

  // ── Users ─────────────────────────────────────────────────────────────────
  static const userProfile      = '/users/profile';
  static const userProfileImage = '/users/profile/image';
  static String userById(int id) => '/users/$id';

  // ── Properties ───────────────────────────────────────────────────────────
  static const properties       = '/properties';
  static const propertySearch   = '/properties/search';
  static const myProperties     = '/properties/my-properties';
  static const propertyFeatured = '/properties/featured';
  static const propertyNearby   = '/properties/nearby';
  static String propertyById(int id)   => '/properties/$id';
  static String propertyImages(int id) => '/properties/$id/images';

  // ── Favorites ─────────────────────────────────────────────────────────────
  static const favorites             = '/favorites';
  static String favoriteById(int id) => '/favorites/$id';
  static String favoriteCheck(int id) => '/favorites/check/$id';

  // ── Alerts ────────────────────────────────────────────────────────────────
  static const alerts               = '/alerts';
  static String alertById(int id)   => '/alerts/$id';
  static String alertToggle(int id) => '/alerts/$id/toggle';

  // ── Messages ──────────────────────────────────────────────────────────────
  static const messages      = '/messages';
  static const conversations = '/messages/conversations';
  static const unreadCount   = '/messages/unread-count';

  // GET /messages/conversation/{otherUserId}  (with optional ?propertyId=)
  static String conversation(int otherUserId) =>
      '/messages/conversation/$otherUserId';

  // PATCH /messages/{messageId}/read
  static String markRead(int msgId) => '/messages/$msgId/read';

  // ── Visits ────────────────────────────────────────────────────────────────
  static const visits = '/visits';
  static String visitById(int id)            => '/visits/$id';
  static String visitsByProperty(int propId) => '/visits/property/$propId';

  // PATCH /visits/{id}/status
  static String visitStatus(int id) => '/visits/$id/status';

  // POST /visits/{id}/cancel
  static String visitCancel(int id) => '/visits/$id/cancel';

  // ── Timeout ───────────────────────────────────────────────────────────────
  static const timeout = Duration(seconds: 30);
}