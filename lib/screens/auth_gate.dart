import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../auth/auth_cubit.dart';
import '../auth/auth_state.dart';
import 'login_screen.dart';
import 'product_home_screen.dart';
import 'splash_screen.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, state) {
        if (state is AuthInitial || state is AuthLoading) {
          return const SplashScreen();
        }

        if (state is Authenticated) {
          return const ProductHomeScreen();
        }

        return const LoginScreen();
      },
    );
  }
}
