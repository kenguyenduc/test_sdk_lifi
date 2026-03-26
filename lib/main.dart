import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'bloc/bridge_bloc.dart';
import 'screens/bridge_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => BridgeBloc(),
      child: MaterialApp(
        title: 'LI.FI Bridge',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          brightness: Brightness.dark,
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF6C5CE7),
            brightness: Brightness.dark,
          ),
          fontFamily: 'Roboto',
          scaffoldBackgroundColor: const Color(0xFF0D0D1A),
        ),
        home: const BridgeScreen(),
      ),
    );
  }
}
