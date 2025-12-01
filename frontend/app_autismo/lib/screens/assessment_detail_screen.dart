import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:app_autismo/services/psychologist_service.dart';
import 'package:app_autismo/models/assessment_model.dart';
import 'package:intl/intl.dart';
import 'package:app_autismo/screens/mchat_screen.dart';

class AssessmentDetailScreen extends StatefulWidget {
  final AssessmentSummary summary;

  const AssessmentDetailScreen({Key? key, required this.summary})
      : super(key: key);

  @override
  _AssessmentDetailScreenState createState() => _AssessmentDetailScreenState();
}

class _AssessmentDetailScreenState extends State<AssessmentDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late Future<Map<String, dynamic>> _dataFuture;

  final Map<String, String> _fieldTranslations = {
    'name': 'Nome',
    'nascimento': 'Nascimento',
    'data_avaliacao': 'Data da Avaliação',
    'aplicador': 'Aplicador',
    'responsaveis': 'Responsáveis',
    'cidade': 'Cidade',
    'celular': 'Celular',
    'cuidadores': 'Cuidadores',
    'composicao_familiar': 'Composição Familiar',
    'pessoas_autorizadas': 'Pessoas Autorizadas',
    'responsavel': 'Médico Responsável',
    'assistente': 'Médico Assistente',
    'diagnostico': 'Diagnóstico',
    'medicamentos': 'Medicamentos',
    'alergias': 'Alergias',
    'audicao_exame': 'Exame de Audição',
    'audicao_percepcao': 'Percepção da Audição',
    'otites': 'Histórico de Otites',
    'planejada': 'Gestação Planejada',
    'intercorrencias': 'Intercorrências (Gestação)',
    'semanas': 'Semanas (Nascimento)',
    'parto': 'Tipo de Parto',
    'apgar': 'Apgar',
    'peso': 'Peso (Nascimento)',
    'altura': 'Altura (Nascimento)',
    'pos_intercorrencias': 'Intercorrências (Parto/Pós)',
    'amamentacao': 'Amamentação',
    'controle_cervical': 'Controle Cervical',
    'sentar': 'Sentar sem Apoio',
    'engatinhar': 'Engatinhar',
    'andar': 'Andar',
    'primeiras_palavras': 'Primeiras Palavras',
    'comportamento_verbal': 'Comportamento Verbal',
    'motor_amplo': 'Motor Amplo',
    'motor_fino': 'Motor Fino',
    'frequenta': 'Frequenta Escola',
    'qual': 'Qual Escola?',
    'turno': 'Turno',
    'ano': 'Ano',
    'professora': 'Professora',
    'comportamento': 'Comportamento (Escola)',
    'banheiro': 'Banheiro / Controle Esfíncteres',
    'banho': 'Banho',
    'dentes': 'Escovar os Dentes',
    'vestir': 'Vestir-se',
    'maos': 'Lavar as Mãos',
    'alimentacao': 'Alimentação',
    'degluticao': 'Dificuldade Deglutição',
    'restricoes': 'Restrições Alimentares',
    'habitos': 'Hábitos Alimentares',
    'sono': 'Sono',
    'chupeta': 'Usa Chupeta?',
    'mamadeira': 'Usa Mamadeira?',
    'tatil': 'Tátil',
    'auditiva': 'Auditiva',
    'olfativa': 'Olfativa',
    'visual': 'Visual',
    'brincar_preferencias': 'Brincar / Preferências',
    'medos': 'Medos',
    'socializacao': 'Socialização',
    'queixas': 'Queixas',
    'comportamentos_inadequados': 'Comportamentos Inadequados',
    'observacoes': 'Observações Gerais',
  };

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _dataFuture = _fetchData();
  }

  String _formatValue(dynamic value) {
    if (value is bool) {
      return value ? 'Sim' : 'Não';
    }
    if (value == null || value.toString().isEmpty) {
      return 'Não preenchido';
    }
    if (value is List) {
      return value.join(', ');
    }
    return value.toString();
  }

  Future<Map<String, dynamic>> _fetchData() async {
    final psychService =
        Provider.of<PsychologistService>(context, listen: false);
    final anamnese =
        await psychService.fetchAssessmentDetails(widget.summary.id);
    MChatResult? mchat;
    try {
      mchat = await psychService.fetchMChatResults(widget.summary.id);
    } catch (e) {
      print('M-CHAT não encontrado (esperado): $e');
    }
    return {
      'anamnese': anamnese,
      'mchat': mchat,
    };
  }

  void _navigateToMChat(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (ctx) => MChatScreen(assessmentId: widget.summary.id),
      ),
    ).then((_) {
      setState(() {
        _dataFuture = _fetchData();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.summary.pacienteNome),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(icon: Icon(Icons.description), text: 'Anamnese'),
            Tab(icon: Icon(Icons.checklist), text: 'M-CHAT'),
          ],
        ),
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _dataFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Erro ao carregar dados.'));
          }
          if (snapshot.hasData) {
            final Assessment anamnese = snapshot.data!['anamnese'];
            final MChatResult? mchat = snapshot.data!['mchat'];

            return TabBarView(
              controller: _tabController,
              children: [
                _buildAnamneseTab(anamnese),
                _buildMChatTab(mchat),
              ],
            );
          }
          return Center(child: Text('Nenhum dado encontrado.'));
        },
      ),
    );
  }

  Widget _buildAnamneseTab(Assessment anamnese) {
    Widget buildSection(String title, Map<String, dynamic>? data) {
      if (data == null) return SizedBox.shrink();

      final validEntries = data.entries
          .where((entry) => entry.value != null && entry.value.toString().isNotEmpty)
          .toList();

      if (validEntries.isEmpty) return SizedBox.shrink();

      return ExpansionTile(
        title: Text(title, style: TextStyle(fontWeight: FontWeight.bold)),
        initiallyExpanded: title == 'Identificação',
        children: validEntries.map((entry) {
          String label = _fieldTranslations[entry.key] ??
                         entry.key.replaceAll('_', ' ');
          String valueText = _formatValue(entry.value);

          return ListTile(
            title: Text(label),
            subtitle: Text(valueText),
          );
        }).toList(),
      );
    }

    return ListView(
      padding: EdgeInsets.all(8.0),
      children: [
        buildSection('Identificação', {
          ...anamnese.pacienteJson,
          ...anamnese.secoesJson['identificacao']
        }),
        buildSection('Dados Médicos', anamnese.secoesJson['medico']),
        buildSection('Gestação e Parto', anamnese.secoesJson['gestacao_parto_puerperio']),
        buildSection('DNPM', anamnese.secoesJson['dnpm']),
        buildSection('Escola', anamnese.secoesJson['escola']),
        buildSection('Autocuidado (AVD)', anamnese.secoesJson['avd']),
        buildSection('Sensorial', anamnese.secoesJson['sensorial']),
        buildSection('Observações Finais', {
          "brincar_preferencias": anamnese.secoesJson['brincar_preferencias'],
          "medos": anamnese.secoesJson['medos'],
          "socializacao": anamnese.secoesJson['socializacao'],
          "queixas": anamnese.secoesJson['queixas'],
          "comportamentos_inadequados": anamnese.secoesJson['comportamentos_inadequados'],
          "observacoes": anamnese.secoesJson['observacoes'],
        }),
      ],
    );
  }

  Widget _buildMChatTab(MChatResult? mchat) {
    if (mchat == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.warning_amber_rounded, size: 60, color: Colors.orange),
            SizedBox(height: 16),
            Text(
              'O M-CHAT para esta avaliação ainda não foi preenchido.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            SizedBox(height: 24),
            ElevatedButton.icon(
              icon: Icon(Icons.edit_note),
              label: Text('Preencher M-CHAT Agora'),
              onPressed: () => _navigateToMChat(context),
            ),
          ],
        ),
      );
    }

    final date = mchat.salvoEm != null
        ? DateFormat('dd/MM/yyyy HH:mm')
            .format(DateTime.parse(mchat.salvoEm!))
        : 'Data indisponível';
    return ListView(
      padding: EdgeInsets.all(16.0),
      children: [
        Text('Resultado do M-CHAT', style: Theme.of(context).textTheme.headlineSmall),
        Text('Preenchido em: $date'),
        SizedBox(height: 16),
        Card(
          color: mchat.classificacao == 'risco' ? Colors.red[50] : Colors.green[50],
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Text(
                  'Classificação: ${mchat.classificacao.toUpperCase()}',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: mchat.classificacao == 'risco' ? Colors.red : Colors.green[800],
                  ),
                ),
                SizedBox(height: 8),
                Text('Score Total: ${mchat.scoreTotal}'),
                Text('Itens Críticos Marcados: ${mchat.itensCriticos.join(', ')}'),
              ],
            ),
          ),
        ),
        SizedBox(height: 16),
        Text('Respostas Detalhadas:', style: Theme.of(context).textTheme.titleMedium),
        ...mchat.respostas.entries.map((entry) {
          return ListTile(
            title: Text('Pergunta ${entry.key}'),
            trailing: Text(
              entry.value.toString().toUpperCase(),
              style: TextStyle(
                color: entry.value == 'sim' ? Colors.green : Colors.red,
                fontWeight: FontWeight.bold,
              ),
            ),
          );
        }).toList(),
      ],
    );
  }
}