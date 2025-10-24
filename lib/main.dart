import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'core/constants/app_themes.dart';
import 'core/constants/app_constants.dart';
import 'core/services/shared_preferences_service.dart';
import 'core/services/navigation_service.dart';
import 'features/home/viewmodels/home_viewmodel.dart';
import 'viewmodels/onboarding_viewmodel.dart';
import 'features/auth/viewmodels/auth_viewmodel.dart';
import 'features/course/viewmodels/course_viewmodel.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();  
  
  // Tùy chỉnh status bar cho đẹp
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent, // Làm trong suốt
      statusBarIconBrightness: Brightness.dark, // Icon màu tối
      statusBarBrightness: Brightness.light, // Cho iOS
      systemNavigationBarColor: Colors.white, // Navigation bar
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );
  
  await SharedPreferencesService.init();
  runApp(const MyApp());
}

class AuthInitializer extends StatefulWidget {
  final Widget child;
  
  const AuthInitializer({super.key, required this.child});

  @override
  State<AuthInitializer> createState() => _AuthInitializerState();
}

class _AuthInitializerState extends State<AuthInitializer> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeAuth();
    });
  }

  Future<void> _initializeAuth() async {
    final authViewModel = Provider.of<AuthViewModel>(context, listen: false);
    await authViewModel.checkAuthStatus();
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => HomeViewModel()),
        ChangeNotifierProvider(create: (_) => OnboardingViewModel()),
        ChangeNotifierProvider(create: (_) => AuthViewModel()),
        ChangeNotifierProvider(create: (_) => CourseViewModel()),
      ],
      child: AuthInitializer(
        child: MaterialApp.router(
          title: AppConstants.appName,
          theme: AppThemes.lightTheme,
          darkTheme: AppThemes.darkTheme,
          themeMode: ThemeMode.system,
          debugShowCheckedModeBanner: false,
          routerConfig: AppRouter.router,
        ),
      ),
    );
  }
}

