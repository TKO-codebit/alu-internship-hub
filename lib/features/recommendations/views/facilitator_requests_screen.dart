import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/common_widgets.dart';
import '../../../data/models/user_model.dart';
import '../cubit/recommendation_cubit.dart';

class FacilitatorRequestsScreen extends StatefulWidget {
  const FacilitatorRequestsScreen({super.key, required this.user});

  final UserModel user;

  @override
  State<FacilitatorRequestsScreen> createState() => _FacilitatorRequestsScreenState();
}

class _FacilitatorRequestsScreenState extends State<FacilitatorRequestsScreen> {
  @override
  void initState() {
    super.initState();
    context.read<RecommendationCubit>().watchForFacilitator(widget.user.id);
  }

  Future<void> _respond(String recommendationId, String studentId) async {
    final controller = TextEditingController();
    final action = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Respond to request'),
        content: TextField(
          controller: controller,
          maxLines: 5,
          decoration: const InputDecoration(
            labelText: 'Recommendation text (optional for decline)',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, 'decline'),
            child: const Text('Decline'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, 'complete'),
            child: const Text('Submit recommendation'),
          ),
        ],
      ),
    );

    if (action == null || !mounted) {
      controller.dispose();
      return;
    }

    await context.read<RecommendationCubit>().respond(
          recommendationId: recommendationId,
          studentId: studentId,
          status: action == 'complete'
              ? RecommendationStatus.completed
              : RecommendationStatus.declined,
          recommendationText:
              controller.text.trim().isEmpty ? null : controller.text.trim(),
        );
    controller.dispose();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            action == 'complete' ? 'Recommendation submitted' : 'Request declined',
          ),
        ),
      );
    }
  }

  Color _statusColor(RecommendationStatus status) {
    switch (status) {
      case RecommendationStatus.completed:
        return AppTheme.success;
      case RecommendationStatus.declined:
        return AppTheme.red;
      case RecommendationStatus.pending:
        return AppTheme.warning;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Reference requests')),
      body: BlocBuilder<RecommendationCubit, RecommendationState>(
        builder: (context, state) {
          if (state.status == RecommendationViewStatus.loading) {
            return const LoadingView(message: 'Loading requests...');
          }
          if (state.status == RecommendationViewStatus.failure) {
            return EmptyStateView(
              icon: Icons.error_outline,
              title: 'Could not load requests',
              subtitle: state.errorMessage ?? 'Try again later.',
            );
          }
          if (state.recommendations.isEmpty) {
            return const EmptyStateView(
              icon: Icons.inbox_outlined,
              title: 'No requests yet',
              subtitle: 'Student recommendation requests will appear here.',
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(20),
            itemCount: state.recommendations.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final rec = state.recommendations[index];
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
                              rec.studentName,
                              style: const TextStyle(
                                color: AppTheme.white,
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          StatusChip(
                            label: rec.status.label,
                            color: _statusColor(rec.status),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(rec.purpose, style: const TextStyle(color: AppTheme.red)),
                      const SizedBox(height: 8),
                      Text(
                        rec.message,
                        style: const TextStyle(color: AppTheme.softWhite, height: 1.4),
                      ),
                      if (rec.recommendationText != null) ...[
                        const SizedBox(height: 10),
                        Text(
                          rec.recommendationText!,
                          style: const TextStyle(color: AppTheme.mutedText, height: 1.4),
                        ),
                      ],
                      const SizedBox(height: 8),
                      Text(
                        DateFormat.yMMMd().format(rec.createdAt),
                        style: const TextStyle(color: AppTheme.mutedText, fontSize: 12),
                      ),
                      if (rec.status == RecommendationStatus.pending) ...[
                        const SizedBox(height: 14),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () => _respond(rec.id, rec.studentId),
                            child: const Text('Respond'),
                          ),
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
