import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';

class AuthInputField extends StatefulWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final bool obscureText;
  final bool showToggleVisibility;
  final TextInputType keyboardType;
  final TextInputAction textInputAction;
  final FocusNode? focusNode;
  final FocusNode? nextFocusNode;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final bool enabled;
  final Widget? prefixIcon;
  final int maxLines;

  const AuthInputField({
    super.key,
    required this.controller,
    required this.label,
    required this.hint,
    this.obscureText = false,
    this.showToggleVisibility = false,
    this.keyboardType = TextInputType.text,
    this.textInputAction = TextInputAction.next,
    this.focusNode,
    this.nextFocusNode,
    this.validator,
    this.onChanged,
    this.enabled = true,
    this.prefixIcon,
    this.maxLines = 1,
  });

  @override
  State<AuthInputField> createState() => _AuthInputFieldState();
}

class _AuthInputFieldState extends State<AuthInputField> {
  late bool _isObscured;
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _isObscured = widget.obscureText;
    widget.focusNode?.addListener(_handleFocusChange);
  }

  @override
  void dispose() {
    widget.focusNode?.removeListener(_handleFocusChange);
    super.dispose();
  }

  void _handleFocusChange() {
    setState(() {
      _isFocused = widget.focusNode?.hasFocus ?? false;
    });
  }

  void _toggleVisibility() {
    setState(() {
      _isObscured = !_isObscured;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOutCubic,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
        boxShadow: _isFocused
            ? [
                BoxShadow(
                  color: AppColors.electricBlueGlow,
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                  spreadRadius: -6,
                ),
              ]
            : null,
      ),
      child: TextFormField(
        controller: widget.controller,
        focusNode: widget.focusNode,
        obscureText: _isObscured,
        keyboardType: widget.keyboardType,
        textInputAction: widget.textInputAction,
        enabled: widget.enabled,
        maxLines: widget.maxLines,
        validator: widget.validator,
        onChanged: widget.onChanged,
        style: AppTypography.inputText,
        cursorColor: AppColors.electricBlue,
        cursorWidth: 1.5,
        onFieldSubmitted: (_) {
          if (widget.nextFocusNode != null) {
            FocusScope.of(context).requestFocus(widget.nextFocusNode);
          }
        },
        decoration: InputDecoration(
          labelText: widget.label,
          hintText: widget.hint,
          prefixIcon: widget.prefixIcon,
          suffixIcon: widget.showToggleVisibility
              ? GestureDetector(
                  onTap: _toggleVisibility,
                  child: Padding(
                    padding: const EdgeInsets.only(right: AppSpacing.smd),
                    child: Icon(
                      _isObscured
                          ? Icons.visibility_off_rounded
                          : Icons.visibility_rounded,
                      color: _isFocused ? AppColors.white60 : AppColors.white30,
                      size: AppSpacing.iconSm,
                    ),
                  ),
                )
              : null,
        ),
      ),
    );
  }
}
