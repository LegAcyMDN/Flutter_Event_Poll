import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/user.dart';
import '../configs.dart';

class AuthState extends ChangeNotifier {
  User? _currentUser ;
  String? _token ;

  User? get currentUSer => _currentUser;
  String? get token => _token;

  bool get isLoggedIn => _token != null;

  Future<User?> login(String username, String password) async {
    final loginResponse = await http.post(
      Uri.parse('${Configs.baseUrl}/auth/login'),
      headers: {HttpHeaders.contentTypeHeader: 'application/json'},
      body: json.encode({
        'username': username,
        'password': password,
      }),
    );

    if (loginResponse.statusCode == HttpStatus.ok) {
      _token = json.decode(loginResponse.body)['token'];

      final userResponse = await http.get(
        Uri.parse('${Configs.baseUrl}/users/me'),
        headers: {
          HttpHeaders.authorizationHeader: 'Bearer $_token',
          HttpHeaders.contentTypeHeader: 'application/json',
        },
      );

      if (userResponse.statusCode == HttpStatus.ok) {
        _currentUser = User.fromJson(json.decode(userResponse.body));
        notifyListeners();
        return _currentUser;
      }
    }

    logout();
    return null;
  }

  Future<bool> signup(String username, String password) async {
    final signupResponse = await http.post(
      Uri.parse('${Configs.baseUrl}/auth/signup'),
      headers: {HttpHeaders.contentTypeHeader: 'application/json'},
      body: json.encode({
        'username': username,
        'password': password,
      }),
    );

    return signupResponse.statusCode == HttpStatus.created;
  }

  void logout() {
    _token = null;
    _currentUser = null;
    notifyListeners();
  }
}