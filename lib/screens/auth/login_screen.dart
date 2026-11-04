import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../core/app_colors.dart';
import '../../core/app_text_styles.dart';
import '../../widgets/primary_button.dart';
import '../main_shell.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _accountCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();

  @override
  void dispose() {
    _accountCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    // TODO: gọi API đăng nhập khi có backend
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const MainShell()),
    );
  }

  void _goToRegister() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const MainShell()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final keyboard = MediaQuery.of(context).viewInsets.bottom;

    return Scaffold(
      backgroundColor: AppColors.backgroundSecondary,
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          // Lá trang trí góc trên phải
          Positioned(
            top: size.height * 0.04,
            right: 0,
            child: IgnorePointer(
              child: SvgPicture.asset(
                'assets/images/La3.svg',
                width: size.width * 0.35,
              ),
            ),
          ),

          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  padding: EdgeInsets.only(bottom: keyboard),
                  child: ConstrainedBox(
                    constraints:
                    BoxConstraints(minHeight: constraints.maxHeight),
                    child: IntrinsicHeight(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 28),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Spacer(flex: 2),

                              // ---------- Tiêu đề ----------
                              Text(
                                'Chào mừng bạn\nđến với FocusUp',
                                style: AppTextStyles.title.copyWith(
                                  fontSize: 29,
                                  height: 1.25,
                                  color: AppColors.text,
                                ),
                              ),
                              const SizedBox(height: 15),
                              Text(
                                'Cùng xây dựng thói quen tốt mỗi ngày nhé!',
                                style: AppTextStyles.body.copyWith(
                                  fontSize: 18,
                                  color: AppColors.textSecondary,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),

                              const Spacer(flex: 1),

                              // ---------- Ô nhập ----------
                              _field(
                                controller: _accountCtrl,
                                hint: 'Email hoặc số điện thoại',
                                iconAsset: 'assets/icons/person.svg',
                                keyboardType: TextInputType.emailAddress,
                                validator: (v) =>
                                (v == null || v.trim().isEmpty)
                                    ? 'Vui lòng nhập email hoặc số điện thoại'
                                    : null,
                              ),
                              const SizedBox(height: 20),
                              _field(
                                controller: _passwordCtrl,
                                hint: 'Mật khẩu',
                                iconAsset: 'assets/icons/lock.svg',
                                obscure: true,
                                validator: (v) => (v == null || v.length < 6)
                                    ? 'Mật khẩu tối thiểu 6 ký tự'
                                    : null,
                              ),

                              const Spacer(flex: 1),

                              // ---------- Nút Đăng Nhập ----------
                              SizedBox(
                                width: double.infinity,
                                height: 48,
                                child: PrimaryButton(
                                  text: 'Đăng Nhập',
                                  onPressed: _submit,
                                ),
                              ),

                              const Spacer(flex: 1),

                              // ---------- Hoặc ----------
                              Row(
                                children: [
                                  const Expanded(child: Divider()),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 16),
                                    child: Text(
                                      'Hoặc',
                                      style: AppTextStyles.caption.copyWith(
                                          color: AppColors.textTertiary),
                                    ),
                                  ),
                                  const Expanded(child: Divider()),
                                ],
                              ),

                              const Spacer(flex: 1),

                              // ---------- Nút Google ----------
                              SizedBox(
                                width: double.infinity,
                                height: 48,
                                child: OutlinedButton.icon(
                                  onPressed: () {
                                    // TODO: đăng nhập Google
                                  },
                                  icon: Image.asset(
                                    'assets/images/google.png',
                                    height: 20,
                                  ),
                                  label: const Text('Tiếp tục với Google'),
                                ),
                              ),

                              const SizedBox(height: 10),

                              // ---------- Chuyển sang Đăng ký ----------
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text('Bạn chưa có tài khoản ?',
                                      style: AppTextStyles.caption),
                                  TextButton(
                                    onPressed: _goToRegister,
                                    child: const Text('Đăng ký'),
                                  ),
                                ],
                              ),

                              const Spacer(flex: 2),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  /// Ô nhập có icon SVG bên trái, chữ gợi ý căn trái.
  Widget _field({
    required TextEditingController controller,
    required String hint,
    required String iconAsset,
    bool obscure = false,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscure,
      keyboardType: keyboardType,
      validator: validator,
      style: AppTextStyles.body,
      decoration: InputDecoration(
        hintText: hint,
        isDense: true,
        contentPadding:
        const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        prefixIcon: Padding(
          padding: const EdgeInsets.all(14),
          child: SvgPicture.asset(
            iconAsset,
            width: 22,
            height: 22,
            colorFilter: const ColorFilter.mode(
                AppColors.textSecondary, BlendMode.srcIn),
          ),
        ),
        prefixIconConstraints: const BoxConstraints(minWidth: 50),
      ),
    );
  }
}