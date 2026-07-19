import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/validators.dart';
import '../../../core/widgets/common_widgets.dart';
import '../../../data/models/user_model.dart';
import '../cubit/startup_cubit.dart';

class StartupSetupScreen extends StatefulWidget {
  const StartupSetupScreen({super.key, required this.user});

  final UserModel user;

  @override
  State<StartupSetupScreen> createState() => _StartupSetupScreenState();
}

class _StartupSetupScreenState extends State<StartupSetupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _teamSizeController = TextEditingController(text: '1');

  String _sector = AppConstants.startupSectors.first;
  String _campus = AppConstants.aluCampuses.first;
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _campus = widget.user.campus;
    context.read<StartupCubit>().loadForOwner(widget.user.id);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _teamSizeController.dispose();
    super.dispose();
  }

  void _populateFromStartup(StartupState state) {
    final startup = state.currentStartup;
    if (startup != null && !_initialized) {
      _nameController.text = startup.name;
      _descriptionController.text = startup.description;
      _sector = startup.sector;
      _campus = startup.campus;
      _teamSizeController.text = startup.teamSize.toString();
      _initialized = true;
    }
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    final teamSize = int.tryParse(_teamSizeController.text.trim()) ?? 1;

    context.read<StartupCubit>().create(
          ownerId: widget.user.id,
          name: _nameController.text.trim(),
          description: _descriptionController.text.trim(),
          sector: _sector,
          campus: _campus,
          teamSize: teamSize,
        );
  }

  Color _verificationColor(VerificationStatus status) {
    switch (status) {
      case VerificationStatus.approved:
        return AppTheme.success;
      case VerificationStatus.rejected:
        return AppTheme.red;
      case VerificationStatus.pending:
        return AppTheme.warning;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Startup profile')),
      body: BlocConsumer<StartupCubit, StartupState>(
        listener: (context, state) {
          _populateFromStartup(state);
          if (state.actionStatus == StartupActionStatus.success) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Startup profile saved — pending verification')),
            );
          } else if (state.actionStatus == StartupActionStatus.failure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.errorMessage ?? 'Could not save startup'),
                backgroundColor: Colors.redAccent,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state.status == StartupViewStatus.loading) {
            return const LoadingView(message: 'Loading startup profile...');
          }

          final startup = state.currentStartup;
          final isSubmitting = state.actionStatus == StartupActionStatus.submitting;
          final hasProfile = startup != null;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (hasProfile) ...[
                    StatusChip(
                      label: startup.verificationStatus.name.toUpperCase(),
                      color: _verificationColor(startup.verificationStatus),
                    ),
                    if (startup.rejectionReason != null) ...[
                      const SizedBox(height: 12),
                      Text(
                        'Reason: ${startup.rejectionReason}',
                        style: const TextStyle(color: AppTheme.mutedText),
                      ),
                    ],
                    const SizedBox(height: 20),
                  ] else ...[
                    const Text(
                      'Register your ALU startup',
                      style: TextStyle(
                        color: AppTheme.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Submit your profile for admin verification before posting internship roles.',
                      style: TextStyle(color: AppTheme.mutedText, height: 1.4),
                    ),
                    const SizedBox(height: 20),
                  ],
                  TextFormField(
                    controller: _nameController,
                    enabled: !hasProfile,
                    decoration: const InputDecoration(labelText: 'Startup name'),
                    validator: (v) => Validators.requiredField(v, label: 'Startup name'),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _descriptionController,
                    enabled: !hasProfile,
                    maxLines: 4,
                    decoration: const InputDecoration(labelText: 'Description'),
                    validator: (v) => Validators.requiredField(v, label: 'Description'),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: _sector,
                    decoration: const InputDecoration(labelText: 'Sector'),
                    items: AppConstants.startupSectors
                        .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                        .toList(),
                    onChanged: hasProfile || isSubmitting
                        ? null
                        : (v) => setState(() => _sector = v!),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: _campus,
                    decoration: const InputDecoration(labelText: 'Campus'),
                    items: AppConstants.aluCampuses
                        .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                        .toList(),
                    onChanged: hasProfile || isSubmitting
                        ? null
                        : (v) => setState(() => _campus = v!),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _teamSizeController,
                    enabled: !hasProfile,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Team size'),
                    validator: (v) => Validators.requiredField(v, label: 'Team size'),
                  ),
                  if (!hasProfile) ...[
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: isSubmitting ? null : _submit,
                        child: isSubmitting
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: AppTheme.white,
                                ),
                              )
                            : const Text('Submit for verification'),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
