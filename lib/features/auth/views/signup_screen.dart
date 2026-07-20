import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/alu_email_policy.dart';
import '../../../core/utils/validators.dart';
import '../bloc/auth_bloc.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _skillsController = TextEditingController();

  UserRole _role = UserRole.student;
  String _campus = AppConstants.aluCampuses.first;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _skillsController.dispose();
    super.dispose();
  }

  void _onEmailChanged(String value) {
    final locked = AluEmailPolicy.lockedRoleForEmail(value);
    if (locked != null && _role != locked) {
      setState(() => _role = locked);
    }
  }

  List<UserRole> get _availableRoles {
    final email = _emailController.text;
    if (email.contains('@')) {
      return AluEmailPolicy.selectableRolesForEmail(email);
    }
    return [UserRole.student, UserRole.startup, UserRole.facilitator];
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    final skills = _skillsController.text
        .split(',')
        .map((skill) => skill.trim())
        .where((skill) => skill.isNotEmpty)
        .toList();

    context.read<AuthBloc>().add(
          AuthSignUpRequested(
            email: _emailController.text,
            password: _passwordController.text,
            fullName: _nameController.text,
            role: _role,
            campus: _campus,
            skills: skills,
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    final roles = _availableRoles;

    return Scaffold(
      appBar: AppBar(title: const Text('Create account')),
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
                    'Join ALUhub',
                    style: TextStyle(
                      color: AppTheme.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Students & founders: @${AppConstants.studentDomain}\nFacilitators: @${AppConstants.facilitatorDomain}',
                    style: const TextStyle(color: AppTheme.mutedText, height: 1.5),
                  ),
                  const SizedBox(height: 24),
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      labelText: 'ALU email',
                      hintText: 'name@${AppConstants.studentDomain}',
                    ),
                    onChanged: _onEmailChanged,
                    validator: (value) => Validators.emailForRole(value, _role),
                  ),
                  const SizedBox(height: 16),
                  if (roles.length > 1)
                    SegmentedButton<UserRole>(
                      segments: roles
                          .map(
                            (role) => ButtonSegment(
                              value: role,
                              label: Text(role.label, style: const TextStyle(fontSize: 12)),
                            ),
                          )
                          .toList(),
                      selected: {_role},
                      onSelectionChanged: (selection) {
                        setState(() => _role = selection.first);
                      },
                    )
                  else
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppTheme.cardNavy,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppTheme.borderBlue),
                      ),
                      child: Text(
                        'Role: ${_role.label}',
                        style: const TextStyle(color: AppTheme.white, fontWeight: FontWeight.w600),
                      ),
                    ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(labelText: 'Full name'),
                    validator: (value) => Validators.requiredField(value, label: 'Name'),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _passwordController,
                    obscureText: true,
                    decoration: const InputDecoration(labelText: 'Password'),
                    validator: Validators.password,
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: _campus,
                    decoration: const InputDecoration(labelText: 'Campus'),
                    items: AppConstants.aluCampuses
                        .map((campus) => DropdownMenuItem(value: campus, child: Text(campus)))
                        .toList(),
                    onChanged: (value) {
                      if (value != null) setState(() => _campus = value);
                    },
                  ),
                  if (_role == UserRole.student) ...[
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _skillsController,
                      decoration: const InputDecoration(
                        labelText: 'Skills (comma separated)',
                        hintText: 'Flutter, UI Design, Marketing',
                      ),
                    ),
                  ],
                  const SizedBox(height: 28),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: isLoading ? null : _submit,
                      child: isLoading
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('Create account'),
                    ),
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
