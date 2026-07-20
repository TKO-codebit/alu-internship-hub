import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/validators.dart';
import '../../../data/models/opportunity_model.dart';
import '../../../data/models/user_model.dart';
import '../../../data/repositories/firebase_repositories.dart';
import '../../startups/cubit/startup_cubit.dart';

class PostOpportunityScreen extends StatefulWidget {
  const PostOpportunityScreen({super.key, required this.user});

  final UserModel user;

  @override
  State<PostOpportunityScreen> createState() => _PostOpportunityScreenState();
}

class _PostOpportunityScreenState extends State<PostOpportunityScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _skillsController = TextEditingController();

  String _category = AppConstants.opportunityCategories.first;
  String _campus = AppConstants.aluCampuses.first;
  String _locationType = 'on-campus';
  int _durationWeeks = 8;
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    _campus = widget.user.campus;
    context.read<StartupCubit>().loadForOwner(widget.user.id);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _skillsController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final startup = context.read<StartupCubit>().state.currentStartup;
    if (startup == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Create a startup profile first')),
      );
      return;
    }
    if (!startup.isVerified) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Your startup must be verified before posting roles')),
      );
      return;
    }

    setState(() => _submitting = true);
    try {
      final skills = _skillsController.text
          .split(',')
          .map((s) => s.trim())
          .where((s) => s.isNotEmpty)
          .toList();

      await context.read<OpportunityRepository>().createOpportunity(
            OpportunityModel(
              id: '',
              startupId: startup.id,
              startupName: startup.name,
              title: _titleController.text.trim(),
              description: _descriptionController.text.trim(),
              category: _category,
              skillsRequired: skills,
              locationType: _locationType,
              campus: _campus,
              durationWeeks: _durationWeeks,
              isActive: true,
              createdAt: DateTime.now(),
            ),
          );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Opportunity posted')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString()), backgroundColor: Colors.redAccent),
        );
      }
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final startup = context.watch<StartupCubit>().state.currentStartup;

    return Scaffold(
      appBar: AppBar(title: const Text('Post a role')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (startup != null && !startup.isVerified)
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppTheme.warning.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppTheme.warning.withOpacity(0.5)),
                  ),
                  child: const Text(
                    'Your startup is pending verification. You can post roles once an admin approves your profile.',
                    style: TextStyle(color: AppTheme.softWhite),
                  ),
                ),
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Role title'),
                validator: (v) => Validators.requiredField(v, label: 'Title'),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _descriptionController,
                maxLines: 5,
                decoration: const InputDecoration(labelText: 'Description'),
                validator: (v) => Validators.requiredField(v, label: 'Description'),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _skillsController,
                decoration: const InputDecoration(
                  labelText: 'Skills required',
                  hintText: 'Flutter, Firebase, ...',
                ),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: _category,
                decoration: const InputDecoration(labelText: 'Category'),
                items: AppConstants.opportunityCategories
                    .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                    .toList(),
                onChanged: _submitting ? null : (v) => setState(() => _category = v!),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: _campus,
                decoration: const InputDecoration(labelText: 'Campus'),
                items: AppConstants.aluCampuses
                    .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                    .toList(),
                onChanged: _submitting ? null : (v) => setState(() => _campus = v!),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: _locationType,
                decoration: const InputDecoration(labelText: 'Location type'),
                items: const [
                  DropdownMenuItem(value: 'on-campus', child: Text('On campus')),
                  DropdownMenuItem(value: 'remote', child: Text('Remote')),
                  DropdownMenuItem(value: 'hybrid', child: Text('Hybrid')),
                ],
                onChanged: _submitting ? null : (v) => setState(() => _locationType = v!),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<int>(
                value: _durationWeeks,
                decoration: const InputDecoration(labelText: 'Duration (weeks)'),
                items: [4, 6, 8, 10, 12, 16]
                    .map((w) => DropdownMenuItem(value: w, child: Text('$w weeks')))
                    .toList(),
                onChanged: _submitting ? null : (v) => setState(() => _durationWeeks = v!),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _submitting ? null : _submit,
                  child: _submitting
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(strokeWidth: 2, color: AppTheme.white),
                        )
                      : const Text('Publish role'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
