import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:app_autismo/utils/constants.dart';
import 'package:app_autismo/models/caa_model.dart';

class CaaService with ChangeNotifier {
  final String? _token;
  List<CaaBoard> _boards = [];

  CaaService(this._token);

  List<CaaBoard> get boards => [..._boards];

  Future<void> fetchBoards() async {
    if (_token == null) return;
    final url = Uri.parse('$apiBaseUrl/boards');

    try {
      final response = await http.get(
        url,
        headers: {'Authorization': 'Bearer $_token'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> responseData = jsonDecode(response.body);
        _boards =
            responseData.map((json) => CaaBoard.fromJson(json)).toList();
        notifyListeners();
      } else {
        print('Falha ao carregar pranchas');
        throw Exception('Falha ao carregar pranchas');
      }
    } catch (error) {
      print('Erro fetchBoards: $error');
      throw Exception('Erro de rede');
    }
  }

  Future<bool> createBoard(String nome) async {
    if (_token == null) return false;

    final url = Uri.parse('$apiBaseUrl/boards');
    final payload = {"nome": nome};

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
        await fetchBoards();
        return true;
      } else {
        print('Falha ao criar prancha: ${response.body}');
        return false;
      }
    } catch (error) {
      print('Erro de rede ao criar prancha: $error');
      return false;
    }
  }

  Future<bool> createBoardItem({
    required int boardId,
    required String texto,
  }) async {
    if (_token == null) return false;

    final url = Uri.parse('$apiBaseUrl/boards/$boardId/items');

    final payload = {
      "texto": texto,
      "img_url": null, 
      "audio_frase": null,
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
        await fetchBoards();
        return true;
      } else {
        print('Falha ao criar item: ${response.body}');
        return false;
      }
    } catch (error) {
      print('Erro de rede ao criar item: $error');
      return false;
    }
  }
}