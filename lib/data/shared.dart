import 'package:my_personal_lib_app/services/constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SecurityStorage {
  /// Remove credenciais (e opcionalmente preferências de notificação)
  static Future<void> clearData({bool alsoNotificationPrefs = false}) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(tokenKey);
    await prefs.remove(entityId);
  }

  // ------------------ Autenticação ------------------

  static Future<void> addAccessToken({required String accessKeyValue, required String userIdValue}) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(tokenKey, accessKeyValue);
    await prefs.setString(entityId, userIdValue);
  }

  static Future<String?> readAccessToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(tokenKey); // corrigido (nada de 'TokenKey' literal)
  }

  static Future<String?> readEntityId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(entityId);
  }
}
