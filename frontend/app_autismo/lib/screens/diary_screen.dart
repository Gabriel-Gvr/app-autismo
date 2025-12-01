import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:app_autismo/services/diary_service.dart';
import 'package:app_autismo/models/diary_model.dart';
import 'package:intl/intl.dart'; 
import 'package:app_autismo/screens/diary_detail_screen.dart';

class DiaryScreen extends StatefulWidget {
  const DiaryScreen({Key? key}) : super(key: key);

  @override
  _DiaryScreenState createState() => _DiaryScreenState();
}

class _DiaryScreenState extends State<DiaryScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late Future _entriesFuture;

  DateTime _selectedDate = DateTime.now();
  String? _humorValue;
  String? _sonoValue;
  String? _alimentacaoValue;
  String? _criseValue;
  final _observacaoController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _entriesFuture =
        Provider.of<DiaryService>(context, listen: false).fetchEntries();
  }

  Future<void> _submitDiary() async {
    setState(() {
      _isLoading = true;
    });

    final diaryService = Provider.of<DiaryService>(context, listen: false);

    bool success = await diaryService.createDiaryEntry(
      data: DateFormat('yyyy-MM-dd').format(_selectedDate),
      humor: _humorValue,
      sono: _sonoValue,
      alimentacao: _alimentacaoValue,
      crise: _criseValue,
      observacao: _observacaoController.text,
    );

    setState(() {
      _isLoading = false;
    });

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Diário salvo com sucesso!'),
          backgroundColor: Colors.green,
        ),
      );
      _clearForm();
      _tabController.animateTo(1);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao salvar o diário.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _clearForm() {
    setState(() {
      _selectedDate = DateTime.now();
      _humorValue = null;
      _sonoValue = null;
      _alimentacaoValue = null;
      _criseValue = null;
      _observacaoController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Diário'),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(icon: Icon(Icons.edit_note), text: 'Novo Registro'),
            Tab(icon: Icon(Icons.history), text: 'Histórico'),
          ],
        ),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _buildFormTab(context), 
                _buildHistoryTab(context), 
              ],
            ),
    );
  }

  Widget _buildFormTab(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('Data:', style: Theme.of(context).textTheme.titleLarge),
              SizedBox(width: 10),
              Text(DateFormat('dd/MM/yyyy').format(_selectedDate)),
              IconButton(
                icon: Icon(Icons.calendar_today),
                onPressed: () async {
                  final pickedDate = await showDatePicker(
                    context: context,
                    initialDate: _selectedDate,
                    firstDate: DateTime(2020),
                    lastDate: DateTime.now(),
                  );
                  if (pickedDate != null) {
                    setState(() {
                      _selectedDate = pickedDate;
                    });
                  }
                },
              )
            ],
          ),
          Divider(height: 20),

          _buildRadioGroup(
            title: 'Humor',
            options: ['Calmo', 'Feliz', 'Irritado'],
            groupValue: _humorValue,
            onChanged: (value) => setState(() => _humorValue = value),
          ),
          
          _buildRadioGroup(
            title: 'Sono',
            options: ['Dormiu bem', 'Agitado', 'Pouco'],
            groupValue: _sonoValue,
            onChanged: (value) => setState(() => _sonoValue = value),
          ),
          
          _buildRadioGroup(
            title: 'Alimentação',
            options: ['Comeu bem', 'Pouco', 'Recusou'],
            groupValue: _alimentacaoValue,
            onChanged: (value) => setState(() => _alimentacaoValue = value),
          ),

          _buildRadioGroup(
            title: 'Crise',
            options: ['Não houve', 'Sim, leve', 'Forte'],
            groupValue: _criseValue,
            onChanged: (value) => setState(() => _criseValue = value),
          ),

          TextFormField(
            controller: _observacaoController,
            decoration: InputDecoration(
              labelText: 'Observações',
              border: OutlineInputBorder(),
            ),
            maxLines: 4,
          ),
          SizedBox(height: 20),

          Center(
            child: ElevatedButton.icon(
              icon: Icon(Icons.save),
              label: Text('Salvar Diário'),
              onPressed: _submitDiary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryTab(BuildContext context) {
    return FutureBuilder(
      future: _entriesFuture,
      builder: (ctx, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.error != null) {
          return Center(child: Text('Erro ao carregar histórico.'));
        } else {
          return Consumer<DiaryService>(
            builder: (ctx, diaryService, child) {
              if (diaryService.entries.isEmpty) {
                return Center(child: Text('Nenhum registro encontrado.'));
              }
              return ListView.builder(
                itemCount: diaryService.entries.length,
                itemBuilder: (ctx, i) {
                  final entry = diaryService.entries[i];
                  String formattedDate = entry.data != null
                      ? DateFormat('dd/MM/yyyy')
                          .format(DateTime.parse(entry.data!))
                      : 'Sem data';

                  return Card(
                    margin: EdgeInsets.all(8.0),
                    child: ListTile(
                      title: Text('Registro de $formattedDate'),
                      subtitle: Text(entry.texto ?? 'Sem observações'),
                      isThreeLine: true,
                      trailing: Icon(Icons.arrow_forward_ios),
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => DiaryDetailScreen(entry: entry),
                          ),
                        );
                      },
                    ),
                  );
                },
              );
            },
          );
        }
      },
    );
  }

  Widget _buildRadioGroup({
    required String title,
    required List<String> options,
    required String? groupValue,
    required ValueChanged<String?> onChanged,
  }) {
    return Card(
      margin: EdgeInsets.only(bottom: 16.0),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleMedium),
            ...options.map((option) {
              return RadioListTile<String>(
                title: Text(option),
                value: option.toLowerCase().split(',')[0], 
                groupValue: groupValue,
                onChanged: onChanged,
              );
            }).toList(),
          ],
        ),
      ),
    );
  }
}