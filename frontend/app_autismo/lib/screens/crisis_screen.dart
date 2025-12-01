import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:app_autismo/services/crisis_service.dart';
import 'package:app_autismo/models/crisis_model.dart';

class CrisisScreen extends StatefulWidget {
  const CrisisScreen({Key? key}) : super(key: key);

  @override
  _CrisisScreenState createState() => _CrisisScreenState();
}

class _CrisisScreenState extends State<CrisisScreen> {
  bool _isEditing = false;
  final _instructionsController = TextEditingController();
  
  List<CrisisContact> _tempContacts = [];
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final service = Provider.of<CrisisService>(context, listen: false);
    service.loadCrisisData().then((_) {
      if (service.data == null) {
        setState(() {
          _isEditing = true;
        });
      }
    });
  }

  void _toggleEdit() {
    final service = Provider.of<CrisisService>(context, listen: false);
    if (_isEditing) {
      if (service.data != null) {
        setState(() {
          _isEditing = false;
        });
      }
    } else {
      _instructionsController.text = service.data?.instructions ?? '';
      _tempContacts = List.from(service.data?.contacts ?? []);
      setState(() {
        _isEditing = true;
      });
    }
  }

  void _save() {
    final service = Provider.of<CrisisService>(context, listen: false);
    service.saveCrisisData(_instructionsController.text, _tempContacts);
    setState(() {
      _isEditing = false;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Dados de crise salvos localmente.')),
    );
  }

  void _addContact() {
    if (_nameController.text.isNotEmpty && _phoneController.text.isNotEmpty) {
      setState(() {
        _tempContacts.add(CrisisContact(
          name: _nameController.text,
          phone: _phoneController.text,
        ));
        _nameController.clear();
        _phoneController.clear();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _isEditing ? Colors.white : Colors.red[50],
      appBar: AppBar(
        title: Text('MODO CRISE', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.red,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: Icon(_isEditing ? Icons.close : Icons.edit),
            onPressed: _toggleEdit,
          )
        ],
      ),
      body: _isEditing ? _buildEditMode() : _buildViewMode(),
    );
  }

  Widget _buildViewMode() {
    return Consumer<CrisisService>(
      builder: (context, service, child) {
        final data = service.data;
        if (data == null) return Center(child: Text('Carregando...'));

        return Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'INSTRUÇÕES:',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.red[900]),
              ),
              SizedBox(height: 10),
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.red, width: 2),
                ),
                child: Text(
                  data.instructions.isEmpty ? "Sem instruções cadastradas." : data.instructions,
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.w500), 
                ),
              ),
              SizedBox(height: 30),
              Text(
                'CONTATOS DE EMERGÊNCIA:',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.red[900]),
              ),
              SizedBox(height: 10),
              Expanded(
                child: ListView.builder(
                  itemCount: data.contacts.length,
                  itemBuilder: (ctx, i) {
                    final contact = data.contacts[i];
                    return Card(
                      elevation: 4,
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Colors.red,
                          child: Icon(Icons.phone, color: Colors.white),
                        ),
                        title: Text(contact.name, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                        subtitle: Text(contact.phone, style: TextStyle(fontSize: 18)),
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Ligar para ${contact.name}: ${contact.phone}')),
                          );
                        },
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildEditMode() {
    return ListView(
      padding: EdgeInsets.all(16),
      children: [
        Text('Instruções de Acalmamento:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        TextField(
          controller: _instructionsController,
          maxLines: 4,
          decoration: InputDecoration(
            hintText: 'Ex: Ir para um lugar silencioso, oferecer água, abraçar forte...',
            border: OutlineInputBorder(),
          ),
        ),
        SizedBox(height: 24),
        Text('Adicionar Contato:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _nameController,
                decoration: InputDecoration(labelText: 'Nome'),
              ),
            ),
            SizedBox(width: 10),
            Expanded(
              child: TextField(
                controller: _phoneController,
                decoration: InputDecoration(labelText: 'Telefone'),
                keyboardType: TextInputType.phone,
              ),
            ),
            IconButton(
              icon: Icon(Icons.add_circle, color: Colors.green, size: 30),
              onPressed: _addContact,
            )
          ],
        ),
        SizedBox(height: 10),
        Text('Lista de Contatos:', style: TextStyle(fontSize: 16)),
        ..._tempContacts.map((c) => ListTile(
          title: Text(c.name),
          subtitle: Text(c.phone),
          trailing: IconButton(
            icon: Icon(Icons.delete, color: Colors.red),
            onPressed: () {
              setState(() {
                _tempContacts.remove(c);
              });
            },
          ),
        )).toList(),
        SizedBox(height: 20),
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
          onPressed: _save,
          child: Text('SALVAR DADOS DE CRISE'),
        ),
      ],
    );
  }
}