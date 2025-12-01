
class RoutineStep {
  final int id;
  final String descricao;
  final int? duracao;
  final bool feito;
  final String? icone;

  RoutineStep({
    required this.id,
    required this.descricao,
    this.duracao,
    required this.feito,
    this.icone,
  });

  factory RoutineStep.fromJson(Map<String, dynamic> json) {
    return RoutineStep(
      id: json['id'],
      descricao: json['descricao'],
      duracao: json['duracao'],
      feito: json['feito'],
      icone: json['icone'],
    );
  }
}

class Routine {
  final int id;
  final String titulo;
  final String? lembrete;
  final List<RoutineStep> steps;

  Routine({
    required this.id,
    required this.titulo,
    this.lembrete,
    required this.steps,
  });

  factory Routine.fromJson(Map<String, dynamic> json) {
    var stepsList = json['steps'] as List;
    List<RoutineStep> steps =
        stepsList.map((stepJson) => RoutineStep.fromJson(stepJson)).toList();

    return Routine(
      id: json['id'],
      titulo: json['titulo'],
      lembrete: json['lembrete'],
      steps: steps,
    );
  }
}