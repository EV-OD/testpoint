import 'package:flutter/material.dart';

class InitialPasswordChangeScreen extends StatefulWidget {
  const InitialPasswordChangeScreen({super.key});

  @override
  State<InitialPasswordChangeScreen> createState() =>
      _InitialPasswordChangeScreenState();
}

class _InitialPasswordChangeScreenState
    extends State<InitialPasswordChangeScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _obscureCurrentPassword = true;
  bool _obscureNewPassword = true;
  bool _obscureConfirmPassword = true;

  // TODO: Add controllers and validation logic
  // final _currentPasswordController = TextEditingController();
  // final _newPasswordController = TextEditingController();
  // final _confirmPasswordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Set New Password'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: theme.colorScheme.onSurface,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildHeader(theme),
              const SizedBox(height: 48),
              _buildForm(theme),
              const SizedBox(height: 32),
              _buildSubmitButton(theme),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(ThemeData theme) {
    return Column(
      children: [
        Icon(
          Icons.security, // Changed Icon
          size: 80,
          color: theme.colorScheme.primary,
        ),
        const SizedBox(height: 24),
        Text(
          'Create a Strong Password',
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          'Your new password must be different from previous passwords.',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildForm(ThemeData theme) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          _buildPasswordTextField(
            label: 'Current Password',
            hint: 'Enter your current password',
            obscureText: _obscureCurrentPassword,
            onToggleVisibility: () {
              setState(() {
                _obscureCurrentPassword = !_obscureCurrentPassword;
              });
            },
          ),
          const SizedBox(height: 20),
          _buildPasswordTextField(
            label: 'New Password',
            hint: 'Enter your new password',
            obscureText: _obscureNewPassword,
            onToggleVisibility: () {
              setState(() {
                _obscureNewPassword = !_obscureNewPassword;
              });
            },
          ),
          const SizedBox(height: 12),
          const _PasswordCriteria(),
          const SizedBox(height: 20),
          _buildPasswordTextField(
            label: 'Confirm New Password',
            hint: 'Re-enter your new password',
            obscureText: _obscureConfirmPassword,
            onToggleVisibility: () {
              setState(() {
                _obscureConfirmPassword = !_obscureConfirmPassword;
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildPasswordTextField({
    required String label,
    required String hint,
    required bool obscureText,
    required VoidCallback onToggleVisibility,
  }) {
    return TextFormField(
      obscureText: obscureText,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: const Icon(Icons.lock_outline),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        fillColor: Theme.of(context).colorScheme.surface.withOpacity(0.5),
        suffixIcon: IconButton(
          icon: Icon(obscureText ? Icons.visibility_off : Icons.visibility),
          onPressed: onToggleVisibility,
        ),
      ),
      // TODO: Add validator
    );
  }

  Widget _buildSubmitButton(ThemeData theme) {
    return ElevatedButton(
      onPressed: () {
        // TODO: Implement save password logic
        // if (_formKey.currentState?.validate() ?? false) {
        //   // Process data
        // }
      },
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: theme.colorScheme.onPrimary,
      ),
      child: const Text(
        'Save and Continue',
        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
      ),
    );
  }
}

class _PasswordCriteria extends StatelessWidget {
  const _PasswordCriteria();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _CriteriaRow(
          theme: theme,
          text: '8+ characters',
          isValid: false, // TODO: Add validation state
        ),
        const SizedBox(height: 4),
        _CriteriaRow(
          theme: theme,
          text: 'Uppercase & lowercase letters',
          isValid: false, // TODO: Add validation state
        ),
        const SizedBox(height: 4),
        _CriteriaRow(
          theme: theme,
          text: 'At least one number & symbol',
          isValid: false, // TODO: Add validation state
        ),
      ],
    );
  }
}

class _CriteriaRow extends StatelessWidget {
  const _CriteriaRow({
    required this.theme,
    required this.text, 
    this.isValid = false, // Added default value
  });

  final ThemeData theme;
  final String text;
  final bool isValid;

  @override
  Widget build(BuildContext context) {
    final color = isValid
        ? Colors.green
        : theme.colorScheme.onSurface.withOpacity(0.7);
    final icon = isValid ? Icons.check_circle : Icons.radio_button_unchecked;

    return Row(
      children: [
        Icon(icon, color: color, size: 16),
        const SizedBox(width: 8),
        Text(text, style: theme.textTheme.bodySmall?.copyWith(color: color)),
      ],
    );
  }
}
