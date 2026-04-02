import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:go_router/go_router.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'providers/auth_provider.dart';
import 'utils/app_theme.dart';
import 'routes/app_router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // TODO: substituir pelo Web Client ID do Firebase Console
  await GoogleSignIn.instance.initialize(
    serverClientId: const String.fromEnvironment('GOOGLE_SERVER_CLIENT_ID'),
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
