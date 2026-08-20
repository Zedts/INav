import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../core/providers/auth_provider.dart';
import '../../core/services/auth_service.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_images.dart';
import '../../widgets/auth/terms_privacy_modal.dart';
import '../../widgets/common/theme_toggle_button.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key, this.register = false});

  final bool register;

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  late bool register = widget.register;
  final name = TextEditingController();
  final email = TextEditingController();
  final password = TextEditingController();
  final confirm = TextEditingController();
  bool terms = false;
  bool showPassword = false;
  bool showConfirmation = false;
  String? error;

  @override
  void dispose() {
    name.dispose();
    email.dispose();
    password.dispose();
    confirm.dispose();
    super.dispose();
  }

  Future<void> submit() async {
    final auth = context.read<AuthProvider>();
    setState(() => error = null);
    if (register &&
        (name.text.trim().length < 2 ||
            email.text.trim().isEmpty ||
            password.text.length < 8 ||
            password.text.length > 64 ||
            password.text != confirm.text ||
            !terms)) {
      setState(() => error = 'Please complete the form correctly.');
      return;
    }
    if (!register && (email.text.trim().isEmpty || password.text.isEmpty)) {
      setState(() => error = 'Enter your email and password.');
      return;
    }
    try {
      if (register) {
        await auth.register(name.text, email.text, password.text);
      } else {
        await auth.login(email.text, password.text);
      }
      if (mounted) Navigator.of(context).popUntil((route) => route.isFirst);
    } on AuthException catch (exception) {
      setState(() => error = exception.message);
    } catch (_) {
      setState(() => error = 'Something went wrong. Please try again.');
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final busy = context.watch<AuthProvider>().submitting;
    final muted = isDark ? AppColors.textMutedDark : AppColors.textMutedLight;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 36),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _TopAction(onTap: () => Navigator.of(context).pop()),
                  const ThemeToggleButton(),
                ],
              ),
              const SizedBox(height: 28),
              SizedBox(
                width: 256,
                height: 108,
                child: Image.asset(
                  isDark ? AppImages.iconDark : AppImages.iconWhite,
                  fit: BoxFit.contain,
                ),
              ),
              Text(
                'بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ',
                style: GoogleFonts.ibmPlexSansArabic(fontSize: 14, color: muted),
              ),
              const SizedBox(height: 32),
              _AuthTabs(
                register: register,
                onChanged: (value) => setState(() {
                  register = value;
                  error = null;
                }),
              ),
              const SizedBox(height: 28),
              if (register) ...[
                _AuthField(
                  controller: name,
                  label: 'FULL NAME',
                  hint: 'Ahmad Fauzi',
                  icon: Icons.person_outline,
                ),
                const SizedBox(height: 16),
              ],
              _AuthField(
                controller: email,
                label: 'EMAIL',
                hint: 'you@example.com',
                icon: Icons.mail_outline,
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 16),
              _AuthField(
                controller: password,
                label: 'PASSWORD',
                hint: register ? 'At least 8 characters' : 'Enter your password',
                icon: Icons.lock_outline,
                obscureText: !showPassword,
                trailing: IconButton(
                  tooltip: showPassword ? 'Hide password' : 'Show password',
                  onPressed: () => setState(() => showPassword = !showPassword),
                  icon: Icon(
                    showPassword
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                    color: muted,
                    size: 20,
                  ),
                ),
              ),
              if (register) ...[
                const SizedBox(height: 16),
                _AuthField(
                  controller: confirm,
                  label: 'CONFIRM PASSWORD',
                  hint: 'Re-enter your password',
                  icon: Icons.lock_outline,
                  obscureText: !showConfirmation,
                  trailing: IconButton(
                    tooltip: showConfirmation ? 'Hide password' : 'Show password',
                    onPressed: () => setState(
                      () => showConfirmation = !showConfirmation,
                    ),
                    icon: Icon(
                      showConfirmation
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                      color: muted,
                      size: 20,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                _TermsAgreement(
                  selected: terms,
                  onChanged: (value) => setState(() => terms = value),
                ),
              ],
              if (error != null) ...[
                const SizedBox(height: 16),
                _ErrorMessage(message: error!),
              ],
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: busy ? null : submit,
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 17),
                    shape: const StadiumBorder(),
                  ),
                  child: Text(
                    busy
                        ? 'Please wait…'
                        : register
                        ? 'Create Account'
                        : 'Log In',
                  ),
                ),
              ),
              const SizedBox(height: 28),
              Row(
                children: [
                  const Expanded(child: Divider()),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Text(
                      'OR CONTINUE WITH',
                      style: GoogleFonts.plusJakartaSans(
                        color: muted,
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.7,
                      ),
                    ),
                  ),
                  const Expanded(child: Divider()),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: _SocialButton(
                      label: 'Google',
                      asset: AppImages.google,
                      onTap: () => _showComingSoon('Google'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _SocialButton(
                      label: 'Apple',
                      asset: isDark ? AppImages.appleDark : AppImages.appleWhite,
                      onTap: () => _showComingSoon('Apple'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showComingSoon(String provider) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$provider sign-in is coming soon.')),
    );
  }
}

class _TopAction extends StatelessWidget {
  const _TopAction({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: isDark ? AppColors.cardDark : AppColors.cardLight,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isDark ? AppColors.hairlineDark : AppColors.hairlineLight,
          ),
        ),
        child: const Icon(Icons.arrow_back, size: 20),
      ),
    );
  }
}

