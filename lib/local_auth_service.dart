// ignore_for_file: depend_on_referenced_packages

import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';
import 'package:local_auth_ios/local_auth_ios.dart';
import 'package:local_auth_android/local_auth_android.dart';
import 'package:local_auth/error_codes.dart' as auth_error;

class LocalAuthService {
  static final _auth = LocalAuthentication();

  static Future<bool> hasSupport({bool biometricOnly = true}) async {
    //Verifica se o dispositivo possui suporte a autenticação biométrica
    final bool canCheck = await _auth.canCheckBiometrics;

    if (biometricOnly && !canCheck) return false; //Não há suporte biométrico

    //Verifica se o dispositivo suporta qualquer outro tipo de autenticação (Senha, PIN, Padrão,...)
    final bool hasSupport = await _auth.isDeviceSupported();

    return canCheck || hasSupport; //Caso algum deles for verdadeira, haverá suporte
  }

  static Future<bool> authenticate({String? message, bool biometricOnly = true}) async {
    try {
      final isAuthenticated = await _auth.authenticate(
        localizedReason: message ?? 'Por favor, realize a autenticação biométrica', //Motivo da solicitação de autenticação
        //Personalização das mensagens do Dialog de autenticação
        authMessages: [
          const AndroidAuthMessages(
            cancelButton: 'Cancelar',
            signInTitle: 'Autenticação Biométrica',
            biometricHint: '',
            biometricNotRecognized: 'Biometria não reconhecida',
            biometricRequiredTitle: 'Cadastro de Biometria',
            biometricSuccess: 'Autenticado',
            deviceCredentialsRequiredTitle: '',
            deviceCredentialsSetupDescription: '',
            goToSettingsButton: 'Configurações',
            goToSettingsDescription: 'Não há nenhuma biometria cadastrada. Você deseja ir para as configurações e cadastrar uma nova?',
          ),
          const IOSAuthMessages(
              //Mensagens para o iOS
              ),
        ],
        //Demais opções para a autenticação
        options: AuthenticationOptions(
          biometricOnly: biometricOnly, //Se for true, aceitará apenas biometria/Face ID
          stickyAuth: true, //Se for true, caso o app vá para segundo plano enquanto estava tentando autenticar, ao retornar para primeiro plano, o app vai tentar retomar a autenticação
          useErrorDialogs: true, //Se for true, em alguns casos vai tentar exibir um Dialog com "tratamentos de erros" já pré-definidos (como não ter nenhuma biometria cadastrada no dispositivo, por exemplo)
          sensitiveTransaction: false, //Se for true, em casos onde o reconhecimento facial é utilizado para desbloqueio, ainda há uma confirmação por Dialog que o usuário deve confirmar
        ),
      );

      return isAuthenticated;
    } on PlatformException catch (err) {
      if (err.code == auth_error.notAvailable) {
        throw Exception('Nenhum tipo de autenticação cadastrada');
      }
      if (err.code == auth_error.notEnrolled) {
        //Nenhuma biometria cadastrada. Utilizado especialmente quando biometricOnly == true
      }

      return false;
    }
  }

  static Future<bool> hasAvailableBiometrics() async {
    return (await _auth.getAvailableBiometrics()).isNotEmpty;
  }
}
