import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/common_widgets.dart';
import '../../../data/models/user_model.dart';
import '../../startups/cubit/startup_cubit.dart';
import '../cubit/application_cubit.dart';

class ApplicationsScreen extends StatefulWidget {
  const ApplicationsScreen({super.key, required this.user});

  final UserModel user;

  @override
  State<ApplicationsScreen> createState() => _ApplicationsScreenState();
}

class _ApplicationsScreenState extends State<ApplicationsScreen> {
  @override
  void initState() {
    super.initState();
    if (widget.user.role == UserRole.student) {
      context.read<ApplicationCubit>().watchForStudent(widget.user.id);
    } else if (widget.user.role == UserRole.startup) {
      context.read<StartupCubit>().loadForOwner(widget.user.id);
    }
  }

  void _watchStartupApplications(String startupId) {
    context.read<ApplicationCubit>().watchForStartup(startupId);
  }

  Color _statusColor(ApplicationStatus status) {
    switch (status) {
      case ApplicationStatus.accepted:
        return AppTheme.success;
      case ApplicationStatus.rejected:
        return AppTheme.red;
      case ApplicationStatus.reviewing:
        return AppTheme.warning;
      case ApplicationStatus.submitted:
        return AppTheme.mutedText;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isStudent = widget.user.role == UserRole.student;
    final title = isStudent ? 'My applications' : 'Applicants';

    if (!isStudent) {
      return BlocListener<StartupCubit, StartupState>(
        listener: (context, state) {
          final startup = state.currentStartup;
          if (startup != null) {
            _watchStartupApplications(startup.id);
          }
        },
        child: _buildScaffold(title, isStudent),
      );
    }

    return _buildScaffold(title, isStudent);
  }

  Widget _buildScaffold(String title, bool isStudent) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: BlocBuilder<ApplicationCubit, ApplicationState>(
        builder: (context, state) {
          if (!isStudent) {
            final startupState = context.watch<StartupCubit>().state;
            if (startupState.status == StartupViewStatus.loading) {
              return const LoadingView(message: 'Loading startup profile...');
            }
            if (startupState.currentStartup == null) {
              return const EmptyStateView(
                icon: Icons.storefront_outlined,
                title: 'No startup profile',
                subtitle: 'Create your startup profile before reviewing applicants.',
              );
            }
          }

          if (state.status == ApplicationViewStatus.loading) {
            return const LoadingView(message: 'Loading applications...');
          }
          if (state.status == ApplicationViewStatus.failure) {
            return EmptyStateView(
              icon: Icons.error_outline,
              title: 'Could not load applications',
              subtitle: state.errorMessage ?? 'Try again later.',
            );
          }
          if (state.applications.isEmpty) {
            return EmptyStateView(
              icon: Icons.inbox_outlined,
              title: isStudent ? 'No applications yet' : 'No applicants yet',
              subtitle: isStudent
                  ? 'Browse opportunities and apply to get started.'
                  : 'Applications will appear here when students apply to your roles.',
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(20),
            itemCount: state.applications.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final app = state.applications[index];
              return Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              isStudent ? app.opportunityTitle : app.studentName,
                              style: const TextStyle(
                                color: AppTheme.white,
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          StatusChip(
                            label: app.status.label,
                            color: _statusColor(app.status),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        isStudent ? app.startupName : app.opportunityTitle,
                        style: const TextStyle(color: AppTheme.mutedText),
                      ),
                      if (app.coverLetter.isNotEmpty) ...[
                        const SizedBox(height: 10),
                        Text(
                          app.coverLetter,
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(color: AppTheme.softWhite, height: 1.4),
                        ),
                      ],
                      const SizedBox(height: 8),
                      Text(
                        'Applied ${DateFormat.MMMd().format(app.appliedAt)}',
                        style: const TextStyle(color: AppTheme.mutedText, fontSize: 12),
                      ),
                      if (!isStudent) ...[
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 8,
                          children: ApplicationStatus.values.map((status) {
                            final selected = app.status == status;
                            return FilterChip(
                              label: Text(status.label),
                              selected: selected,
                              onSelected: selected
                                  ? null
                                  : (_) {
                                      context.read<ApplicationCubit>().updateStatus(
                                            applicationId: app.id,
                                            status: status,
                                            studentId: app.studentId,
                                            opportunityTitle: app.opportunityTitle,
                                          );
                                    },
                            );
                          }).toList(),
                        ),
                      ],
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
