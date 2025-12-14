import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:masjid_sabilillah/data/services/local_storage_service.dart';

class AuthProvider extends ChangeNotifier {
  bool _isLoggedIn = false;
  bool _isInitializing = true; // baru: menandakan inisialisasi sedang berjalan
  bool _supabaseInitialized = false;
  final LocalStorageService _storageService = LocalStorageService();
  bool get isLoggedIn => _isLoggedIn;
  bool get isInitializing => _isInitializing;

  AuthProvider() {
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    // Check if user has active session in Supabase
    debugPrint('AuthProvider: starting _checkLoginStatus');
    try {
      // Ensure Supabase initialized (may have been deferred from main)
      await _initializeSupabase();
      final client = Supabase.instance.client;
      final session = client.auth.currentSession;
      _isLoggedIn = session != null;
      debugPrint('AuthProvider: currentSession=${session != null}');
    } catch (e) {
      debugPrint('AuthProvider: _checkLoginStatus error: $e');
      _isLoggedIn = false;
    } finally {
      _isInitializing = false;
      notifyListeners();
      debugPrint(
        'AuthProvider: finished _checkLoginStatus isLoggedIn=$_isLoggedIn',
      );
    }
  }

  Future<void> _initializeSupabase() async {
    if (_supabaseInitialized) return;
    // Prevent concurrent initializations
    if (_isInitializing) {
      // Wait until other init finishes
      while (_isInitializing) {
        await Future.delayed(const Duration(milliseconds: 50));
      }
      if (_supabaseInitialized) return;
    }

    _isInitializing = true;
    notifyListeners();

    try {
      debugPrint('AuthProvider: loading .env (deferred)');
      await dotenv.load(fileName: '.env');
      debugPrint('AuthProvider: .env loaded');

      debugPrint('AuthProvider: initializing Supabase (deferred)');
      await Supabase.initialize(
        url: dotenv.env['SUPABASE_URL'] ?? '',
        anonKey: dotenv.env['SUPABASE_ANON_KEY'] ?? '',
      );
      _supabaseInitialized = true;
      debugPrint('AuthProvider: Supabase initialized (deferred)');
    } catch (e) {
      debugPrint('AuthProvider: _initializeSupabase error: $e');
      rethrow;
    } finally {
      _isInitializing = false;
      notifyListeners();
    }
  }

  Future<void> register(String email, String password, String fullName) async {
    try {
      // Ensure Supabase initialized before calling its APIs
      await _initializeSupabase();
      // Register user dengan Supabase
      final client = Supabase.instance.client;
      final response = await client.auth.signUp(
        email: email,
        password: password,
        data: {'full_name': fullName},
      );

      if (response.user != null) {
        _isLoggedIn = true;
        await _storageService.saveLoginStatus(true);
        notifyListeners();
      } else {
        throw Exception('Registration failed');
      }
    } catch (e) {
      _isLoggedIn = false;
      rethrow;
    }
  }

  Future<void> login(String email, String password) async {
    try {
      // Ensure Supabase initialized before calling its APIs
      await _initializeSupabase();
      // Login dengan Supabase
      final client = Supabase.instance.client;
      final response = await client.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.user != null) {
        _isLoggedIn = true;
        await _storageService.saveLoginStatus(true);
        notifyListeners();
      } else {
        throw Exception('Login failed');
      }
    } catch (e) {
      _isLoggedIn = false;
      rethrow;
    }
  }

  Future<void> logout() async {
    try {
      // Ensure Supabase initialized before calling its APIs
      await _initializeSupabase();
      final client = Supabase.instance.client;
      await client.auth.signOut();
      _isLoggedIn = false;
      await _storageService.saveLoginStatus(false);
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }
}
