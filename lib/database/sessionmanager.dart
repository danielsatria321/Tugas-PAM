import 'package:shared_preferences/shared_preferences.dart';

class SessionManager {
  static const String _sessionKey = 'user_session';
  static const String _usernameKey = 'username';
  static const String _userIdKey = 'user_id';

  // Cek apakah user sudah login
  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_sessionKey) ?? false;
  }

  // Simpan session login
  static Future<void> saveSession(int userId, String username) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_sessionKey, true);
    await prefs.setString(_usernameKey, username);
    await prefs.setInt(_userIdKey, userId);
  }

  // Hapus session (logout)
  static Future<void> clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_sessionKey);
    await prefs.remove(_usernameKey);
    await prefs.remove(_userIdKey);
  }

  // Dapatkan user ID dari session
  static Future<int?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_userIdKey);
  }

  // Dapatkan username dari session
  static Future<String?> getUsername() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_usernameKey);
  }

  // Dapatkan semua data session
  static Future<Map<String, dynamic>> getSessionData() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'isLoggedIn': prefs.getBool(_sessionKey) ?? false,
      'userId': prefs.getInt(_userIdKey),
      'username': prefs.getString(_usernameKey),
    };
  }
}
