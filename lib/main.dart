import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'auth/auth_cubit.dart';
import 'auth/auth_service.dart';
import 'firebase_options.dart';
import 'products/product_cubit.dart';
import 'products/product_service.dart';
import 'screens/auth_gate.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(const StocklyApp());
}

class StocklyApp extends StatelessWidget {
  const StocklyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<AuthService>(create: (_) => AuthService()),
        RepositoryProvider<ProductService>(create: (_) => ProductService()),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider<AuthCubit>(
            create: (context) => AuthCubit(context.read<AuthService>()),
          ),
          BlocProvider<ProductCubit>(
            create: (context) => ProductCubit(context.read<ProductService>()),
          ),
        ],
        child: MaterialApp(
          title: 'Stockly',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            useMaterial3: true,
            colorScheme: ColorScheme.fromSeed(
              seedColor: const Color(0xFFFF5A1F),
              primary: const Color(0xFFFF5A1F),
              surface: Colors.white,
            ),
            scaffoldBackgroundColor: const Color(0xFFF7F7F9),
            appBarTheme: const AppBarTheme(centerTitle: false, elevation: 0),
            inputDecorationTheme: InputDecorationTheme(
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          ),
          home: const AuthGate(),
        ),
      ),
    );
  }
}
