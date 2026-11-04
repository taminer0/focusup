import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../core/app_colors.dart';
import '../../core/app_text_styles.dart';
import '../../core/app_theme.dart';
import '../../widgets/primary_button.dart';
import 'login_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();

  @override
  void dispose() {
    _usernameCtrl.dispose();
    _passwordCtrl.dispose();
    _confirmCtrl.dispose();
    _emailCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    // TODO: gọi API đăng ký khi có backend
    _goToLogin();
  }

  void _goToLogin() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final keyboard = MediaQuery.of(context).viewInsets.bottom;

    return Scaffold(
      backgroundColor: AppColors.backgroundSecondary,
      // false: lá trang trí đứng yên khi bật bàn phím
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          // ================= LÁ TRANG TRÍ (nằm dưới nội dung) =================
          _leaf(
            asset: 'assets/images/Latim2.svg',
            width: size.width * 0.7,
            top: 0,
            left: 0,
          ),
          _leaf(
            asset: 'assets/images/Cumla2.svg',
            width: size.width * 0.3,
            top: size.height * 0.03,
            right: 0,
          ),
          _leaf(
            asset: 'assets/images/Laxanh2.svg',
            width: size.width * 0.85,
            // Số âm = đẩy lá xuống. Lá chưa chạm đáy thì tăng 0.10 lên 0.13...
            bottom: -size.height * 0.02,
            right: 0,
          ),
          _leaf(
            asset: 'assets/images/ladon2.svg',
            width: size.width * 0.2,
            bottom: size.height * 0.12,
            left: 0,
          ),

          // ======================= NỘI DUNG =======================
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
                        padding: const EdgeInsets.symmetric(horizontal: 32),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            children: [
                              const Spacer(flex: 2),
                              Text('Đăng Ký', style: AppTheme.logo(size: 34)),
                              const Spacer(flex: 2),

                              // ---------- 4 ô nhập ----------
                              _field(
                                controller: _usernameCtrl,
                                hint: 'Tên đăng nhập',
                                validator: (v) =>
                                (v == null || v.trim().isEmpty)
                                    ? 'Vui lòng nhập tên đăng nhập'
                                    : null,
                              ),
                              const SizedBox(height: 14),
                              _field(
                                controller: _passwordCtrl,
                                hint: 'Nhập mật khẩu',
                                obscure: true,
                                validator: (v) => (v == null || v.length < 6)
                                    ? 'Mật khẩu tối thiểu 6 ký tự'
                                    : null,
                              ),
                              const SizedBox(height: 14),
                              _field(
                                controller: _confirmCtrl,
                                hint: 'Nhập lại mật khẩu',
                                obscure: true,
                                validator: (v) => v != _passwordCtrl.text
                                    ? 'Mật khẩu nhập lại không khớp'
                                    : null,
                              ),
                              const SizedBox(height: 14),
                              _field(
                                controller: _emailCtrl,
                                hint: 'Nhập Email',
                                keyboardType: TextInputType.emailAddress,
                                validator: (v) {
                                  final ok =
                                  RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$')
                                      .hasMatch(v?.trim() ?? '');
                                  return ok ? null : 'Email không hợp lệ';
                                },
                              ),

                              const Spacer(flex: 1),

                              // ---------- Nút Đăng Ký ----------
                              SizedBox(
                                height: 48,
                                child: PrimaryButton(
                                  text: 'Đăng Ký',
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

                              const SizedBox(height: 5),

                              // ---------- Chuyển sang Đăng nhập ----------
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text('Đã có tài khoản?',
                                      style: AppTextStyles.caption),
                                  TextButton(
                                    onPressed: _goToLogin,
                                    child: const Text('Đăng nhập'),
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

  /// Một lá trang trí. IgnorePointer để lá không chặn thao tác chạm.
  Widget _leaf({
    required String asset,
    required double width,
    double? top,
    double? bottom,
    double? left,
    double? right,
  }) {
    return Positioned(
      top: top,
      bottom: bottom,
      left: left,
      right: right,
      child: IgnorePointer(
        child: SvgPicture.asset(asset, width: width),
      ),
    );
  }

  /// Ô nhập chỉ có gợi ý (hint) ở giữa, giống Figma.
  Widget _field({
    required TextEditingController controller,
    required String hint,
    bool obscure = false,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscure,
      keyboardType: keyboardType,
      validator: validator,
      textAlign: TextAlign.center,
      style: AppTextStyles.body,
      decoration: InputDecoration(
        hintText: hint,
        isDense: true,
        contentPadding:
        const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
    );
  }
}