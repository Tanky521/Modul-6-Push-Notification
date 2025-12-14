import 'package:flutter/material.dart';
import 'package:masjid_sabilillah/data/services/local_storage_service.dart';

class ThemeProvider extends ChangeNotifier {
  bool _isDarkMode = false;
  bool _isInitializing = true; // menandakan proses load awal sedang berjalan
  final LocalStorageService _storageService = LocalStorageService();

  bool get isDarkMode => _isDarkMode;
  bool get isInitializing => _isInitializing;

  ThemeProvider() {
    _loadTheme();
  }

  Future<void> _loadTheme() async {
    debugPrint('ThemeProvider: loading theme from storage');
    try {
      _isDarkMode = await _storageService.getTheme();
      debugPrint('ThemeProvider: loaded isDark=$_isDarkMode');
    } catch (e) {
      debugPrint('ThemeProvider: _loadTheme error: $e');
      _isDarkMode = false;
    }
    // tanda inisialisasi selesai dan beri tahu UI
    _isInitializing = false;
    notifyListeners();
  }

  Future<void> toggleTheme(bool isDark) async {
    _isDarkMode = isDark;
    await _storageService.saveTheme(isDark);
    notifyListeners();
  }
}
