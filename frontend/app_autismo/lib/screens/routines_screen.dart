import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:app_autismo/services/routine_service.dart';
import 'package:app_autismo/models/routine_model.dart';
import 'package:app_autismo/screens/create_routine_screen.dart'; 
import 'package:app_autismo/screens/routine_detail_screen.dart';

class RoutinesScreen extends StatefulWidget {
  const RoutinesScreen({Key? key}) : super(key: key);

  @override
  _RoutinesScreenState createState() => _RoutinesScreenState();
}

class _RoutinesScreenState extends State<RoutinesScreen> {
  late Future _routinesFuture;

  @override
  void initState() {
    super.initState();
    _routinesFuture = _fetchData();
  }

  Future<void> _fetchData() {
    return Provider.of<RoutineService>(context, listen: false).fetchRoutines();
  }

  void _navigateToCreateScreen(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (ctx) => CreateRoutineScreen(),
      ),
    ).then((_) {
      setState(() {
        _routinesFuture = _fetchData();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Minhas Rotinas'),
      ),
      body: FutureBuilder(
        future: _routinesFuture,
        builder: (ctx, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.error != null) {
            return Center(child: Text('Erro ao carregar rotinas.'));
          } else {
            return Consumer<RoutineService>(
              builder: (ctx, routineService, child) {
                if (routineService.routines.isEmpty) {
                  return Center(child: Text('Nenhuma rotina encontrada.'));
                }
                
                return ListView.builder(
                  itemCount: routineService.routines.length,
                  itemBuilder: (ctx, i) {
                    final routine = routineService.routines[i];
                   return ListTile(
                      title: Text(routine.titulo),
                      subtitle: Text('${routine.steps.length} passos'),
                      leading: Icon(Icons.list_alt),
                      trailing: Icon(Icons.arrow_forward_ios),
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => RoutineDetailScreen(routine: routine),
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