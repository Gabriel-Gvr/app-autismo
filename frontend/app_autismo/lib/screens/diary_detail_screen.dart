import 'package:flutter/material.dart';
import 'package:app_autismo/models/diary_model.dart';
import 'package:intl/intl.dart';

class DiaryDetailScreen extends StatelessWidget {
  final DiaryEntry entry;

  const DiaryDetailScreen({Key? key, required this.entry}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    String formattedDate = entry.data != null
        ? DateFormat('d MMMM yyyy', 'pt_BR')
            .format(DateTime.parse(entry.data!))
        : 'Sem data';

    return Scaffold(
      appBar: AppBar(
        title: Text('Registro de $formattedDate'),
      ),
      body: ListView(
        padding: EdgeInsets.all(16.0),
        children: [
          _buildDetailCard(
            context,
            title: 'Observações',
            content: entry.texto ?? 'Nenhuma observação.',
            icon: Icons.notes,
          ),
          SizedBox(height: 16),

          _buildDetailCard(
            context,
            title: 'Resumo do Dia',
            icon: Icons.checklist,
            children: [
              _buildDetailRow(context, 'Humor:', entry.details.humor),
              _buildDetailRow(context, 'Sono:', entry.details.sono),
              _buildDetailRow(context, 'Alimentação:', entry.details.alimentacao),
              _buildDetailRow(context, 'Crise:', entry.details.crise),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDetailCard(
    BuildContext context, {
    required String title,
    IconData? icon,
    String? content,
    List<Widget>? children,
  }) {
    return Card(
      elevation: 2.0,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                if (icon != null) ...[
                  Icon(icon, color: Theme.of(context).primaryColor),
                  SizedBox(width: 8),
                ],
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ],
            ),
            Divider(height: 20),
            if (content != null)
              Text(
                content,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            if (children != null) ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(BuildContext context, String label, String? value) {
    if (value == null || value.isEmpty) {
      return SizedBox.shrink(); 
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: Theme.of(context).textTheme.bodyMedium),
          Text(
            value[0].toUpperCase() + value.substring(1),
            style: Theme.of(context)
                .textTheme
                .bodyLarge
                ?.copyWith(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}