
class ReportAggregates {
  final Map<String, dynamic> humor;
  final Map<String, dynamic> sono;
  final Map<String, dynamic> alimentacao;
  final Map<String, dynamic> crise;

  ReportAggregates({
    required this.humor,
    required this.sono,
    required this.alimentacao,
    required this.crise,
  });

  factory ReportAggregates.fromJson(Map<String, dynamic> json) {
    return ReportAggregates(
      humor: json['humor'] ?? {},
      sono: json['sono'] ?? {},
      alimentacao: json['alimentacao'] ?? {},
      crise: json['crise'] ?? {},
    );
  }
}

class ReportData {
  final String dataInicio;
  final String dataFim;
  final ReportAggregates agregados;

  ReportData({
    required this.dataInicio,
    required this.dataFim,
    required this.agregados,
  });

  factory ReportData.fromJson(Map<String, dynamic> json) {
    return ReportData(
      dataInicio: json['periodo']?['de'] ?? '',
      dataFim: json['periodo']?['ate'] ?? '',
      agregados: ReportAggregates.fromJson(json['agregados'] ?? {}),
    );
  }

  bool get isEmpty {
    return agregados.humor.isEmpty &&
           agregados.sono.isEmpty &&
           agregados.alimentacao.isEmpty &&
           agregados.crise.isEmpty;
  }
}

class SharedReportData {
  final int pacienteId;
  final String pacienteEmail;
  final ReportData report; 

  SharedReportData({
    required this.pacienteId,
    required this.pacienteEmail,
    required this.report,
  });

  factory SharedReportData.fromJson(Map<String, dynamic> json) {
    return SharedReportData(
      pacienteId: json['paciente_id'],
      pacienteEmail: json['paciente_email'],
      report: ReportData.fromJson(json), 
    );
  }
}