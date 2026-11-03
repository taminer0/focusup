import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'core/app_theme.dart';
import 'widgets/primary_button.dart';
import 'widgets/app_text_field.dart';

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
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Đăng ký', style: AppTheme.logo(size: 32)),
                const SizedBox(height: 24),
                const AppTextField(
                  label: 'Email',
                  hint: 'Nhập email của bạn',
                  prefixIcon: Icons.email_outlined,
                ),
                const SizedBox(height: 16),
                const AppTextField(
                  label: 'Mật khẩu',
                  hint: 'Nhập mật khẩu',
                  isPassword: true,
                ),
                const SizedBox(height: 24),
                PrimaryButton(text: 'Đăng ký', onPressed: () {}),
              ],
            ),
          ),
        ),
      ),
    );
  }
}