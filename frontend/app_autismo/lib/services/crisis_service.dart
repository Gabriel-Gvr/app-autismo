import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:app_autismo/models/crisis_model.dart';

class CrisisService with ChangeNotifier {
  CrisisData? _data;

  CrisisData? get data => _data;

  Future<void> loadCrisisData() async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.containsKey('crisis_data')) {
      final jsonString = prefs.getString('crisis_data');
      if (jsonString != null) {
        _data = CrisisData.fromJson(jsonDecode(jsonString));
        notifyListeners();
      }
    }
  }

  Future<void> saveCrisisData(String instructions, List<CrisisContact> contacts) async {
    final newData = CrisisData(instructions: instructions, contacts: contacts);
    _data = newData;

    final prefs = await SharedPreferences.getInstance();
    final jsonString = jsonEncode(newData.toJson());
    await prefs.setString('crisis_data', jsonString);
    
    notifyListeners();
  }
}