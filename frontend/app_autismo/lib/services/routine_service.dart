import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:app_autismo/utils/constants.dart';
import 'package:app_autismo/models/routine_model.dart';

class RoutineService with ChangeNotifier {
  final String? _token;
  List<Routine> _routines = [];

  RoutineService(this._token);

  List<Routine> get routines => [..._routines];

  Future<void> fetchRoutines() async {
    if (_token == null) {
      print('Token é nulo. Não é possível buscar rotinas.');
      return;
    }

    final url = Uri.parse('$apiBaseUrl/routines');

    try {
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_token', 
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> responseData = jsonDecode(response.body);
        _routines = responseData
            .map((json) => Routine.fromJson(json))
            .toList();
        
        notifyListeners(); 
      } else {
        print('Falha ao carregar rotinas: ${response.body}');
        throw Exception('Falha ao carregar rotinas');
      }
    } catch (error) {
      print('Erro de rede: $error');
      throw Exception('Erro de rede');
    }
  }
  Future<bool> createRoutine(
    String titulo,
    String? lembrete, 
    List<Map<String, dynamic>> steps, 
  ) async {
    if (_token == null) {
      print('Token é nulo. Não é possível criar rotina.');
      return false;
    }

    final url = Uri.parse('$apiBaseUrl/routines');

    final Map<String, dynamic> payload = {
      "titulo": titulo,
      "lembrete": lembrete, 
      "steps": steps, 
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
        fetchRoutines(); 
        return true;
      } else {
        print('Falha ao criar rotina: ${response.body}');
        return false;
      }
    } catch (error) {
      print('Erro de rede ao criar rotina: $error');
      return false;
    }
  }
  Future<bool> checkRoutineStep(
    int routineId,
    int stepId,
    bool newState, 
  ) async {
    if (_token == null) {
      print('Token é nulo. Não é possível checar o passo.');
      return false;
    }

    final url = Uri.parse('$apiBaseUrl/routines/$routineId/steps/$stepId/check');

    final payload = {"feito": newState};

    try {
      final response = await http.patch( 
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_token',
        },
        body: jsonEncode(payload),
      );

      if (response.statusCode == 200) {
        _updateLocalStepState(routineId, stepId, newState);
        return true;
      } else {
        print('Falha ao checar passo: ${response.body}');
        return false;
      }
    } catch (error) {
      print('Erro de rede ao checar passo: $error');
      return false;
    }
  }

  void _updateLocalStepState(int routineId, int stepId, bool newState) {
    final routineIndex =
        _routines.indexWhere((routine) => routine.id == routineId);
    if (routineIndex == -1) return; 

    final stepIndex = _routines[routineIndex]
        .steps
        .indexWhere((step) => step.id == stepId);
    if (stepIndex == -1) return; 

    
    final oldStep = _routines[routineIndex].steps[stepIndex];
    final updatedStep = RoutineStep(
      id: oldStep.id,
      descricao: oldStep.descricao,
      duracao: oldStep.duracao,
      icone: oldStep.icone,
      feito: newState, 
    );

    _routines[routineIndex].steps[stepIndex] = updatedStep;

    notifyListeners();
  }
}
