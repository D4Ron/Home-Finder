import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_sizes.dart';
import '../../core/constants/app_strings.dart';
import '../../core/utils/validators.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/common/app_button.dart';
import '../../widgets/common/app_text_field.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey   = GlobalKey<FormState>();
  final _nameCtrl  = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passCtrl  = TextEditingController();
  final _phoneCtrl = TextEditingController();
  String _selectedRole = 'USER';

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passCtrl.dispose();
    _phoneCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final auth = context.read<AuthProvider>();
    auth.clearError();

    final ok = await auth.register(
      name:     _nameCtrl.text.trim(),
      email:    _emailCtrl.text.trim(),
      password: _passCtrl.text,
      phone: _phoneCtrl.text.trim().isEmpty ? null : _phoneCtrl.text.trim(),
      role: _selectedRole,
    );

    if (!mounted) return;

    if (ok) {
      // Auth gate in main.dart will auto-navigate to HomeScreen.
      // Pop the register screen so back stack is clean.
      Navigator.of(context).popUntil((route) => route.isFirst);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(auth.error ?? AppStrings.errorGeneric),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 4),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Stack(
        children: [
          SizedBox.expand(
            child: Image.asset(
              'assets/images/welcome_screen.jpg',
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(color: AppColors.primary),
            ),
          ),
          Container(color: AppColors.primary.withOpacity(0.65)),

          SafeArea(
            child: Column(
              children: [
                // Header bar
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                      AppSizes.sm, AppSizes.sm, AppSizes.md, 0),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back,
                            color: AppColors.textWhite),
                        onPressed: () => Navigator.pop(context),
                      ),
                      const Expanded(
                        child: Text(
                          'Créer un compte',
                          style: TextStyle(
                            color: AppColors.textWhite,
                            fontSize: AppSizes.fontXl,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const SizedBox(width: 48),
                    ],
                  ),
                ),

                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(AppSizes.lg),
                    child: Column(
                      children: [
                        const SizedBox(height: AppSizes.md),
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
                                  controller: _nameCtrl,
                                  label: AppStrings.name,
                                  textInputAction: TextInputAction.next,
                                  prefixIcon:
                                  const Icon(Icons.person_outline),
                                  validator: Validators.name,
                                ),
                                const SizedBox(height: AppSizes.md),
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
                                  controller: _phoneCtrl,
                                  label: '${AppStrings.phone} (optionnel)',
                                  keyboardType: TextInputType.phone,
                                  textInputAction: TextInputAction.next,
                                  prefixIcon:
                                  const Icon(Icons.phone_outlined),
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
                                ),
                                const SizedBox(height: AppSizes.md),

                                // Role selection
                                const Text(
                                  'Type de compte',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: AppSizes.fontSm,
                                    color: AppColors.textGrey,
                                  ),
                                ),
                                const SizedBox(height: AppSizes.sm),
                                Row(
                                  children: [
                                    _RoleChip(
                                      label: 'Particulier',
                                      value: 'USER',
                                      selected: _selectedRole == 'USER',
                                      onTap: () => setState(
                                              () => _selectedRole = 'USER'),
                                    ),
                                    const SizedBox(width: AppSizes.sm),
                                    _RoleChip(
                                      label: 'Agent / Agence',
                                      value: 'AGENT',
                                      selected: _selectedRole == 'AGENT',
                                      onTap: () => setState(
                                              () => _selectedRole = 'AGENT'),
                                    ),
                                  ],
                                ),

                                const SizedBox(height: AppSizes.lg),
                                Consumer<AuthProvider>(
                                  builder: (_, auth, __) => AppButton(
                                    label: AppStrings.register,
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
                            const Text(AppStrings.hasAccount,
                                style: TextStyle(color: Colors.white70)),
                            GestureDetector(
                              onTap: () => Navigator.pop(context),
                              child: const Text(
                                AppStrings.login,
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
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _RoleChip extends StatelessWidget {
  final String label;
  final String value;
  final bool selected;
  final VoidCallback onTap;
  const _RoleChip({
    required this.label,
    required this.value,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: AppSizes.sm),
          decoration: BoxDecoration(
            color: selected ? AppColors.primary : AppColors.background,
            borderRadius: BorderRadius.circular(AppSizes.radiusMd),
            border: Border.all(
              color: selected ? AppColors.primary : AppColors.textLight,
              width: selected ? 2 : 1,
            ),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: selected ? AppColors.textWhite : AppColors.textDark,
              fontWeight: FontWeight.w600,
              fontSize: AppSizes.fontSm,
            ),
          ),
        ),
      ),
    );
  }
}