import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_sizes.dart';
import '../../core/constants/app_strings.dart';
import '../../core/utils/validators.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/common/app_button.dart';
import '../../widgets/common/app_text_field.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey   = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passCtrl  = TextEditingController();

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final auth = context.read<AuthProvider>();
    auth.clearError();

    final ok = await auth.login(
      email: _emailCtrl.text.trim(),
      password: _passCtrl.text,
    );

    // Navigation is handled automatically by the Consumer<AuthProvider>
    // in main.dart — when auth.authenticated becomes true, HomeScreen appears.
    if (!ok && mounted) {
      _showError(auth.error ?? AppStrings.errorGeneric);
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 4),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Stack(
        children: [
          // Background
          SizedBox.expand(
            child: Image.asset(
              'assets/images/welcome_screen.jpg',
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(color: AppColors.primary),
            ),
          ),
          Container(color: AppColors.primary.withOpacity(0.65)),

          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppSizes.lg),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: AppSizes.xxl),

                    // Logo
                    const Icon(Icons.home_work_rounded,
                        color: Colors.white, size: 56),
                    const SizedBox(height: AppSizes.sm),
                    const Text(
                      AppStrings.appName,
                      style: TextStyle(
                        color: AppColors.textWhite,
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1,
                      ),
                    ),
                    const SizedBox(height: AppSizes.xs),
                    const Text(
                      'Connexion',
                      style: TextStyle(
                          color: Colors.white70, fontSize: AppSizes.fontLg),
                    ),
                    const SizedBox(height: AppSizes.xxl),

                    // Form card
                    Container(
                      padding: const EdgeInsets.all(AppSizes.lg),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius:
                        BorderRadius.circular(AppSizes.radiusXl),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.15),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          )
                        ],
                      ),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            AppTextField(
                              controller: _emailCtrl,
                              label: AppStrings.email,
                              keyboardType: TextInputType.emailAddress,
                              textInputAction: TextInputAction.next,
                              prefixIcon:
                              const Icon(Icons.email_outlined),
                              validator: Validators.email,
                            ),
                            const SizedBox(height: AppSizes.md),
                            AppTextField(
                              controller: _passCtrl,
                              label: AppStrings.password,
                              obscure: true,
                              textInputAction: TextInputAction.done,
                              prefixIcon:
                              const Icon(Icons.lock_outline),
                              validator: Validators.password,
                              onSubmitted: (_) => _submit(),
                            ),
                            const SizedBox(height: AppSizes.lg),
                            Consumer<AuthProvider>(
                              builder: (_, auth, __) => AppButton(
                                label: AppStrings.login,
                                onPressed: _submit,
                                loading: auth.loading,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: AppSizes.lg),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(AppStrings.noAccount,
                            style: TextStyle(color: Colors.white70)),
                        GestureDetector(
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const RegisterScreen()),
                          ),
                          child: const Text(
                            AppStrings.register,
                            style: TextStyle(
                              color: AppColors.textWhite,
                              fontWeight: FontWeight.bold,
                              decoration: TextDecoration.underline,
                              decorationColor: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSizes.xxl),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}