import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:app_autismo/services/auth_service.dart';
import 'package:app_autismo/services/psychologist_service.dart';
import 'package:app_autismo/screens/anamnese_form_screen.dart';
import 'package:app_autismo/screens/assessment_detail_screen.dart';
import 'package:app_autismo/models/report_model.dart'; 
import 'package:fl_chart/fl_chart.dart'; 
import 'package:intl/intl.dart';

class PsychologistHomeScreen extends StatefulWidget {
  const PsychologistHomeScreen({Key? key}) : super(key: key);

  @override
  _PsychologistHomeScreenState createState() => _PsychologistHomeScreenState();
}

class _PsychologistHomeScreenState extends State<PsychologistHomeScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late Future _assessmentsFuture;
  late Future _reportsFuture; 

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _assessmentsFuture = _fetchAssessments();
    _reportsFuture = _fetchReports();
  }

  Future<void> _fetchAssessments() {
    return Provider.of<PsychologistService>(context, listen: false)
        .fetchAssessments();
  }

  Future<void> _fetchReports() {
    return Provider.of<PsychologistService>(context, listen: false)
        .fetchSharedReports();
  }

  void _navigateToCreateScreen(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => AnamneseFormScreen(),
      ),
    ).then((_) {
      setState(() {
        _assessmentsFuture = _fetchAssessments();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Painel do Psicólogo'),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () {
              Provider.of<AuthService>(context, listen: false).logout();
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(icon: Icon(Icons.description), text: 'Minhas Avaliações'),
            Tab(icon: Icon(Icons.bar_chart), text: 'Relatórios de Pacientes'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildAssessmentsTab(), 
          _buildReportsTab(), 
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _navigateToCreateScreen(context),
        icon: Icon(Icons.add),
        label: Text('Nova Anamnese'),
      ),
    );
  }

  Widget _buildAssessmentsTab() {
    return FutureBuilder(
      future: _assessmentsFuture,
      builder: (ctx, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.error != null) {
          return Center(child: Text('Erro ao carregar avaliações.'));
        } else {
          return Consumer<PsychologistService>(
            builder: (ctx, psychService, child) {
              if (psychService.assessments.isEmpty) {
                return Center(
                  child: Text('Nenhuma avaliação encontrada.'),
                );
              }
              return ListView.builder(
                padding: EdgeInsets.all(8.0),
                itemCount: psychService.assessments.length,
                itemBuilder: (ctx, i) {
                  final assessment = psychService.assessments[i];
                  final date = DateTime.parse(assessment.dataCriacao);
                  final formattedDate =
                      DateFormat('dd/MM/yyyy \'às\' HH:mm').format(date);
                  return Card(
                    child: ListTile(
                      leading: Icon(Icons.description),
                      title: Text(assessment.pacienteNome),
                      subtitle: Text('Registrado em: $formattedDate'),
                      trailing: assessment.mchatCompleto
                          ? Icon(Icons.check_circle, color: Colors.green)
                          : Icon(Icons.warning_amber, color: Colors.orange),
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => AssessmentDetailScreen(
                              summary: assessment,
                            ),
                          ),
                        ).then((_) {
                          setState(() {
                            _assessmentsFuture = _fetchAssessments();
                          });
                        });
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

  Widget _buildReportsTab() {
    return FutureBuilder(
      future: _reportsFuture,
      builder: (ctx, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.error != null) {
          return Center(child: Text('Erro ao carregar relatórios.'));
        } else {
          return Consumer<PsychologistService>(
            builder: (ctx, psychService, child) {
              if (psychService.sharedReports.isEmpty) {
                return Center(
                  child: Text('Nenhum paciente compartilhou relatórios com você.'),
                );
              }
              return ListView.builder(
                padding: EdgeInsets.all(8.0),
                itemCount: psychService.sharedReports.length,
                itemBuilder: (ctx, i) {
                  final sharedReport = psychService.sharedReports[i];
                  final report = sharedReport.report;
                  final startDate = DateFormat('dd/MM').format(DateTime.parse(report.dataInicio));
                  final endDate = DateFormat('dd/MM').format(DateTime.parse(report.dataFim));
                  
                  return Card(
                    child: ExpansionTile(
                      leading: Icon(Icons.person_pin),
                      title: Text(sharedReport.pacienteEmail),
                      subtitle: Text('Período: $startDate - $endDate'),
                      children: [
                        _buildPieChartCard(
                          'Humor', 
                          report.agregados.humor, 
                          [Colors.blue, Colors.green, Colors.orange]
                        ),
                        _buildPieChartCard(
                          'Sono', 
                          report.agregados.sono, 
                          [Colors.indigo, Colors.purple, Colors.teal]
                        ),
                        _buildPieChartCard(
                          'Alimentação', 
                          report.agregados.alimentacao, 
                          [Colors.green, Colors.amber, Colors.red]
                        ),
                        _buildPieChartCard(
                          'Crise', 
                          report.agregados.crise, 
                          [Colors.grey, Colors.orange, Colors.red]
                        ),
                      ],
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

  Widget _buildPieChartCard(String title, Map<String, dynamic> data, List<Color> colors) {
    if (data.isEmpty) {
      return ListTile(title: Text('Nenhum dado de $title no período.'));
    }

    double total = 0;
    data.forEach((key, value) { total += (value as num); });

    int colorIndex = 0;
    final List<PieChartSectionData> sections = data.entries.map((entry) {
      final percentage = ((entry.value as num) / total) * 100;
      final color = colors[colorIndex % colors.length];
      colorIndex++;
      
      return PieChartSectionData(
        color: color,
        value: percentage,
        title: '${percentage.toStringAsFixed(0)}%',
        radius: 60, 
        titleStyle: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      );
    }).toList();

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Text(title, style: Theme.of(context).textTheme.titleLarge),
          SizedBox(height: 16),
          SizedBox(
            height: 150, 
            child: PieChart(
              PieChartData(
                sections: sections,
                borderData: FlBorderData(show: false),
                sectionsSpace: 2,
                centerSpaceRadius: 0,
              ),
            ),
          ),
          SizedBox(height: 16),
          ...data.entries.map((entry) {
            final color = colors[data.keys.toList().indexOf(entry.key) % colors.length];
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 2.0),
              child: Row(
                children: [
                  Container(width: 16, height: 16, color: color),
                  SizedBox(width: 8),
                  Text(
                    '${entry.key.toUpperCase()}: ${entry.value} ocorrência(s)',
                    style: TextStyle(fontSize: 14),
                  ),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }
}