import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:app_autismo/services/auth_service.dart';
import 'package:app_autismo/screens/routines_screen.dart';
import 'package:app_autismo/screens/diary_screen.dart';
import 'package:app_autismo/screens/caa_screen.dart';
import 'package:app_autismo/screens/reports_screen.dart';
import 'package:app_autismo/screens/share_screen.dart';
import 'package:app_autismo/screens/crisis_screen.dart'; 

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        title: Text('Início'),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () {
              authService.logout();
            },
          ),
        ],
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch, 
            children: [
              Text(
                'Bem-vindo!',
                style: Theme.of(context).textTheme.headlineSmall,
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 30),

              ElevatedButton.icon(
                icon: Icon(Icons.list_alt),
                label: Text('Ver Minhas Rotinas'),
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => RoutinesScreen()),
                  );
                },
              ),
              SizedBox(height: 12),
              
              ElevatedButton.icon(
                icon: Icon(Icons.book),
                label: Text('Ver Diário'),
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => DiaryScreen()),
                  );
                },
              ),
              SizedBox(height: 12),
              
              ElevatedButton.icon(
                icon: Icon(Icons.dashboard_rounded),
                label: Text('Ver Pranchas (CAA)'),
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => CaaScreen()),
                  );
                },
              ),
              SizedBox(height: 12),
              
              ElevatedButton.icon(
                icon: Icon(Icons.bar_chart),
                label: Text('Ver Relatórios'),
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => ReportsScreen()),
                  );
                },
              ),
              SizedBox(height: 12),
              
              ElevatedButton.icon(
                icon: Icon(Icons.share),
                label: Text('Compartilhar com Profissional'),
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => ShareScreen()),
                  );
                },
              ),

              SizedBox(height: 40), 
              
              SizedBox(
                height: 55, 
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red, 
                    foregroundColor: Colors.white, 
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 5,
                  ),
                  icon: Icon(Icons.warning_amber_rounded, size: 28),
                  label: Text(
                    'MODO CRISE', 
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)
                  ),
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (context) => CrisisScreen()),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}