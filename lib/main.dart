import 'package:flutter/material.dart';
import 'package:flutter_localauth/local_auth_service.dart';

void main() => runApp(const LocalAuthApp());

class LocalAuthApp extends StatefulWidget {
  const LocalAuthApp({super.key});

  @override
  State<LocalAuthApp> createState() => _LocalAuthAppState();
}

class _LocalAuthAppState extends State<LocalAuthApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Local Auth App',
      theme: ThemeData.dark(),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  void onAuthenticate() async {
    try {
      if (!await LocalAuthService.hasSupport(biometricOnly: true)) {
        showMessage('O dispositivo não possui suporte a biometria');
        return;
      }

      if (!await LocalAuthService.authenticate(biometricOnly: true)) {
        showMessage('Autenticação não reconhecida');
        return;
      }

      showMessage('Usuário autenticado');
      //Restante do código
    } catch (_) {
      showMessage('Erro ao realizar autenticação');
    }
  }

  void showMessage(String message) {
    ScaffoldMessenger.of(context).clearSnackBars();

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Local Auth App'),
        centerTitle: true,
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: onAuthenticate,
          child: const Text('Request Auth'),
        ),
      ),
    );
  }
}
