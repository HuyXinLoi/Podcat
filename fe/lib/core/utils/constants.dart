class ApiConstants {
  static const String baseUrl = 'https://podcat-4.onrender.com/api';

  // Auth endpoints
  static const String login = '/auth/login';
  static const String register = '/auth/register';

  // Podcast endpoints
  static const String podcasts = '/podcasts';
  static const String search = '/podcasts/search';
  static const String podcastsByCategory = '/podcasts/category';

  // Category endpoints
  static const String categories = '/categories';

  // User endpoints
  static const String userProfile = '/users/me';

  // Playlist endpoints
  static const String playlists = '/playlists';
  static const String myPlaylists = '/playlists/my';

  // Favorite endpoints
  static const String favorites = '/favorites';

  // History endpoints
  static const String history = '/history';

  // Comment endpoints
  static const String comments = '/comments';
}

class StorageConstants {
  static const String token = 'token';
  static const String userId = 'userId';
  static const String username = 'username';
  static const String language = 'language';
}

class ResponsiveBreakpoints {
  static const double mobileMax = 600;
  static const double tabletMax = 900;
  static const double desktopMin = 901;
}
