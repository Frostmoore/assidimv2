import 'package:Assidim/core/providers/app_provider.dart';
import 'package:Assidim/sections/account.dart';
import 'package:Assidim/sections/login_form.dart';
import 'package:Assidim/sections/responses/codice_agenzia_errato.dart';
import 'package:Assidim/sections/responses/general_error.dart';
import 'package:Assidim/sections/responses/login_fallito.dart';
import 'package:Assidim/sections/responses/password_dimenticata.dart';
import 'package:Assidim/sections/responses/register_success.dart';
import 'package:Assidim/sections/responses/reset_password.dart';
import 'package:Assidim/sections/responses/user_already_exists.dart';
import 'package:Assidim/sections/responses/utente_non_attivo.dart';
import 'package:Assidim/sections/register_form.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/// Seleziona quale widget mostrare nella tab Account
/// in base allo stato di autenticazione nel Provider.
/// Sostituisce il vecchio meccanismo basato sull'int globale `userStatus`
/// e le callback `logParent()` a cascata.
class AccountContainer extends StatelessWidget {
  const AccountContainer({super.key});

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AppProvider>().authState;

    return switch (authState) {
      AuthState.authenticated        => const AccountPage(),
      AuthState.registering          => const RegisterForm(),
      AuthState.userAlreadyExists    => const UserAlreadyExists(),
      AuthState.wrongAgencyCode      => const CodiceAgenziaErrato(),
      AuthState.registrationSuccess  => const RegisterSuccess(),
      AuthState.passwordReset        => const ResetPassword(),
      AuthState.inactiveUser         => const UtenteNonAttivo(),
      AuthState.loginFailed          => const LoginFallito(),
      AuthState.forgotPassword       => const PasswordDimenticata(),
      AuthState.error                => const GeneralError(),
      AuthState.unauthenticated      => const LoginForm(),
    };
  }
}
