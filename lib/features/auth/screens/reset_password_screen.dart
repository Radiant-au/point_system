import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/data/member_data_provider.dart';
import '../../../core/data/initial_member_data.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/reward_widgets.dart';

class ResetPasswordScreen extends ConsumerStatefulWidget {
  const ResetPasswordScreen({super.key, this.memberId = initialMemberId});

  final String memberId;

  @override
  ConsumerState<ResetPasswordScreen> createState() =>
      _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends ConsumerState<ResetPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _currentPassword = TextEditingController();
  final _password = TextEditingController();
  final _confirmation = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirmation = true;
  bool _submitting = false;

  bool get _longEnough => _password.text.length >= 8;
  bool get _hasUppercase => RegExp(r'[A-Z]').hasMatch(_password.text);
  bool get _hasNumber => RegExp(r'[0-9]').hasMatch(_password.text);

  @override
  void dispose() {
    _currentPassword.dispose();
    _password.dispose();
    _confirmation.dispose();
    super.dispose();
  }

  Future<void> _updatePassword() async {
    if (_submitting || !_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    setState(() => _submitting = true);
    final changed = await ref.read(appDatabaseProvider).updatePassword(
      widget.memberId,
      _currentPassword.text,
      _password.text,
    );
    if (!mounted) return;
    setState(() => _submitting = false);
    if (!changed) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Current password is incorrect')),
      );
      return;
    }
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => Dialog(
        insetPadding: const EdgeInsets.symmetric(horizontal: 40, vertical: 24),
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircleAvatar(
                radius: 32,
                backgroundColor: Color(0xFFDCFCE7),
                child: Icon(Icons.task_alt, color: Color(0xFF00B83E), size: 36),
              ),
              const SizedBox(height: 16),
              const Text(
                'Your password is updated successfully.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppTheme.ink,
                  fontSize: 14,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 16),
              GradientButton(
                label: 'OK',
                onPressed: () => Navigator.of(dialogContext).pop(),
              ),
            ],
          ),
        ),
      ),
    );
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    body: SafeArea(
      child: Column(
        children: [
          RewardPageHeader(
            title: 'Reset Password',
            onBack: () => Navigator.of(context).pop(),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      'Current Password',
                      style: TextStyle(color: Color(0xFF4A5565), fontSize: 12),
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: _currentPassword,
                      obscureText: true,
                      decoration: const InputDecoration(
                        hintText: 'Enter current password',
                      ),
                      validator: (value) => value == null || value.isEmpty
                          ? 'Enter your current password'
                          : null,
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'New Password',
                      style: TextStyle(color: Color(0xFF4A5565), fontSize: 12),
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: _password,
                      obscureText: _obscurePassword,
                      enableSuggestions: false,
                      autocorrect: false,
                      textInputAction: TextInputAction.next,
                      style: const TextStyle(fontSize: 14),
                      onChanged: (_) => setState(() {}),
                      decoration: InputDecoration(
                        hintText: 'Enter new password',
                        hintStyle: const TextStyle(
                          color: Color(0xFF99A1AF),
                          fontSize: 14,
                        ),
                        suffixIcon: IconButton(
                          tooltip: _obscurePassword
                              ? 'Show new password'
                              : 'Hide new password',
                          onPressed: () => setState(
                            () => _obscurePassword = !_obscurePassword,
                          ),
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                            size: 18,
                          ),
                        ),
                      ),
                      validator: (_) =>
                          _longEnough && _hasUppercase && _hasNumber
                          ? null
                          : 'Meet all three password requirements',
                    ),
                    const SizedBox(height: 20),
                    _Requirement(
                      label: 'Minimum 8 characters',
                      met: _longEnough,
                    ),
                    _Requirement(
                      label: 'At least one uppercase letter',
                      met: _hasUppercase,
                    ),
                    _Requirement(label: 'At least one number', met: _hasNumber),
                    const SizedBox(height: 24),
                    const Text(
                      'Confirm Password',
                      style: TextStyle(color: Color(0xFF4A5565), fontSize: 12),
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: _confirmation,
                      obscureText: _obscureConfirmation,
                      enableSuggestions: false,
                      autocorrect: false,
                      textInputAction: TextInputAction.done,
                      onFieldSubmitted: (_) => _updatePassword(),
                      style: const TextStyle(fontSize: 14),
                      decoration: InputDecoration(
                        hintText: 'Re-enter password',
                        hintStyle: const TextStyle(
                          color: Color(0xFF99A1AF),
                          fontSize: 14,
                        ),
                        suffixIcon: IconButton(
                          tooltip: _obscureConfirmation
                              ? 'Show confirm password'
                              : 'Hide confirm password',
                          onPressed: () => setState(
                            () => _obscureConfirmation = !_obscureConfirmation,
                          ),
                          icon: Icon(
                            _obscureConfirmation
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                            size: 18,
                          ),
                        ),
                      ),
                      validator: (value) => value == null || value.isEmpty
                          ? 'Confirm your password'
                          : value != _password.text
                          ? 'Passwords do not match'
                          : null,
                    ),
                    const SizedBox(height: 22),
                    GradientButton(
                      label: _submitting ? 'Updating…' : 'Update Password',
                      onPressed: _submitting ? null : _updatePassword,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

class _Requirement extends StatelessWidget {
  const _Requirement({required this.label, required this.met});
  final String label;
  final bool met;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 4),
    child: Row(
      children: [
        Icon(
          met ? Icons.check_circle_outline : Icons.circle_outlined,
          size: 16,
          color: met ? const Color(0xFF00B83E) : const Color(0xFFD1D5DB),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(color: AppTheme.muted, fontSize: 11),
          ),
        ),
      ],
    ),
  );
}
