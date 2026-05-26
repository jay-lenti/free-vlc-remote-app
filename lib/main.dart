import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/vlc_provider.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => VlcProvider()),
      ],
      child: const VlcRemoteApp(),
    ),
  );
}

class VlcRemoteApp extends StatelessWidget {
  const VlcRemoteApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'VLC Remote',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.orange),
        useMaterial3: true,
        brightness: Brightness.light,
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.orange, brightness: Brightness.dark),
        useMaterial3: true,
        brightness: Brightness.dark,
      ),
      home: const HomeScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
