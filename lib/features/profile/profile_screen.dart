import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/constants/app_constants.dart';
import '../../core/theme/app_theme.dart';
import '../../data/models/user_model.dart';
import '../auth/bloc/auth_bloc.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key, required this.user});

  final UserModel user;

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late final TextEditingController _nameController;
  late final TextEditingController _bioController;
  late final TextEditingController _linkedInController;
  late final TextEditingController _githubController;
  late final TextEditingController _portfolioController;
  late final TextEditingController _skillsController;
  late String _campus;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.user.fullName);
    _bioController = TextEditingController(text: widget.user.bio ?? '');
    _linkedInController = TextEditingController(text: widget.user.linkedInUrl ?? '');
    _githubController = TextEditingController(text: widget.user.githubUrl ?? '');
    _portfolioController = TextEditingController(text: widget.user.portfolioUrl ?? '');
    _skillsController = TextEditingController(text: widget.user.skills.join(', '));
    _campus = widget.user.campus;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _bioController.dispose();
    _linkedInController.dispose();
    _githubController.dispose();
    _portfolioController.dispose();
    _skillsController.dispose();
    super.dispose();
  }

  void _save() {
    final skills = _skillsController.text
        .split(',')
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();

    context.read<AuthBloc>().add(
          AuthProfileUpdated(
            widget.user.copyWith(
              fullName: _nameController.text.trim(),
              campus: _campus,
              bio: _bioController.text.trim().isEmpty ? null : _bioController.text.trim(),
              linkedInUrl:
                  _linkedInController.text.trim().isEmpty ? null : _linkedInController.text.trim(),
              githubUrl:
                  _githubController.text.trim().isEmpty ? null : _githubController.text.trim(),
              portfolioUrl: _portfolioController.text.trim().isEmpty
                  ? null
                  : _portfolioController.text.trim(),
              skills: skills,
            ),
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message), backgroundColor: Colors.redAccent),
            );
          } else if (state is AuthAuthenticated) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Profile updated')),
            );
          }
        },
        builder: (context, state) {
          final isLoading = state is AuthLoading;
          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              CircleAvatar(
                radius: 42,
                backgroundColor: AppTheme.red.withValues(alpha: 0.2),
                child: Text(
                  widget.user.fullName.isNotEmpty ? widget.user.fullName[0].toUpperCase() : '?',
                  style: const TextStyle(
                    color: AppTheme.red,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                widget.user.email,
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppTheme.mutedText),
              ),
              const SizedBox(height: 6),
              Text(
                widget.user.role.label,
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppTheme.red, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 24),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Full name'),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: _campus,
                decoration: const InputDecoration(labelText: 'Campus'),
                items: AppConstants.aluCampuses
                    .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                    .toList(),
                onChanged: isLoading ? null : (v) => setState(() => _campus = v!),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _skillsController,
                decoration: const InputDecoration(
                  labelText: 'Skills',
                  hintText: 'Flutter, UI Design, ...',
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _bioController,
                maxLines: 3,
                decoration: const InputDecoration(labelText: 'Bio'),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _linkedInController,
                decoration: const InputDecoration(labelText: 'LinkedIn URL'),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _githubController,
                decoration: const InputDecoration(labelText: 'GitHub URL'),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _portfolioController,
                decoration: const InputDecoration(labelText: 'Portfolio URL'),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: isLoading ? null : _save,
                  child: isLoading
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(strokeWidth: 2, color: AppTheme.white),
                        )
                      : const Text('Save profile'),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: isLoading
                      ? null
                      : () => context.read<AuthBloc>().add(const AuthSignOutRequested()),
                  child: const Text('Sign out'),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
