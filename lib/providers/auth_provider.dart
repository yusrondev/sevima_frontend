import 'package:flutter/material.dart';
import '../api_service.dart';

class AuthProvider extends ChangeNotifier {
  final ApiService api = ApiService();
  bool loggedIn = false;

  Future<bool> login(String email, String pwd) async {
    final ok = await api.login(email, pwd);
    if (ok) loggedIn = true;
    notifyListeners();
    return ok;
  }

  Future<bool> register(String email, String pwd, String name) async {
    return await api.register(email, pwd, name);
  }

  void logout() {
    loggedIn = false;
    api.storage.delete(key: 'jwt');
    notifyListeners();
  }
}
