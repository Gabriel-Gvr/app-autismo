
class DiaryDetails {
  final String? humor;
  final String? sono;
  final String? alimentacao;
  final String? crise;

  DiaryDetails({this.humor, this.sono, this.alimentacao, this.crise});

  factory DiaryDetails.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return DiaryDetails(); 
    }
    return DiaryDetails(
      humor: json['humor'],
      sono: json['sono'],
      alimentacao: json['alimentacao'],
      crise: json['crise'],
    );
  }
}

class DiaryEntry {
  final int id;
  final String tipo;
  final String? data; 
  final String? texto; 
  final DiaryDetails details;
  final String criadoEm; 

  DiaryEntry({
    required this.id,
    required this.tipo,
    this.data,
    this.texto,
    required this.details,
    required this.criadoEm,
  });

  factory DiaryEntry.fromJson(Map<String, dynamic> json) {
    return DiaryEntry(
      id: json['id'],
      tipo: json['tipo'],
      data: json['data'],
      texto: json['texto'],
      details: DiaryDetails.fromJson(json['details']),
      criadoEm: json['criado_em'],
    );
  }
}