import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_sizes.dart';
import '../../core/constants/app_strings.dart';
import '../../core/utils/validators.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/common/app_button.dart';
import '../../widgets/common/app_text_field.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey     = GlobalKey<FormState>();
  late final TextEditingController _nameCtrl;
  late final TextEditingController _phoneCtrl;
  late final TextEditingController _bioCtrl;
  late final TextEditingController _addressCtrl;

  @override
  void initState() {
    super.initState();
    final user = context.read<AuthProvider>().user;
    _nameCtrl    = TextEditingController(text: user?.name);
    _phoneCtrl   = TextEditingController(text: user?.phoneNumber);
    _bioCtrl     = TextEditingController(text: user?.bio);
    _addressCtrl = TextEditingController(text: user?.address);
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _bioCtrl.dispose();
    _addressCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final auth = context.read<AuthProvider>();
    final ok = await auth.updateProfile(
      name:    _nameCtrl.text.trim(),
      phone:   _phoneCtrl.text.trim().isEmpty ? null : _phoneCtrl.text.trim(),
      bio:     _bioCtrl.text.trim().isEmpty ? null : _bioCtrl.text.trim(),
      address: _addressCtrl.text.trim().isEmpty ? null : _addressCtrl.text.trim(),
    );
    if (!mounted) return;
    if (ok) {
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(auth.error ?? AppStrings.errorGeneric),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.editProfile,
            style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSizes.lg),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              AppTextField(
                controller: _nameCtrl,
                label: AppStrings.name,
                prefixIcon: const Icon(Icons.person_outline),
                textInputAction: TextInputAction.next,
                validator: Validators.name,
              ),
              const SizedBox(height: AppSizes.md),
              AppTextField(
                controller: _phoneCtrl,
                label: AppStrings.phone,
                keyboardType: TextInputType.phone,
                prefixIcon: const Icon(Icons.phone_outlined),
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: AppSizes.md),
              AppTextField(
                controller: _bioCtrl,
                label: 'Bio',
                prefixIcon: const Icon(Icons.info_outline),
                maxLines: 3,
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: AppSizes.md),
              AppTextField(
                controller: _addressCtrl,
                label: 'Adresse',
                prefixIcon: const Icon(Icons.location_on_outlined),
                textInputAction: TextInputAction.done,
              ),
              const SizedBox(height: AppSizes.xl),
              Consumer<AuthProvider>(
                builder: (_, auth, __) => AppButton(
                  label: 'Enregistrer',
                  onPressed: _save,
                  loading: auth.loading,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}