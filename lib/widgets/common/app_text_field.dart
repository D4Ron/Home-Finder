import 'package:flutter/material.dart';

class AppTextField extends StatefulWidget {
  final TextEditingController? controller;
  final String?  label;
  final String?  hint;
  final Widget?  prefixIcon;
  final Widget?  suffixIcon;
  final bool     obscure;
  final TextInputType?    keyboardType;
  final TextInputAction?  textInputAction;
  final FormFieldValidator<String>? validator;
  final ValueChanged<String>?       onChanged;
  final ValueChanged<String>?       onSubmitted;
  final int  maxLines;
  final bool autofocus;
  final bool enabled;

  const AppTextField({
    super.key,
    this.controller,
    this.label,
    this.hint,
    this.prefixIcon,
    this.suffixIcon,
    this.obscure = false,
    this.keyboardType,
    this.textInputAction,
    this.validator,
    this.onChanged,
    this.onSubmitted,
    this.maxLines = 1,
    this.autofocus = false,
    this.enabled = true,
  });

  @override
  State<AppTextField> createState() => _AppTextFieldState();
}

class _AppTextFieldState extends State<AppTextField> {
  late bool _obscure;

  @override
  void initState() {
    super.initState();
    _obscure = widget.obscure;
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller:      widget.controller,
      obscureText:     _obscure,
      keyboardType:    widget.keyboardType,
      textInputAction: widget.textInputAction,
      maxLines:        _obscure ? 1 : widget.maxLines,
      validator:       widget.validator,
      onChanged:       widget.onChanged,
      onFieldSubmitted: widget.onSubmitted,
      autofocus:       widget.autofocus,
      enabled:         widget.enabled,
      decoration: InputDecoration(
        labelText:  widget.label,
        hintText:   widget.hint,
        prefixIcon: widget.prefixIcon,
        suffixIcon: widget.obscure
            ? IconButton(
          icon: Icon(_obscure
              ? Icons.visibility_outlined
              : Icons.visibility_off_outlined),
          onPressed: () => setState(() => _obscure = !_obscure),
        )
            : widget.suffixIcon,
      ),
    );
  }
}