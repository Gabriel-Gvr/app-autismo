import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:app_autismo/services/auth_service.dart';
import 'package:app_autismo/services/routine_service.dart';
import 'package:app_autismo/services/diary_service.dart';
import 'package:app_autismo/services/caa_service.dart';
import 'package:app_autismo/services/report_service.dart';
import 'package:app_autismo/services/share_service.dart';
import 'package:app_autismo/services/psychologist_service.dart'; 
import 'package:app_autismo/services/crisis_service.dart'; 
import 'package:app_autismo/screens/login_screen.dart';
import 'package:app_autismo/screens/home_screen.dart';
import 'package:app_autismo/screens/psychologist_home_screen.dart';
import 'package:intl/date_symbol_data_local.dart';

void main() {
  initializeDateFormatting('pt_BR', null).then((_) {
    runApp(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (context) => AuthService()),
          ChangeNotifierProxyProvider<AuthService, RoutineService>(
            create: (context) => RoutineService(null),
            update: (context, auth, previous) => RoutineService(auth.token),
          ),
          ChangeNotifierProxyProvider<AuthService, DiaryService>(
            create: (context) => DiaryService(null),
            update: (context, auth, previous) => DiaryService(auth.token),
          ),
          ChangeNotifierProxyProvider<AuthService, CaaService>(
            create: (context) => CaaService(null),
            update: (context, auth, previous) => CaaService(auth.token),
          ),
          ChangeNotifierProxyProvider<AuthService, PsychologistService>(
            create: (context) => PsychologistService(null),
            update: (context, auth, previous) => PsychologistService(auth.token),
          ),
          ChangeNotifierProxyProvider<AuthService, ReportService>(
            create: (context) => ReportService(null),
            update: (context, auth, previous) => ReportService(auth.token),
          ),
          ChangeNotifierProxyProvider<AuthService, ShareService>(
            create: (context) => ShareService(null),
            update: (context, auth, previous) => ShareService(auth.token),
          ),
          ChangeNotifierProvider(create: (context) => CrisisService()),
        ],
        child: MyApp(),
      ),
    );
  });
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'App Autismo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: AuthWrapper(), 
      locale: Locale('pt', 'BR'),
    );
  }
}

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({Key? key}) : super(key: key);

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  late Future<bool> _autoLoginFuture;

  @override
  void initState() {
    super.initState();
    _autoLoginFuture = Provider.of<AuthService>(context, listen: false)
        .tryAutoLogin();
  }

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);

    if (authService.isAuthenticated) {
      if (authService.role == 'psicologo') {
        return PsychologistHomeScreen();
      } else {
        return HomeScreen();
      }
    }

    return FutureBuilder(
      future: _autoLoginFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          
          return Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        
        return LoginScreen();
      },
    );
  }
}