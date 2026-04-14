import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:go_router/go_router.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'firebase_options.dart';
import 'providers/auth_provider.dart';
import 'utils/app_theme.dart';
import 'routes/app_router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  await Supabase.initialize(
    url: 'https://fyjefwpyesgedvfuewiw.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImZ5amVmd3B5ZXNnZWR2ZnVld2l3Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDk0OTMyODQsImV4cCI6MjA2NTA2OTI4NH0.KVm_djZHkih9CKVXrPPtb2ZHiVzHhNNtYctpR2KCXsw',
  );

  await GoogleSignIn.instance.initialize(
    serverClientId:
        '677900581774-j5k91404i5por2tm6vgstb3fco0hatsd.apps.googleusercontent.com',
  );

  final authProvider = AuthProvider();
  final router = buildRouter(authProvider);

  runApp(CidadeIntegraApp(authProvider: authProvider, router: router));
}

class CidadeIntegraApp extends StatelessWidget {
  final AuthProvider authProvider;
  final GoRouter router;

  const CidadeIntegraApp({
    super.key,
    required this.authProvider,
    required this.router,
  });

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: authProvider,
      child: MaterialApp.router(
        title: 'Cidade Integra',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        routerConfig: router,
      ),
    );
  }
}
