import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);
  runApp(const FocusUpApp());
}

class FocusUpApp extends StatelessWidget {
  const FocusUpApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FocusUp',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorSchemeSeed: const Color(0xFF2F6B4F),
        useMaterial3: true,
      ),
      home: const Scaffold(
        body: Center(child: Text('FocusUp')),
      ),
    );
  }
}