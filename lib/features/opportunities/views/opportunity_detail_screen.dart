import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/application_model.dart';
import '../../../data/models/opportunity_model.dart';
import '../../../data/models/user_model.dart';
import '../../applications/cubit/application_cubit.dart';
import '../../bookmarks/cubit/bookmark_cubit.dart';

class OpportunityDetailScreen extends StatefulWidget {
  const OpportunityDetailScreen({
    super.key,
    required this.user,
    required this.opportunity,
  });

  final UserModel user;
  final OpportunityModel opportunity;

  @override
  State<OpportunityDetailScreen> createState() => _OpportunityDetailScreenState();
}

class _OpportunityDetailScreenState extends State<OpportunityDetailScreen> {
  final _coverLetterController = TextEditingController();
  bool _hasApplied = false;
  bool _checkingApplication = true;

  @override
  void initState() {
    super.initState();
    if (widget.user.role == UserRole.student) {
      _checkApplied();
    } else {
      _checkingApplication = false;
    }
  }

  Future<void> _checkApplied() async {
    final applied = await context.read<ApplicationCubit>().hasApplied(
          studentId: widget.user.id,
          opportunityId: widget.opportunity.id,
        );
    if (mounted) {
      setState(() {
        _hasApplied = applied;
        _checkingApplication = false;
      });
    }
  }

  @override
  void dispose() {
    _coverLetterController.dispose();
    super.dispose();
  }

  Future<void> _apply() async {
    final coverLetter = _coverLetterController.text.trim();
    if (coverLetter.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add a short cover letter')),
      );
      return;
    }

    await context.read<ApplicationCubit>().submit(
          ApplicationModel(
            id: '',
            opportunityId: widget.opportunity.id,
            opportunityTitle: widget.opportunity.title,
            studentId: widget.user.id,
            studentName: widget.user.fullName,
            startupId: widget.opportunity.startupId,
            startupName: widget.opportunity.startupName,
            coverLetter: coverLetter,
            status: ApplicationStatus.submitted,
            appliedAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ),
        );

    if (mounted) {
      setState(() => _hasApplied = true);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Application submitted')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final bookmarkState = context.watch<BookmarkCubit>().state;
    final isBookmarked = bookmarkState.bookmarkedIds.contains(widget.opportunity.id);
    final canApply = widget.user.role == UserRole.student && !_hasApplied;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Role details'),
        actions: [
          IconButton(
            onPressed: bookmarkState.isUpdating
                ? null
                : () => context.read<BookmarkCubit>().toggle(
                      userId: widget.user.id,
                      opportunityId: widget.opportunity.id,
                    ),
            icon: Icon(
              isBookmarked ? Icons.bookmark : Icons.bookmark_border,
              color: AppTheme.red,
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(
            widget.opportunity.title,
            style: const TextStyle(
              color: AppTheme.white,
              fontSize: 26,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            widget.opportunity.startupName,
            style: const TextStyle(color: AppTheme.red, fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _infoChip(Icons.category_outlined, widget.opportunity.category),
              _infoChip(Icons.place_outlined, widget.opportunity.campus),
              _infoChip(Icons.schedule, '${widget.opportunity.durationWeeks} weeks'),
              _infoChip(Icons.location_on_outlined, widget.opportunity.locationType),
            ],
          ),
          const SizedBox(height: 20),
          const Text(
            'About this role',
            style: TextStyle(color: AppTheme.white, fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            widget.opportunity.description,
            style: const TextStyle(color: AppTheme.softWhite, height: 1.5),
          ),
          if (widget.opportunity.skillsRequired.isNotEmpty) ...[
            const SizedBox(height: 20),
            const Text(
              'Skills required',
              style: TextStyle(color: AppTheme.white, fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: widget.opportunity.skillsRequired
                  .map((skill) => Chip(label: Text(skill)))
                  .toList(),
            ),
          ],
          const SizedBox(height: 12),
          Text(
            'Posted ${DateFormat.yMMMd().format(widget.opportunity.createdAt)}',
            style: const TextStyle(color: AppTheme.mutedText, fontSize: 12),
          ),
          if (canApply) ...[
            const SizedBox(height: 28),
            TextField(
              controller: _coverLetterController,
              maxLines: 5,
              decoration: const InputDecoration(
                labelText: 'Cover letter',
                hintText: 'Tell the startup why you are a great fit...',
              ),
            ),
            const SizedBox(height: 16),
            BlocBuilder<ApplicationCubit, ApplicationState>(
              builder: (context, state) {
                final submitting = state.submitStatus == ApplicationSubmitStatus.submitting;
                return SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: submitting ? null : _apply,
                    child: submitting
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(strokeWidth: 2, color: AppTheme.white),
                          )
                        : const Text('Apply now'),
                  ),
                );
              },
            ),
          ] else if (widget.user.role == UserRole.student && _hasApplied) ...[
            const SizedBox(height: 28),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.red.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppTheme.red.withValues(alpha: 0.4)),
              ),
              child: const Row(
                children: [
                  Icon(Icons.check_circle_outline, color: AppTheme.red),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'You have already applied to this role.',
                      style: TextStyle(color: AppTheme.white, fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            ),
          ] else if (_checkingApplication) ...[
            const SizedBox(height: 28),
            const Center(child: CircularProgressIndicator(color: AppTheme.red)),
          ],
        ],
      ),
    );
  }

  Widget _infoChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppTheme.softNavy,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: AppTheme.mutedText),
          const SizedBox(width: 6),
          Text(label, style: const TextStyle(color: AppTheme.softWhite, fontSize: 13)),
        ],
      ),
    );
  }
}
