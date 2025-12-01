import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:app_autismo/services/caa_service.dart';

class CreateItemScreen extends StatefulWidget {
  final int boardId;
  const CreateItemScreen({Key? key, required this.boardId}) : super(key: key);

  @override
  _CreateItemScreenState createState() => _CreateItemScreenState();
}

class _CreateItemScreenState extends State<CreateItemScreen> {
  final _formKey = GlobalKey<FormState>();
  final _textoController = TextEditingController();
  bool _isLoading = false;

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    final caaService = Provider.of<CaaService>(context, listen: false);

    bool success = await caaService.createBoardItem(
      boardId: widget.boardId,
      texto: _textoController.text,
    );

    setState(() {
      _isLoading = false;
    });

    if (success && mounted) {
      Navigator.of(context).pop();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao salvar o cartão.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Novo Cartão'),
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
                padding: const EdgeInsets.all(16.0),
                children: [
                  TextFormField(
                    controller: _textoController,
                    decoration: InputDecoration(
                      labelText: 'Texto do Cartão (Obrigatório)',
                      hintText: 'Ex: "Leite"',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor, insira um texto.';
                      }
                      return null;
                    },
                  ),
                ],
              ),
            ),
    );
  }
}