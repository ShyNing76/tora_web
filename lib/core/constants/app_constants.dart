class AppConstants {
  // App Info
  static const String appName = 'Tora';
  static const String appVersion = '1.0.0';
  static const String websiteUrl = 'https://tora.aizy.vn';

  // API Configuration
  static const String baseUrl = 'https://torabe.aizy.vn'; 
  static const String apiTimeout = '30';
  
  // API Identity Endpoints
  static const String prefixIdentity = '/identity/api';
  static const String authLogin = '$prefixIdentity/User/login';
  static const String authRegister = '$prefixIdentity/User/register';
  static const String authLogout = '$prefixIdentity/User/logout';
  static const String authMe = '$prefixIdentity/User/me';
  static const String authRefresh = '$prefixIdentity/User/refresh-token';

  // API APP Endpoints
  static const String prefixApp = '/app/api';
  static const String getCourses = '$prefixApp/Course';

  // Storage Keys
  static const String userTokenKey = 'user_token';
  static const String userIdKey = 'user_id';
  static const String themeKey = 'theme_mode';
  
  // UI Constants
  static const double defaultPadding = 16.0;
  static const double smallPadding = 8.0;
  static const double largePadding = 24.0;
  
  // Animation Durations
  static const int animationDuration = 300;
  static const int splashDuration = 2000;
}