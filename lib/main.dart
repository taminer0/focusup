import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'core/app_theme.dart';

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
      theme: AppTheme.light,
      home: Scaffold(
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('FocusUp', style: AppTheme.logo()),
              const SizedBox(height: 24),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: ElevatedButton(
                  onPressed: () {},
                  child: const Text('Đăng nhập'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}