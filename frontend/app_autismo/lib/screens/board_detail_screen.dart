// lib/screens/board_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:app_autismo/models/caa_model.dart';
import 'package:app_autismo/services/caa_service.dart';
import 'package:app_autismo/screens/create_item_screen.dart';
import 'package:flutter_tts/flutter_tts.dart';

class BoardDetailScreen extends StatefulWidget {
  final CaaBoard board;

  const BoardDetailScreen({Key? key, required this.board}) : super(key: key);

  @override
  _BoardDetailScreenState createState() => _BoardDetailScreenState();
}

class _BoardDetailScreenState extends State<BoardDetailScreen> {
  late List<CaaItem> _items;
  late FlutterTts _flutterTts;

  @override
  void initState() {
    super.initState();
    _items = widget.board.items;
    _initializeTts();
  }

  void _initializeTts() {
    _flutterTts = FlutterTts();
    _flutterTts.setLanguage('pt-BR');
  }

  void _onCardTapped(CaaItem item) {
    String textToSpeak = '${widget.board.nome} ${item.texto}';

    if (item.texto.toLowerCase() == 'silêncio') {
      textToSpeak = 'Preciso de silêncio.';
    }

    _flutterTts.speak(textToSpeak);
  }

  void _navigateToCreateItem() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => CreateItemScreen(boardId: widget.board.id),
      ),
    ).then((_) {
      _refreshItems();
    });
  }

  void _refreshItems() {
    final caaService = Provider.of<CaaService>(context, listen: false);
    final updatedBoard = caaService.boards.firstWhere(
      (b) => b.id == widget.board.id,
      orElse: () => widget.board,
    );

    setState(() {
      _items = updatedBoard.items;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.board.nome),
      ),
      body: _buildCardGrid(),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToCreateItem,
        child: Icon(Icons.add_photo_alternate),
      ),
    );
  }

  Widget _buildCardGrid() {
    if (_items.isEmpty) {
      return Center(
        child: Text(
          'Nenhum cartão nesta prancha. Adicione um no botão "+".',
          textAlign: TextAlign.center,
        ),
      );
    }

    return GridView.builder(
      padding: EdgeInsets.all(16.0),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16.0,
        mainAxisSpacing: 16.0,
        childAspectRatio: 1.0,
      ),
      itemCount: _items.length,
      itemBuilder: (context, index) {
        final item = _items[index];
        return _buildCard(item);
      },
    );
  }

  Widget _buildCard(CaaItem item) {
    IconData iconData = Icons.notes;
    String lowerText = item.texto.toLowerCase();

    if (lowerText == 'leite') {
      iconData = Icons.local_drink;
    } else if (lowerText == 'maçã') {
      iconData = Icons.apple;
    } else if (lowerText == 'brincar') {
      iconData = Icons.sports_esports;
    } else if (lowerText == 'passear') {
      iconData = Icons.directions_walk;
    } else if (lowerText == 'silêncio') {
      iconData = Icons.volume_off;
    } else if (lowerText.contains('comida')) {
      iconData = Icons.restaurant;
    }

    return InkWell(
      onTap: () => _onCardTapped(item),
      child: Card(
        elevation: 4.0,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(iconData, size: 60, color: Colors.grey.shade700),
            SizedBox(height: 16),
            Text(
              item.texto,
              style: Theme.of(context).textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}