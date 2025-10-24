class AppRoutes {
  // Auth Routes
  static const String splash = '/splash';
  static const String login = '/login';
  static const String signup = '/signup';
  
  // Main App Routes (with shell)
  static const String home = '/home';
  static const String courses = '/courses';
  static const String progress = '/progress';
  static const String exams = '/exams';
  static const String profile = '/profile';
  
  // Nested Routes
  static const String settings = '/profile/settings';
  
  // Helper method to get route name
  static String getRouteName(String path) {
    switch (path) {
      case splash:
        return 'splash';
      case login:
        return 'login';
      case signup:
        return 'signup';
      case home:
        return 'home';
      case courses:
        return 'courses';
      case progress:
        return 'progress';
      case exams:
        return 'exams';
      case profile:
        return 'profile';
      case settings:
        return 'settings';
      default:
        return 'unknown';
    }
  }
}