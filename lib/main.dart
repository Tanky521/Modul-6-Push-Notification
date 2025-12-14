// lib/main.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:get/get.dart';
import 'package:masjid_sabilillah/core/constants/app_colors.dart';
import 'package:masjid_sabilillah/core/providers/theme_provider.dart';
import 'package:masjid_sabilillah/core/providers/auth_provider.dart';
import 'package:masjid_sabilillah/data/services/notification_service.dart';
import 'package:masjid_sabilillah/presentation/screens/home_screen.dart';
import 'package:masjid_sabilillah/presentation/screens/prayer_times_screen.dart';
import 'package:masjid_sabilillah/presentation/screens/settings_screen.dart';
import 'package:masjid_sabilillah/presentation/screens/login_screen.dart';
import 'package:masjid_sabilillah/presentation/screens/register_screen.dart';
import 'package:masjid_sabilillah/presentation/screens/pengumuman_screen.dart';
import 'package:masjid_sabilillah/presentation/screens/notification_history_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  debugPrint('main: start initialization');

  // Initialize Firebase
  try {
    await Firebase.initializeApp();
    debugPrint('main: Firebase initialized');
  } catch (e) {
    debugPrint('main: Firebase initialization error: $e');
    debugPrint('main: Note: Make sure google-services.json is in android/app/');
  }

  // Initialize Notification Service
  try {
    await NotificationService.instance.initialize();
    debugPrint('main: NotificationService initialized');
  } catch (e) {
    debugPrint('main: NotificationService initialization error: $e');
  }

  // Load environment variables

  // Initialize Supabase
  // Do NOT perform long async initialization (dotenv / Supabase) here before runApp.
  // Move initialization into a provider (AuthProvider) so the first Flutter frame
  // can be rendered quickly and we can show a loading UI while services initialize.
  debugPrint('main: starting app (deferred Supabase/dotenv init to provider)');

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

GoRouter _createRouter(bool isLoggedIn) {
  return GoRouter(
    initialLocation: isLoggedIn ? '/' : '/login',
    routes: [
      GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(path: '/', builder: (context, state) => const HomeScreen()),
      GoRoute(
        path: '/jadwal',
        builder: (context, state) => const PrayerTimesScreen(),
      ),
      GoRoute(
        path: '/lokasi',
        builder: (context, state) => const LokasiScreen(),
      ),
      GoRoute(
        path: '/donasi',
        builder: (context, state) => const DonasiScreen(),
      ),
      GoRoute(
        path: '/pengumuman',
        builder: (context, state) => const PengumumanScreen(),
      ),
      GoRoute(
        path: '/notifikasi',
        builder: (context, state) => const NotificationHistoryScreen(),
      ),
      GoRoute(
        path: '/pengaturan',
        builder: (context, state) => const SettingsScreen(),
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      appBar: AppBar(title: const Text('Error')),
      body: Center(child: Text('Route tidak ditemukan: ${state.uri}')),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  ThemeData _buildLightTheme() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: ColorScheme.light(
        primary: AppColors.lightPrimary,
        onPrimary: AppColors.lightTextOnPrimary,
        background: AppColors.lightBackground,
        surface: AppColors.lightSurface,
        onBackground: AppColors.lightTextPrimary,
      ),
      scaffoldBackgroundColor: AppColors.lightBackground,
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.lightPrimary,
        foregroundColor: AppColors.lightTextOnPrimary,
      ),
    );
  }

  ThemeData _buildDarkTheme() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.dark(
        primary: AppColors.darkPrimary,
        onPrimary: AppColors.lightTextOnPrimary,
        background: AppColors.darkBackground,
        surface: AppColors.darkSurface,
        onBackground: AppColors.darkTextPrimary,
      ),
      scaffoldBackgroundColor: AppColors.darkBackground,
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.darkSurface,
        foregroundColor: AppColors.lightTextOnPrimary,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<ThemeProvider, AuthProvider>(
      builder: (context, themeProvider, authProvider, child) {
        final isInitializing =
            themeProvider.isInitializing || authProvider.isInitializing;

        if (isInitializing) {
          // Tampilkan loading sederhana selama provider inisialisasi
          return MaterialApp(
            title: 'Masjid Sabilillah',
            debugShowCheckedModeBanner: false,
            theme: _buildLightTheme(),
            darkTheme: _buildDarkTheme(),
            themeMode: themeProvider.isDarkMode
                ? ThemeMode.dark
                : ThemeMode.light,
            home: const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            ),
          );
        }

        return MaterialApp.router(
          routerConfig: _createRouter(authProvider.isLoggedIn),
          title: 'Masjid Sabilillah',
          debugShowCheckedModeBanner: false,
          theme: _buildLightTheme(),
          darkTheme: _buildDarkTheme(),
          themeMode: themeProvider.isDarkMode
              ? ThemeMode.dark
              : ThemeMode.light,
        );
      },
    );
  }
}

// Placeholder screens
class DonasiScreen extends StatelessWidget {
  const DonasiScreen({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Donasi')),
    body: const Center(child: Text('Donasi')),
  );
}


class LokasiScreen extends StatelessWidget {
  const LokasiScreen({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Lokasi Masjid')),
    body: const Center(child: Text('Lokasi')),
  );
}
