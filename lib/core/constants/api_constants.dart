class ApiConstants {
  // Physical device - Use your PC's Wi-Fi IP
  static const baseUrl = 'http://192.168.1.70:8080/api';

  // Auth
  static const register = '/auth/register';
  static const me       = '/auth/me';

  // Users
  static const userProfile      = '/users/profile';
  static const userProfileImage = '/users/profile/image';

  // Properties
  static const properties       = '/properties';
  static const propertySearch   = '/properties/search';
  static const myProperties     = '/properties/my-properties';
  static const propertyFeatured = '/properties/featured';

  // Favorites
  static const favorites = '/favorites';

  // Alerts
  static const alerts = '/alerts';

  // Messages
  static const messages      = '/messages';
  static const conversations = '/messages/conversations';
  static const unreadCount   = '/messages/unread-count';

  // Visits
  static const visits = '/visits';

  static const timeout = Duration(seconds: 30);


  static String withId(String route, dynamic id) =>
      route.replaceAll(':id', '$id');
}