class _AuthTabs extends StatelessWidget {
  const _AuthTabs({required this.register, required this.onChanged});

  final bool register;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final muted = isDark ? AppColors.textMutedDark : AppColors.textMutedLight;
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : AppColors.cardLight,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: isDark ? AppColors.hairlineDark : AppColors.hairlineLight,
        ),
      ),
      child: Row(
        children: [
          _TabButton(
            label: 'Log In',
            selected: !register,
            muted: muted,
            onTap: () => onChanged(false),
          ),
          _TabButton(
            label: 'Register',
            selected: register,
            muted: muted,
            onTap: () => onChanged(true),
          ),
        ],
      ),
    );
  }
}

class _TabButton extends StatelessWidget {
  const _TabButton({
    required this.label,
    required this.selected,
    required this.muted,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final Color muted;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Expanded(
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: selected ? Theme.of(context).colorScheme.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(999),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: GoogleFonts.plusJakartaSans(
            color: selected ? Theme.of(context).colorScheme.onPrimary : muted,
            fontSize: 13,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    ),
  );
}

class _AuthField extends StatelessWidget {
  const _AuthField({
    required this.controller,
    required this.label,
    required this.hint,
    required this.icon,
    this.keyboardType,
    this.obscureText = false,
    this.trailing,
  });

  final TextEditingController controller;
  final String label;
  final String hint;
  final IconData icon;
  final TextInputType? keyboardType;
  final bool obscureText;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final muted = isDark ? AppColors.textMutedDark : AppColors.textMutedLight;
    final border = isDark ? AppColors.hairlineDark : AppColors.hairlineLight;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.plusJakartaSans(
            color: muted,
            fontSize: 10,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.7,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          obscureText: obscureText,
          style: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.w500),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: GoogleFonts.plusJakartaSans(color: muted, fontSize: 14),
            prefixIcon: Icon(icon, color: muted, size: 20),
            suffixIcon: trailing,
            filled: true,
            fillColor: isDark ? AppColors.cardDark : AppColors.cardLight,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 17),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: Theme.of(context).colorScheme.primary),
            ),
          ),
        ),
      ],
    );
  }
}

class _TermsAgreement extends StatelessWidget {
  const _TermsAgreement({required this.selected, required this.onChanged});

  final bool selected;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final muted = isDark ? AppColors.textMutedDark : AppColors.textMutedLight;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 1),
          child: SizedBox(
            width: 24,
            height: 24,
            child: Checkbox(
              value: selected,
              onChanged: (value) => onChanged(value ?? false),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
              side: BorderSide(color: isDark ? AppColors.hairlineDark : AppColors.hairlineLight),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Text(
                'I agree to the ',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: muted,
                  height: 1.55,
                ),
              ),
              _LegalLink(
                title: 'Terms of Service',
                onTap: () => TermsPrivacyModal.show(context, 'Terms of Service'),
              ),
              Text(
                ' & ',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: muted,
                  height: 1.55,
                ),
              ),
              _LegalLink(
                title: 'Privacy Policy',
                onTap: () => TermsPrivacyModal.show(context, 'Privacy Policy'),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _LegalLink extends StatelessWidget {
  const _LegalLink({required this.title, required this.onTap});

  final String title;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => InkWell(
    onTap: onTap,
    child: Text(
      title,
      style: GoogleFonts.plusJakartaSans(
        color: Theme.of(context).colorScheme.primary,
        fontSize: 12,
        fontWeight: FontWeight.w700,
        height: 1.55,
      ),
    ),
  );
}

class _ErrorMessage extends StatelessWidget {
  const _ErrorMessage({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: Theme.of(context).colorScheme.errorContainer,
      borderRadius: BorderRadius.circular(12),
    ),
    child: Text(
      message,
      style: GoogleFonts.plusJakartaSans(
        color: Theme.of(context).colorScheme.onErrorContainer,
        fontSize: 12,
        fontWeight: FontWeight.w600,
      ),
    ),
  );
}

class _SocialButton extends StatelessWidget {
  const _SocialButton({
    required this.label,
    required this.asset,
    required this.onTap,
  });

  final String label;
  final String asset;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: isDark ? AppColors.cardDark : AppColors.cardLight,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDark ? AppColors.hairlineDark : AppColors.hairlineLight,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgPicture.asset(asset, width: 19, height: 19),
            const SizedBox(width: 8),
            Text(
              label,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
