class ApiConstants {
  // ── Base URL ─────────────────────────────────────────────────────────────
  // Physical device: use your PC's Wi-Fi IP
  // Emulator: use 10.0.2.2 instead of localhost
  static const baseUrl = 'http://10.0.116.12:8080/api';

  // ── Auth ─────────────────────────────────────────────────────────────────
  static const register      = '/auth/register';       // POST (email/password direct - for testing)
  static const login         = '/auth/login';          // POST (for testing only)
  static const firebaseToken = '/auth/firebase-token'; // POST ?token=<firebase_id_token>
  static const me            = '/auth/me';             // GET

  // ── Users ─────────────────────────────────────────────────────────────────
  static const userProfile      = '/users/profile';        // GET / PUT
  static const userProfileImage = '/users/profile/image';  // POST multipart
  static String userById(int id) => '/users/$id';          // GET

  // ── Properties ───────────────────────────────────────────────────────────
  static const properties       = '/properties';
  static const propertySearch   = '/properties/search';
  static const myProperties     = '/properties/my-properties';
  static const propertyFeatured = '/properties/featured';
  static const propertyNearby   = '/properties/nearby';
  static String propertyById(int id)     => '/properties/$id';
  static String propertyImages(int id)   => '/properties/$id/images';

  // ── Favorites ─────────────────────────────────────────────────────────────
  static const favorites              = '/favorites';          // GET / POST
  static String favoriteById(int id)  => '/favorites/$id';    // DELETE
  static String favoriteCheck(int id) => '/favorites/check/$id'; // GET

  // ── Alerts ────────────────────────────────────────────────────────────────
  static const alerts                    = '/alerts';
  static String alertById(int id)        => '/alerts/$id';
  static String alertToggle(int id)      => '/alerts/$id/toggle';

  // ── Messages ──────────────────────────────────────────────────────────────
  static const messages      = '/messages';
  static const conversations = '/messages/conversations';
  static const unreadCount   = '/messages/unread-count';
  static String conversation(int userId) => '/messages/conversation/$userId';
  static String markRead(int msgId)      => '/messages/$msgId/read';

  // ── Visits ────────────────────────────────────────────────────────────────
  static const visits                        = '/visits';
  static String visitById(int id)            => '/visits/$id';
  static String visitsByProperty(int propId) => '/visits/property/$propId';
  static String visitStatus(int id)          => '/visits/$id/status';
  static String visitCancel(int id)          => '/visits/$id/cancel';

  // ── Timeout ───────────────────────────────────────────────────────────────
  static const timeout = Duration(seconds: 30);
}