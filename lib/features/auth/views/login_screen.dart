import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/alu_email_policy.dart';
import '../../../core/utils/validators.dart';
import '../bloc/auth_bloc.dart';
import 'signup_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  UserRole _googleRole = UserRole.student;
  String _campus = AppConstants.aluCampuses.first;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submitEmail() {
    if (!_formKey.currentState!.validate()) return;
    context.read<AuthBloc>().add(
          AuthSignInRequested(
            email: _emailController.text,
            password: _passwordController.text,
          ),
        );
  }

  void _submitGoogle() {
    context.read<AuthBloc>().add(
          AuthGoogleSignInRequested(role: _googleRole, campus: _campus),
        );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sign in')),
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message), backgroundColor: Colors.redAccent),
            );
          }
        },
        builder: (context, state) {
          final isLoading = state is AuthLoading;
          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Welcome back',
                    style: TextStyle(
                      color: AppTheme.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Sign in with ${AluEmailPolicy.domainHint()} or your linked Google school account.',
                    style: const TextStyle(color: AppTheme.mutedText),
                  ),
                  const SizedBox(height: 28),
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      labelText: 'ALU email',
                      hintText: 'you@${AppConstants.studentDomain}',
                    ),
                    validator: Validators.aluEmail,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _passwordController,
                    obscureText: true,
                    decoration: const InputDecoration(labelText: 'Password'),
                    validator: Validators.password,
                  ),
                  const SizedBox(height: 28),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: isLoading ? null : _submitEmail,
                      child: isLoading
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('Sign in with email'),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Row(
                    children: [
                      Expanded(child: Divider(color: AppTheme.borderBlue)),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 12),
                        child: Text('or', style: TextStyle(color: AppTheme.mutedText)),
                      ),
                      Expanded(child: Divider(color: AppTheme.borderBlue)),
                    ],
                  ),
                  const SizedBox(height: 20),
                  DropdownButtonFormField<UserRole>(
                    value: _googleRole,
                    decoration: const InputDecoration(labelText: 'Google account role'),
                    items: const [
                      DropdownMenuItem(value: UserRole.student, child: Text('Student')),
                      DropdownMenuItem(value: UserRole.startup, child: Text('Startup founder')),
                      DropdownMenuItem(value: UserRole.facilitator, child: Text('Facilitator')),
                    ],
                    onChanged: isLoading
                        ? null
                        : (value) {
                            if (value != null) setState(() => _googleRole = value);
                          },
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: _campus,
                    decoration: const InputDecoration(labelText: 'Campus'),
                    items: AppConstants.aluCampuses
                        .map((campus) => DropdownMenuItem(value: campus, child: Text(campus)))
                        .toList(),
                    onChanged: isLoading
                        ? null
                        : (value) {
                            if (value != null) setState(() => _campus = value);
                          },
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: isLoading ? null : _submitGoogle,
                      icon: const Icon(Icons.g_mobiledata, size: 28),
                      label: const Text('Continue with Google'),
                    ),
                  ),
                  const SizedBox(height: 24),
                  TextButton(
                    onPressed: isLoading
                        ? null
                        : () => Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const SignupScreen()),
                            ),
                    child: const Text('Need an account? Create one'),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
