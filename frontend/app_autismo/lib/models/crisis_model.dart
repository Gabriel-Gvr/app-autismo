import 'dart:convert';

class CrisisContact {
  final String name;
  final String phone;

  CrisisContact({required this.name, required this.phone});

  Map<String, dynamic> toJson() => {
        'name': name,
        'phone': phone,
      };

  factory CrisisContact.fromJson(Map<String, dynamic> json) {
    return CrisisContact(
      name: json['name'],
      phone: json['phone'],
    );
  }
}

class CrisisData {
  final String instructions;
  final List<CrisisContact> contacts;

  CrisisData({required this.instructions, required this.contacts});

  Map<String, dynamic> toJson() => {
        'instructions': instructions,
        'contacts': contacts.map((c) => c.toJson()).toList(),
      };

  factory CrisisData.fromJson(Map<String, dynamic> json) {
    var list = json['contacts'] as List;
    List<CrisisContact> contactList =
        list.map((i) => CrisisContact.fromJson(i)).toList();

    return CrisisData(
      instructions: json['instructions'],
      contacts: contactList,
    );
  }
}