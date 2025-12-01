import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:app_autismo/utils/constants.dart';
import 'package:app_autismo/models/share_model.dart';

class ShareService with ChangeNotifier {
  final String? _token;
  List<Share> _shares = [];

  ShareService(this._token);

  List<Share> get shares => [..._shares];

  Future<void> fetchShares() async {
    if (_token == null) return;
    final url = Uri.parse('$apiBaseUrl/shares');

    try {
      final response = await http.get(
        url,
        headers: {'Authorization': 'Bearer $_token'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> responseData = jsonDecode(response.body);
        _shares = responseData.map((json) => Share.fromJson(json)).toList();
        notifyListeners();
      } else {
        throw Exception('Falha ao carregar compartilhamentos');
      }
    } catch (error) {
      print('Erro fetchShares: $error');
      throw Exception('Erro de rede');
    }
  }

  Future<bool> createShare(String email, String escopo) async {
    if (_token == null) return false;
    final url = Uri.parse('$apiBaseUrl/shares');
    
    final payload = {
      "viewer_email": email,
      "escopo": escopo,
    };

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_token',
        },
        body: jsonEncode(payload),
      );

      if (response.statusCode == 201) {
        await fetchShares();
        return true;
      } else {
        print('Falha ao criar compartilhamento: ${response.body}');
        return false;
      }
    } catch (error) {
      print('Erro createShare: $error');
      return false;
    }
  }

  Future<bool> deleteShare(int shareId) async {
    if (_token == null) return false;
    final url = Uri.parse('$apiBaseUrl/shares/$shareId');

    try {
      final response = await http.delete(
        url,
        headers: {'Authorization': 'Bearer $_token'},
      );

      if (response.statusCode == 200) {
        await fetchShares();
        return true;
      } else {
        print('Falha ao remover compartilhamento: ${response.body}');
        return false;
      }
    } catch (error) {
      print('Erro deleteShare: $error');
      return false;
    }
  }
}