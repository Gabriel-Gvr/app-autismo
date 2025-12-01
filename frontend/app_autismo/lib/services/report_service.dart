import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:app_autismo/utils/constants.dart';
import 'package:app_autismo/models/report_model.dart';
import 'package:intl/intl.dart'; 

class ReportService with ChangeNotifier {
  final String? _token;
  ReportData? _reportData;
  bool _isLoading = false;

  ReportService(this._token);

  ReportData? get reportData => _reportData;
  bool get isLoading => _isLoading;

  Future<void> fetchWeeklyReport() async {
    if (_token == null) return;
    _isLoading = true;
    notifyListeners();

    final DateTime endDate = DateTime.now();
    final DateTime startDate = endDate.subtract(Duration(days: 7));

    final String from = DateFormat('yyyy-MM-dd').format(startDate);
    final String to = DateFormat('yyyy-MM-dd').format(endDate);

    final url = Uri.parse('$apiBaseUrl/reports/weekly?from=$from&to=$to');

    try {
      final response = await http.get(
        url,
        headers: {'Authorization': 'Bearer $_token'},
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        _reportData = ReportData.fromJson(responseData);
      } else {
        print('Falha ao carregar relatório: ${response.body}');
        throw Exception('Falha ao carregar relatório');
      }
    } catch (error) {
      print('Erro fetchWeeklyReport: $error');
      throw Exception('Erro de rede');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}