import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:app_autismo/utils/constants.dart';
import 'package:app_autismo/models/assessment_model.dart';
import 'package:app_autismo/models/report_model.dart';

class PsychologistService with ChangeNotifier {
  final String? _token;
  List<AssessmentSummary> _assessments = [];

  List<SharedReportData> _sharedReports = [];

  PsychologistService(this._token);

  List<AssessmentSummary> get assessments => [..._assessments];
  List<SharedReportData> get sharedReports => [..._sharedReports]; 

  Future<void> fetchAssessments() async {
    if (_token == null) return;
    
    final url = Uri.parse('$apiBaseUrl/psych/assessments'); 

    try {
      final response = await http.get(
        url,
        headers: {'Authorization': 'Bearer $_token'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> responseData = jsonDecode(response.body);
        _assessments = responseData
            .map((json) => AssessmentSummary.fromJson(json))
            .toList();
        notifyListeners();
      } else {
        print('Falha ao carregar avaliações: ${response.body}');
        throw Exception('Falha ao carregar avaliações');
      }
    } catch (error) {
      print('Erro fetchAssessments: $error');
      throw Exception('Erro de rede');
    }
  }

  Future<int?> createAssessment(Map<String, dynamic> anamneseData) async {
    if (_token == null) return null;
    final url = Uri.parse('$apiBaseUrl/psych/assessments');

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_token',
        },
        body: jsonEncode(anamneseData), 
      );

      if (response.statusCode == 201) {
        final responseData = jsonDecode(response.body);
        await fetchAssessments(); 
        return responseData['id']; 
      } else {
        print('Falha ao criar avaliação: ${response.body}');
        return null;
      }
    } catch (error) {
      print('Erro de rede createAssessment: $error');
      return null;
    }
  }

  Future<bool> saveMchatResults(int assessmentId, Map<String, String> respostas) async {
    if (_token == null) return false;
    final url = Uri.parse('$apiBaseUrl/psych/assessments/$assessmentId/mchat');

    final payload = {"respostas": respostas};

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
        await fetchAssessments();
        return true;
      } else {
        print('Falha ao salvar M-CHAT: ${response.body}');
        return false;
      }
    } catch (error) {
      print('Erro de rede saveMchatResults: $error');
      return false;
    }
    
  }
  Future<Assessment> fetchAssessmentDetails(int assessmentId) async {
    if (_token == null) throw Exception('Não autenticado');
    
    final url = Uri.parse('$apiBaseUrl/psych/assessments/$assessmentId');
    try {
      final response = await http.get(
        url,
        headers: {'Authorization': 'Bearer $_token'},
      );
      if (response.statusCode == 200) {
        return Assessment.fromJson(jsonDecode(response.body));
      } else {
        throw Exception('Falha ao carregar detalhes da avaliação');
      }
    } catch (error) {
      print('Erro fetchAssessmentDetails: $error');
      throw Exception('Erro de rede');
    }
  }

  Future<MChatResult> fetchMChatResults(int assessmentId) async {
    if (_token == null) throw Exception('Não autenticado');
    
    final url = Uri.parse('$apiBaseUrl/psych/assessments/$assessmentId/mchat');
    try {
      final response = await http.get(
        url,
        headers: {'Authorization': 'Bearer $_token'},
      );
      if (response.statusCode == 200) {
        return MChatResult.fromJson(jsonDecode(response.body));
      } else {
        throw Exception('Falha ao carregar resultados do M-CHAT');
      }
    } catch (error) {
      print('Erro fetchMChatResults: $error');
      throw Exception('Erro de rede');
    }
  }
  Future<void> fetchSharedReports() async {
    if (_token == null) return;
    
    final url = Uri.parse('$apiBaseUrl/psych/shared_reports');

    try {
      final response = await http.get(
        url,
        headers: {'Authorization': 'Bearer $_token'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> responseData = jsonDecode(response.body);
        _sharedReports = responseData
            .map((json) => SharedReportData.fromJson(json))
            .toList();
        notifyListeners();
      } else {
        print('Falha ao carregar relatórios compartilhados: ${response.body}');
        throw Exception('Falha ao carregar relatórios compartilhados');
      }
    } catch (error) {
      print('Erro fetchSharedReports: $error');
      throw Exception('Erro de rede');
    }
  }
}

