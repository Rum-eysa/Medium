// Bu dosyayı lib/features/auth/views/ içindeki tüm view'lar kullanır.
// Ayrı bir widgets/ klasörüne taşımak isterseniz import path'lerini güncelleyin.

import 'package:flutter/material.dart';

// ─── Auth Text Field ──────────────────────────────────────────────────────────

class AuthField extends StatefulWidget {
  final TextEditingController controller;
  final String label;
  final String? hint;
  final IconData? icon;
  final bool isPassword;
  final TextInputType keyboardType;
  final String? Function(String?)? validator;
  final TextInputAction textInputAction;

  const AuthField({
    super.key,
    required this.controller,
    required this.label,
    this.hint,
    this.icon,
    this.isPassword = false,
    this.keyboardType = TextInputType.text,
    this.validator,
    this.textInputAction = TextInputAction.next,
  });

  @override
  State<AuthField> createState() => _AuthFieldState();
}

class _AuthFieldState extends State<AuthField> {
  bool _obscure = true;
  bool _focused = false;
  final _focus = FocusNode();

  @override
  void initState() {
    super.initState();
    _focus.addListener(() => setState(() => _focused = _focus.hasFocus));
  }

  @override
  void dispose() {
    _focus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w500,
            color: _focused ? const Color(0xFF8B85FF) : const Color(0xFF8B8A9B),
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 8),
        AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            boxShadow: _focused
                ? [
                    const BoxShadow(
                      color: Color(0x336C63FF),
                      blurRadius: 12,
                      spreadRadius: 0,
                    ),
                  ]
                : [],
          ),
          child: TextFormField(
            controller: widget.controller,
            focusNode: _focus,
            obscureText: widget.isPassword && _obscure,
            keyboardType: widget.keyboardType,
            validator: widget.validator,
            textInputAction: widget.textInputAction,
            style: const TextStyle(color: Color(0xFFF0EFF8), fontSize: 15),
            decoration: InputDecoration(
              hintText: widget.hint,
              hintStyle: const TextStyle(
                color: Color(0xFF4A4A5E),
                fontSize: 15,
              ),
              prefixIcon: widget.icon != null
                  ? Icon(
                      widget.icon,
                      color: _focused
                          ? const Color(0xFF8B85FF)
                          : const Color(0xFF4A4A5E),
                      size: 18,
                    )
                  : null,
              suffixIcon: widget.isPassword
                  ? IconButton(
                      icon: Icon(
                        _obscure
                            ? Icons.visibility_off_rounded
                            : Icons.visibility_rounded,
                        color: const Color(0xFF4A4A5E),
                        size: 18,
                      ),
                      onPressed: () => setState(() => _obscure = !_obscure),
                    )
                  : null,
              filled: true,
              fillColor: const Color(0xFF1C1C27),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 16,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                  color: Color(0xFF2A2A3A),
                  width: 1,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                  color: Color(0xFF2A2A3A),
                  width: 1,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                  color: Color(0xFF6C63FF),
                  width: 1.5,
                ),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                  color: Color(0xFFFF5C72),
                  width: 1,
                ),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                  color: Color(0xFFFF5C72),
                  width: 1.5,
                ),
              ),
              errorStyle: const TextStyle(
                color: Color(0xFFFF5C72),
                fontSize: 12,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ─── Primary Button ───────────────────────────────────────────────────────────

class PrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;

  const PrimaryButton({
    super.key,
    required this.label,
    this.onPressed,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF6C63FF),
          foregroundColor: Colors.white,
          disabledBackgroundColor: const Color(
            0xFF6C63FF,
          ).withValues(alpha: 0.5),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: isLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : Text(
                label,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
      ),
    );
  }
}

// ─── Auth Divider ─────────────────────────────────────────────────────────────
// Flutter'ın kendi Divider widget'ıyla çakışmaması için AuthDivider olarak adlandırıldı.

class AuthDivider extends StatelessWidget {
  const AuthDivider({super.key});

  @override
  Widget build(BuildContext context) {
    return const Row(
      children: [
        Expanded(child: Divider(color: Color(0xFF2A2A3A), thickness: 1)),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'veya',
            style: TextStyle(
              color: Color(0xFF4A4A5E),
              fontSize: 11,
              letterSpacing: 1.2,
            ),
          ),
        ),
        Expanded(child: Divider(color: Color(0xFF2A2A3A), thickness: 1)),
      ],
    );
  }
}

// ─── App Logo ─────────────────────────────────────────────────────────────────

class AppLogo extends StatelessWidget {
  const AppLogo({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF6C63FF), Color(0xFF8B85FF)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF6C63FF).withValues(alpha: 0.4),
                blurRadius: 16,
                spreadRadius: 1,
              ),
            ],
          ),
          child: const Center(
            child: Text(
              'B',
              style: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.w700,
                fontFamily: 'Georgia',
              ),
            ),
          ),
        ),
        const SizedBox(width: 14),
        const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Blogify',
              style: TextStyle(
                color: Color(0xFFF0EFF8),
                fontSize: 20,
                fontWeight: FontWeight.w700,
                fontFamily: 'Georgia',
              ),
            ),
            Text(
              'BLOG PLATFORMU',
              style: TextStyle(
                color: Color(0xFF4A4A5E),
                fontSize: 10,
                letterSpacing: 1.5,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
