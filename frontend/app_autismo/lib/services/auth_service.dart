import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:app_autismo/utils/constants.dart'; 

class AuthService with ChangeNotifier {
  String? _token;
  String? _role; 
  bool _isAuthenticated = false;

  bool get isAuthenticated => _isAuthenticated;
  String? get token => _token;
  String? get role => _role; 

  Future<bool> login(String email, String password) async {
    final url = Uri.parse('$apiBaseUrl/auth/login');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        _token = responseData['access_token'];
        _role = responseData['role']; 
        _isAuthenticated = true;

        final prefs = await SharedPreferences.getInstance();
        prefs.setString('token', _token!);
        prefs.setString('role', _role!); 

        notifyListeners(); 
        return true;
      } else {
        print('Erro no login: ${response.body}');
        _isAuthenticated = false;
        return false;
      }
    } catch (error) {
      print('Erro de rede: $error');
      _isAuthenticated = false;
      return false;
    }
  }

  Future<void> logout() async {
    _token = null;
    _role = null; 
    _isAuthenticated = false;

    final prefs = await SharedPreferences.getInstance();
    prefs.remove('token');
    prefs.remove('role'); 

    notifyListeners(); 
  }

  Future<bool> tryAutoLogin() async {
    final prefs = await SharedPreferences.getInstance();
    
    if (!prefs.containsKey('token') || !prefs.containsKey('role')) {
      return false;
    }

    _token = prefs.getString('token');
    _role = prefs.getString('role');
    _isAuthenticated = true;
    
    notifyListeners();
    return true;
  }
}