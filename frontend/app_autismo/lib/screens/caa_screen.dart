import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:app_autismo/services/caa_service.dart';
import 'package:app_autismo/screens/create_board_screen.dart';
import 'package:app_autismo/screens/board_detail_screen.dart';
import 'package:app_autismo/models/caa_model.dart';

class CaaScreen extends StatefulWidget {
  const CaaScreen({Key? key}) : super(key: key);

  @override
  _CaaScreenState createState() => _CaaScreenState();
}

class _CaaScreenState extends State<CaaScreen> {
  late Future _boardsFuture;

  @override
  void initState() {
    super.initState();
    _boardsFuture = _fetchData();
  }

  Future<void> _fetchData() {
    if (!mounted) return Future.value();
    return Provider.of<CaaService>(context, listen: false).fetchBoards();
  }

  void _navigateToCreateScreen(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (ctx) => CreateBoardScreen(),
      ),
    ).then((_) {
      setState(() {
        _boardsFuture = _fetchData();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Pranchas de Comunicação'),
      ),
      body: FutureBuilder(
        future: _boardsFuture,
        builder: (ctx, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.error != null) {
            return Center(child: Text('Erro ao carregar pranchas.'));
          } else {
            return Consumer<CaaService>(
              builder: (ctx, caaService, child) {
                if (caaService.boards.isEmpty) {
                  return Center(child: Text('Nenhuma prancha encontrada.'));
                }

                return ListView.builder(
                  itemCount: caaService.boards.length,
                  itemBuilder: (ctx, i) {
                    final board = caaService.boards[i];
                    return ListTile(
                      title: Text(board.nome),
                      subtitle: Text('${board.items.length} cartões'),
                      leading: Icon(Icons.dashboard_rounded),
                      trailing: Icon(Icons.arrow_forward_ios),
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => BoardDetailScreen(board: board),
                          ),
                        );
                      },
                    );
                  },
                );
              },
            );
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navigateToCreateScreen(context),
        child: Icon(Icons.add),
      ),
    );
  }
}