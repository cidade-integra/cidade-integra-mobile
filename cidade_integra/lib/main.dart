import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:go_router/go_router.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'firebase_options.dart';
import 'providers/auth_provider.dart';
import 'utils/app_theme.dart';
import 'routes/app_router.dart';
import 'screens/splash_screen.dart';
import 'services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await initializeDateFormatting('pt_BR');

  await Supabase.initialize(
    url: 'https://fyjefwpyesgedvfuewiw.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImZ5amVmd3B5ZXNnZWR2ZnVld2l3Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDk0OTMyODQsImV4cCI6MjA2NTA2OTI4NH0.KVm_djZHkih9CKVXrPPtb2ZHiVzHhNNtYctpR2KCXsw',
  );

  await GoogleSignIn.instance.initialize(
    serverClientId:
        '677900581774-j5k91404i5por2tm6vgstb3fco0hatsd.apps.googleusercontent.com',
  );

  await NotificationService().initialize();

  final authProvider = AuthProvider();
  final router = buildRouter(authProvider);

  runApp(CidadeIntegraApp(authProvider: authProvider, router: router));
}

class CidadeIntegraApp extends StatefulWidget {
  final AuthProvider authProvider;
  final GoRouter router;

  const CidadeIntegraApp({
    super.key,
    required this.authProvider,
    required this.router,
  });

  @override
  State<CidadeIntegraApp> createState() => _CidadeIntegraAppState();
}

class _CidadeIntegraAppState extends State<CidadeIntegraApp> {
  bool _showSplash = true;

  @override
  Widget build(BuildContext context) {
    if (_showSplash) {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        home: SplashScreen(
          onComplete: () => setState(() => _showSplash = false),
        ),
      );
    }

    return ChangeNotifierProvider.value(
      value: widget.authProvider,
      child: MaterialApp.router(
        title: 'Cidade Integra',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        routerConfig: widget.router,
      ),
    );
  }
}
