import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:app_autismo/services/routine_service.dart';

class CreateRoutineScreen extends StatefulWidget {
  const CreateRoutineScreen({Key? key}) : super(key: key);

  @override
  _CreateRoutineScreenState createState() => _CreateRoutineScreenState();
}

class StepControllers {
  final TextEditingController descricao = TextEditingController();
  final TextEditingController duracao = TextEditingController();
}

class _CreateRoutineScreenState extends State<CreateRoutineScreen> {
  final _formKey = GlobalKey<FormState>();
  final _tituloController = TextEditingController();
  final _lembreteController = TextEditingController();

  List<StepControllers> _stepControllers = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _addNewStep();
  }

  void _addNewStep() {
    setState(() {
      _stepControllers.add(StepControllers());
    });
  }

  void _removeStep() {
    if (_stepControllers.length > 1) {
      setState(() {
        _stepControllers.removeLast();
      });
    }
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final routineService = Provider.of<RoutineService>(context, listen: false);

    final titulo = _tituloController.text;
    final lembrete =
        _lembreteController.text.isNotEmpty ? _lembreteController.text : null;

    final List<Map<String, dynamic>> steps = _stepControllers
        .map((controllers) {
          final duracaoSegundos =
              int.tryParse(controllers.duracao.text) ?? null;
          return {
            "descricao": controllers.descricao.text,
            "duracao_segundos": duracaoSegundos,
            "icone": null,
          };
        })
        .where((step) => (step["descricao"] as String).isNotEmpty)
        .toList();

    bool success = await routineService.createRoutine(titulo, lembrete, steps);

    setState(() {
      _isLoading = false;
    });

    if (success && mounted) {
      Navigator.of(context).pop();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao salvar a rotina.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Nova Rotina'),
        actions: [
          IconButton(
            icon: Icon(Icons.save),
            onPressed: _submitForm,
          ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : Form(
              key: _formKey,
              child: ListView(
                padding: EdgeInsets.all(16.0),
                children: [
                  Text('Dados da Rotina',
                      style: Theme.of(context).textTheme.headlineSmall),
                  TextFormField(
                    controller: _tituloController,
                    decoration: InputDecoration(labelText: 'Título da Rotina'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor, insira um título.';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: _lembreteController,
                    decoration: InputDecoration(
                        labelText: 'Horário do Lembrete (HH:MM)',
                        hintText: 'Ex: 07:00'),
                  ),
                  SizedBox(height: 24),

                  Text('Passos da Rotina',
                      style: Theme.of(context).textTheme.headlineSmall),

                  ..._stepControllers.map((controllers) {
                    return _buildStepInput(controllers);
                  }).toList(),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton.icon(
                        icon: Icon(Icons.remove_circle_outline),
                        label: Text('Remover Passo'),
                        onPressed: _removeStep,
                      ),
                      TextButton.icon(
                        icon: Icon(Icons.add_circle),
                        label: Text('Adicionar Passo'),
                        onPressed: _addNewStep,
                      ),
                    ],
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildStepInput(StepControllers controllers) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 8.0),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            TextFormField(
              controller: controllers.descricao,
              decoration: InputDecoration(labelText: 'Descrição do Passo'),
            ),
            TextFormField(
              controller: controllers.duracao,
              decoration: InputDecoration(labelText: 'Duração (em segundos)'),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
      ),
    );
  }
}