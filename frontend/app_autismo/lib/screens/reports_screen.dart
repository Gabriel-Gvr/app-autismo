import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart'; 
import 'package:app_autismo/services/report_service.dart';
import 'package:app_autismo/models/report_model.dart';
import 'package:intl/intl.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({Key? key}) : super(key: key);

  @override
  _ReportsScreenState createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  late Future _reportFuture;

  @override
  void initState() {
    super.initState();
    _reportFuture = Provider.of<ReportService>(context, listen: false)
        .fetchWeeklyReport();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Relatórios Semanais'),
      ),
      body: FutureBuilder(
        future: _reportFuture,
        builder: (ctx, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.error != null) {
            return Center(child: Text('Erro ao carregar o relatório.'));
          }
          
          return Consumer<ReportService>(
            builder: (ctx, reportService, child) {
              if (reportService.reportData == null || reportService.reportData!.isEmpty) {
                return Center(
                  child: Text('Nenhum dado de diário encontrado nos últimos 7 dias.'),
                );
              }

              final report = reportService.reportData!;
              final startDate = DateFormat('dd/MM').format(DateTime.parse(report.dataInicio));
              final endDate = DateFormat('dd/MM').format(DateTime.parse(report.dataFim));

              return ListView(
                padding: EdgeInsets.all(16.0),
                children: [
                  Text(
                    'Relatório do Período: $startDate - $endDate',
                    style: Theme.of(context).textTheme.headlineSmall,
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 24),
                  
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
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildPieChartCard(String title, Map<String, dynamic> data, List<Color> colors) {
    if (data.isEmpty) {
      return SizedBox.shrink(); 
    }

    double total = 0;
    data.forEach((key, value) {
      total += (value as num);
    });

    int colorIndex = 0;
    final List<PieChartSectionData> sections = data.entries.map((entry) {
      final percentage = ((entry.value as num) / total) * 100;
      final color = colors[colorIndex % colors.length];
      colorIndex++;
      
      return PieChartSectionData(
        color: color,
        value: percentage, 
        title: '${percentage.toStringAsFixed(0)}%', 
        radius: 80,
        titleStyle: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Colors.white,
          shadows: [Shadow(color: Colors.black, blurRadius: 2)],
        ),
      );
    }).toList();

    return Card(
      elevation: 4,
      margin: EdgeInsets.only(bottom: 20),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(title, style: Theme.of(context).textTheme.titleLarge),
            SizedBox(height: 16),
            SizedBox(
              height: 180,
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
      ),
    );
  }
}