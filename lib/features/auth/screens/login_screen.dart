import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:testpoint/providers/auth_provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _obscureText = true;
  String? _errorMessage; // New state variable for error message

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 48.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildHeader(context),
              const SizedBox(height: 48),
              _buildLoginForm(context),
              if (_errorMessage != null) // Display error message if not null
                Padding(
                  padding: const EdgeInsets.only(top: 16.0),
                  child: Text(
                    _errorMessage!,
                    style: TextStyle(color: Theme.of(context).colorScheme.error),
                    textAlign: TextAlign.center,
                  ),
                ),
              const SizedBox(height: 24),
              _buildLoginButton(context),
              const SizedBox(height: 16),
              _buildForgotPasswordButton(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      children: [
        Icon(Icons.school, size: 100, color: theme.colorScheme.primary),
        const SizedBox(height: 16),
        Text(
          'Test Point',
          style: theme.textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.primary,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Your ultimate exam companion',
          style: theme.textTheme.titleMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildLoginForm(BuildContext context) {
    final theme = Theme.of(context);
    return Form(
      key: _formKey,
      child: Column(
        children: [
          TextFormField(
            controller: _emailController,
            decoration: InputDecoration(
              labelText: 'Email / Student ID',
              hintText: 'Enter your email or student ID',
              prefixIcon: const Icon(Icons.person_outline),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              filled: true,
              fillColor: theme.colorScheme.surface.withOpacity(0.5),
            ),
            keyboardType: TextInputType.emailAddress,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your email or student ID';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _passwordController,
            obscureText: _obscureText,
            decoration: InputDecoration(
              labelText: 'Password',
              hintText: 'Enter your password',
              prefixIcon: const Icon(Icons.lock_outline),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              filled: true,
              fillColor: theme.colorScheme.surface.withOpacity(0.5),
              suffixIcon: IconButton(
                icon: Icon(
                  _obscureText ? Icons.visibility_off : Icons.visibility,
                ),
                onPressed: () {
                  setState(() {
                    _obscureText = !_obscureText;
                  });
                },
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your password';
              }
              return null;
            },
          ),
        ],
      ),
    );
  }

  Widget _buildLoginButton(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    return ElevatedButton(
      onPressed: authProvider.isLoginLoading
          ? null
          : () async {
              // Clear previous error message
              setState(() {
                _errorMessage = null;
              });

              if (_formKey.currentState?.validate() ?? false) {
                print('LoginScreen: Form validated. Attempting login...');
                final success = await authProvider.login(
                  _emailController.text,
                  _passwordController.text,
                );
                print('LoginScreen: Login attempt success: $success');
                if (!success) {
                  setState(() {
                    _errorMessage = 'Invalid email or password.';
                    print('LoginScreen: Error message set: $_errorMessage');
                  });
                } else {
                  // Clear error message on successful login
                  setState(() {
                    _errorMessage = null;
                  });
                }
              } else {
                print('LoginScreen: Form validation failed.');
                setState(() {
                  _errorMessage = 'Please correct the errors in the form.';
                });
              }
            },
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
      ),
      child: authProvider.isLoginLoading
          ? const CircularProgressIndicator(color: Colors.white)
          : const Text(
              'Login',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
    );
  }

  Widget _buildForgotPasswordButton(BuildContext context) {
    final theme = Theme.of(context);
    return TextButton(
      onPressed: () {
        // TODO: Implement forgot password navigation
      },
      child: Text(
        'Forgot Password?',
        style: TextStyle(
          color: theme.colorScheme.primary,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
