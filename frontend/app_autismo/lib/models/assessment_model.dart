
class Assessment {
  final int id;
  final String status;
  final String aplicadorId;
  final Map<String, dynamic> pacienteJson;
  final Map<String, dynamic> secoesJson;

  Assessment({
    required this.id,
    required this.status,
    required this.aplicadorId,
    required this.pacienteJson,
    required this.secoesJson,
  });

  factory Assessment.fromJson(Map<String, dynamic> json) {
    return Assessment(
      id: json['id'],
      status: json['status'],
      aplicadorId: json['aplicador_id'].toString(),
      pacienteJson: json['paciente'] ?? {},
      
      secoesJson: {
        "identificacao": json['identificacao'] ?? {},
        "medico": json['medico'] ?? {},
        "gestacao_parto_puerperio": json['gestacao_parto_puerperio'] ?? {},
        "dnpm": json['dnpm'] ?? {},
        "escola": json['escola'] ?? {},
        "avd": json['avd'] ?? {},
        "sensorial": json['sensorial'] ?? {},
        
        "brincar_preferencias": json['brincar_preferencias'],
        "medos": json['medos'],
        "socializacao": json['socializacao'],
        "queixas": json['queixas'],
        "comportamentos_inadequados": json['comportamentos_inadequados'], 
        "observacoes": json['observacoes'],
      },
    );
  }
}

class AssessmentSummary {
  final int id;
  final String status;
  final String dataCriacao;
  final String pacienteNome;
  final bool mchatCompleto;

  AssessmentSummary({
    required this.id,
    required this.status,
    required this.dataCriacao,
    required this.pacienteNome,
    required this.mchatCompleto,
  });

  factory AssessmentSummary.fromJson(Map<String, dynamic> json) {
    return AssessmentSummary(
      id: json['id'],
      status: json['status'],
      dataCriacao: json['data_criacao'],
      pacienteNome: json['paciente_nome'],
      mchatCompleto: json['mchat_completo'],
    );
  }
}

class MChatItem {
  final int id;
  MChatItem({required this.id});
}

class MChatResult {
  final int assessmentId;
  final Map<String, dynamic> respostas;
  final int scoreTotal;
  final List<dynamic> itensCriticos;
  final String classificacao;
  final String? salvoEm;

  MChatResult({
    required this.assessmentId,
    required this.respostas,
    required this.scoreTotal,
    required this.itensCriticos,
    required this.classificacao,
    this.salvoEm,
  });

  factory MChatResult.fromJson(Map<String, dynamic> json) {
    return MChatResult(
      assessmentId: json['assessment_id'],
      respostas: json['respostas'] ?? {},
      scoreTotal: json['score_total'],
      itensCriticos: json['itens_criticos_marcados'] ?? [],
      classificacao: json['classificacao'],
      salvoEm: json['salvo_em'],
    );
  }
}