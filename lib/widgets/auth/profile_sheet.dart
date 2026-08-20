import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../core/providers/auth_provider.dart';
import '../../core/services/auth_service.dart';
import '../../core/theme/app_colors.dart';

class ProfileSheet extends StatefulWidget {
  const ProfileSheet({super.key});

  static Future<void> show(BuildContext context) => showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => const ProfileSheet(),
  );

  @override
  State<ProfileSheet> createState() => _ProfileSheetState();
}

class _ProfileSheetState extends State<ProfileSheet> {
  late final TextEditingController _name;
  late final TextEditingController _email;
  final _currentPassword = TextEditingController();
  final _newPassword = TextEditingController();
  bool _showCurrentPassword = false;
  bool _showNewPassword = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    final user = context.read<AuthProvider>().user!;
    _name = TextEditingController(text: user.fullName);
    _email = TextEditingController(text: user.email);
  }

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _currentPassword.dispose();
    _newPassword.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    setState(() => _error = null);
    try {
      await context.read<AuthProvider>().updateProfile(
        fullName: _name.text,
        email: _email.text,
        currentPassword: _currentPassword.text,
        newPassword: _newPassword.text,
      );
      if (mounted) Navigator.of(context).pop();
    } on AuthException catch (exception) {
      setState(() => _error = exception.message);
    } catch (_) {
      setState(() => _error = 'Unable to save your profile. Please try again.');
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final busy = context.watch<AuthProvider>().submitting;
    final muted = isDark ? AppColors.textMutedDark : AppColors.textMutedLight;

    return SafeArea(
      top: false,
      child: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.viewInsetsOf(context).bottom,
        ),
        child: Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.sizeOf(context).height * 0.9,
          ),
          decoration: BoxDecoration(
            color: isDark ? AppColors.cardDark : AppColors.cardLight,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 12, 24, 28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 42,
                    height: 4,
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.hairlineDark : AppColors.hairlineLight,
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'Profile',
                  style: GoogleFonts.fraunces(
                    fontSize: 26,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Confirm your current password before saving changes.',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    height: 1.5,
                    color: muted,
                  ),
                ),
                const SizedBox(height: 24),
                _ProfileField(
                  controller: _name,
                  label: 'USERNAME',
                  hint: 'Your name',
                  icon: Icons.person_outline,
                ),
                const SizedBox(height: 16),
                _ProfileField(
                  controller: _email,
                  label: 'EMAIL',
                  hint: 'you@example.com',
                  icon: Icons.mail_outline,
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 16),
                _ProfileField(
                  controller: _currentPassword,
                  label: 'CURRENT PASSWORD',
                  hint: 'Required to save changes',
                  icon: Icons.lock_outline,
                  obscureText: !_showCurrentPassword,
                  trailing: _PasswordVisibilityButton(
                    visible: _showCurrentPassword,
                    onPressed: () => setState(
                      () => _showCurrentPassword = !_showCurrentPassword,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                _ProfileField(
                  controller: _newPassword,
                  label: 'NEW PASSWORD',
                  hint: 'Leave blank to keep your password',
                  icon: Icons.lock_outline,
                  obscureText: !_showNewPassword,
                  trailing: _PasswordVisibilityButton(
                    visible: _showNewPassword,
                    onPressed: () => setState(
                      () => _showNewPassword = !_showNewPassword,
                    ),
                  ),
                ),
                if (_error != null) ...[
                  const SizedBox(height: 16),
                  _ProfileError(message: _error!),
                ],
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: busy ? null : _save,
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: const StadiumBorder(),
                    ),
                    child: Text(busy ? 'Saving…' : 'Save Changes'),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: TextButton.icon(
                    onPressed: busy ? null : _showDeleteDialog,
                    icon: const Icon(Icons.delete_outline),
                    label: const Text('Delete Account'),
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.roseAccent,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _showDeleteDialog() async {
    final deleted = await showDialog<bool>(
      context: context,
      builder: (_) => const _DeleteAccountDialog(),
    );
    if (deleted == true && mounted) Navigator.of(context).pop();
  }
}

class _ProfileField extends StatelessWidget {
  const _ProfileField({
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 10,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.7,
            color: muted,
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
            hintStyle: GoogleFonts.plusJakartaSans(fontSize: 14, color: muted),
            prefixIcon: Icon(icon, size: 20, color: muted),
            suffixIcon: trailing,
            filled: true,
            fillColor: isDark ? AppColors.cardDark : AppColors.cardLight,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 17),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(
                color: isDark ? AppColors.hairlineDark : AppColors.hairlineLight,
              ),
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

class _PasswordVisibilityButton extends StatelessWidget {
  const _PasswordVisibilityButton({required this.visible, required this.onPressed});

  final bool visible;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) => IconButton(
    tooltip: visible ? 'Hide password' : 'Show password',
    onPressed: onPressed,
    icon: Icon(
      visible ? Icons.visibility_off_outlined : Icons.visibility_outlined,
      size: 20,
    ),
  );
}

class _ProfileError extends StatelessWidget {
  const _ProfileError({required this.message});

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

class _DeleteAccountDialog extends StatefulWidget {
  const _DeleteAccountDialog();

  @override
  State<_DeleteAccountDialog> createState() => _DeleteAccountDialogState();
}

class _DeleteAccountDialogState extends State<_DeleteAccountDialog> {
  final _password = TextEditingController();
  Timer? _verificationDelay;
  bool _passwordMatches = false;
  bool _verifying = false;
  bool _deleting = false;
  bool _showPassword = false;
  String? _error;

  @override
  void dispose() {
    _verificationDelay?.cancel();
    _password.dispose();
    super.dispose();
  }

  void _onPasswordChanged(String value) {
    _verificationDelay?.cancel();
    setState(() {
      _passwordMatches = false;
      _error = null;
    });
    if (value.isEmpty) return;
    _verificationDelay = Timer(const Duration(milliseconds: 450), () async {
      if (!mounted || value != _password.text) return;
      setState(() => _verifying = true);
      final matches = await context.read<AuthProvider>().verifyCurrentPassword(value);
      if (!mounted || value != _password.text) return;
      setState(() {
        _verifying = false;
        _passwordMatches = matches;
      });
    });
  }

  Future<void> _delete() async {
    setState(() {
      _deleting = true;
      _error = null;
    });
    try {
      await context.read<AuthProvider>().deleteAccount(_password.text);
      if (mounted) Navigator.of(context).pop(true);
    } on AuthException catch (exception) {
      setState(() {
        _deleting = false;
        _passwordMatches = false;
        _error = exception.message;
      });
    } catch (_) {
      setState(() {
        _deleting = false;
        _error = 'Unable to delete your account. Please try again.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Delete account?'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'This permanently removes your local account, bookmarks, last-read position, and favorite mosques.',
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _password,
            obscureText: !_showPassword,
            onChanged: _onPasswordChanged,
            decoration: InputDecoration(
              labelText: 'Current password',
              suffixIcon: IconButton(
                tooltip: _showPassword ? 'Hide password' : 'Show password',
                onPressed: () => setState(() => _showPassword = !_showPassword),
                icon: Icon(
                  _showPassword
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                ),
              ),
            ),
          ),
          if (_verifying) const Padding(
            padding: EdgeInsets.only(top: 12),
            child: Text('Checking password…'),
          ),
          if (!_verifying && _password.text.isNotEmpty && !_passwordMatches)
            const Padding(
              padding: EdgeInsets.only(top: 12),
              child: Text('Enter the correct password to enable deletion.'),
            ),
          if (_error != null) ...[
            const SizedBox(height: 12),
            Text(_error!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
          ],
        ],
      ),
      actions: [
        TextButton(
          onPressed: _deleting ? null : () => Navigator.of(context).pop(false),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _passwordMatches && !_deleting ? _delete : null,
          style: FilledButton.styleFrom(backgroundColor: AppColors.roseAccent),
          child: Text(_deleting ? 'Deleting…' : 'Delete'),
        ),
      ],
    );
  }
}
