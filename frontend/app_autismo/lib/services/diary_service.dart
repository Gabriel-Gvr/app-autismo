import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:app_autismo/utils/constants.dart';
import 'package:app_autismo/models/diary_model.dart';

class DiaryService with ChangeNotifier {
  final String? _token;
  List<DiaryEntry> _entries = [];

  DiaryService(this._token);

  List<DiaryEntry> get entries => [..._entries];

  Future<void> fetchEntries() async {
    if (_token == null) return;
    final url = Uri.parse('$apiBaseUrl/entries?tipo=diario'); 

    try {
      final response = await http.get(
        url,
        headers: {'Authorization': 'Bearer $_token'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> responseData = jsonDecode(response.body);
        _entries =
            responseData.map((json) => DiaryEntry.fromJson(json)).toList();
        notifyListeners();
      } else {
        throw Exception('Falha ao carregar o diário');
      }
    } catch (error) {
      print('Erro fetchEntries: $error');
      throw Exception('Erro de rede');
    }
  }

  Future<bool> createDiaryEntry({
    required String data, 
    String? humor,
    String? sono,
    String? alimentacao,
    String? crise,
    String? observacao,
  }) async {
    if (_token == null) return false;
    final url = Uri.parse('$apiBaseUrl/entries');

    final Map<String, dynamic> payload = {
      "tipo": "diario",
      "data": data,
      "humor": humor,
      "sono": sono,
      "alimentacao": alimentacao,
      "crise": crise,
      "observacao": observacao,
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
        fetchEntries();
        return true;
      } else {
        print('Falha ao criar entrada: ${response.body}');
        return false;
      }
    } catch (error) {
      print('Erro createDiaryEntry: $error');
      return false;
    }
  }
}