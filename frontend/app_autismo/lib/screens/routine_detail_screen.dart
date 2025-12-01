import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:app_autismo/models/routine_model.dart';
import 'package:app_autismo/services/routine_service.dart';

class RoutineDetailScreen extends StatefulWidget {
  final Routine routine;

  const RoutineDetailScreen({Key? key, required this.routine}) : super(key: key);

  @override
  State<RoutineDetailScreen> createState() => _RoutineDetailScreenState();
}

class _RoutineDetailScreenState extends State<RoutineDetailScreen> {
  late Map<int, bool> _stepStates;
  late Map<int, bool> _stepLoading;

  @override
  void initState() {
    super.initState();
    _stepStates = {
      for (var step in widget.routine.steps) step.id: step.feito
    };
    _stepLoading = {
      for (var step in widget.routine.steps) step.id: false
    };
  }

  Future<void> _onStepChanged(RoutineStep step, bool? newValue) async {
    if (newValue == null) return;

    final routineService = Provider.of<RoutineService>(context, listen: false);

    setState(() {
      _stepLoading[step.id] = true;
    });

    bool success = await routineService.checkRoutineStep(
      widget.routine.id,
      step.id,
      newValue,
    );

    setState(() {
      _stepLoading[step.id] = false;
      if (success) {
        _stepStates[step.id] = newValue; 
      }
    });

    if (!success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao salvar passo. Tente novamente.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.routine.titulo),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (widget.routine.lembrete != null)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Icon(Icons.alarm, color: Colors.blueGrey),
                  SizedBox(width: 8),
                  Text(
                    'Lembrete às: ${widget.routine.lembrete}',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ],
              ),
            ),
          Divider(height: 1),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Passos da Rotina:',
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ),
          
          Expanded(
            child: ListView.builder(
              itemCount: widget.routine.steps.length,
              itemBuilder: (ctx, index) {
                final step = widget.routine.steps[index];
                final bool isLoading = _stepLoading[step.id] ?? false;
                final bool isDone = _stepStates[step.id] ?? false;

                return Card(
                  margin: EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
                  child: ListTile(
                    leading: isLoading
                        ? Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: CircularProgressIndicator(strokeWidth: 2.0),
                          )
                        : Checkbox(
                            value: isDone,
                            onChanged: (newValue) => _onStepChanged(step, newValue),
                          ),
                    title: Text(
                      step.descricao,
                      style: TextStyle(
                        decoration: isDone
                            ? TextDecoration.lineThrough
                            : TextDecoration.none,
                      ),
                    ),
                    subtitle: step.duracao != null
                        ? Text('${step.duracao} segundos')
                        : null,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}