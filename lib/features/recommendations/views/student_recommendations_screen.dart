import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/common_widgets.dart';
import '../../../data/models/user_model.dart';
import '../../../data/repositories/firebase_repositories.dart';
import '../cubit/recommendation_cubit.dart';

class StudentRecommendationsScreen extends StatefulWidget {
  const StudentRecommendationsScreen({super.key, required this.user});

  final UserModel user;

  @override
  State<StudentRecommendationsScreen> createState() =>
      _StudentRecommendationsScreenState();
}

class _StudentRecommendationsScreenState extends State<StudentRecommendationsScreen> {
  List<UserModel> _facilitators = [];
  bool _loadingFacilitators = true;

  @override
  void initState() {
    super.initState();
    context.read<RecommendationCubit>().watchForStudent(widget.user.id);
    _loadFacilitators();
  }

  Future<void> _loadFacilitators() async {
    try {
      final facilitators = await context.read<AuthRepository>().getFacilitators();
      if (mounted) {
        setState(() {
          _facilitators = facilitators;
          _loadingFacilitators = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _loadingFacilitators = false);
    }
  }

  Future<void> _requestRecommendation(UserModel facilitator) async {
    final purposeController = TextEditingController();
    final messageController = TextEditingController();

    final submitted = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Request from ${facilitator.fullName}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: purposeController,
              decoration: const InputDecoration(labelText: 'Purpose'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: messageController,
              maxLines: 3,
              decoration: const InputDecoration(labelText: 'Message'),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Send request'),
          ),
        ],
      ),
    );

    if (submitted == true && mounted) {
      await context.read<RecommendationCubit>().request(
            student: widget.user,
            facilitator: facilitator,
            purpose: purposeController.text.trim(),
            message: messageController.text.trim(),
          );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Recommendation request sent')),
        );
      }
    }

    purposeController.dispose();
    messageController.dispose();
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
      appBar: AppBar(title: const Text('References')),
      body: BlocBuilder<RecommendationCubit, RecommendationState>(
        builder: (context, state) {
          if (state.status == RecommendationViewStatus.loading) {
            return const LoadingView(message: 'Loading recommendations...');
          }

          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              const Text(
                'Your recommendation requests',
                style: TextStyle(
                  color: AppTheme.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              if (state.recommendations.isEmpty)
                const EmptyStateView(
                  icon: Icons.rate_review_outlined,
                  title: 'No requests yet',
                  subtitle: 'Request a reference from an ALU facilitator below.',
                )
              else
                ...state.recommendations.map((rec) {
                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  rec.facilitatorName,
                                  style: const TextStyle(
                                    color: AppTheme.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
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
                          Text(rec.purpose, style: const TextStyle(color: AppTheme.mutedText)),
                          if (rec.recommendationText != null) ...[
                            const SizedBox(height: 10),
                            Text(
                              rec.recommendationText!,
                              style: const TextStyle(color: AppTheme.softWhite, height: 1.4),
                            ),
                          ],
                          const SizedBox(height: 6),
                          Text(
                            DateFormat.yMMMd().format(rec.createdAt),
                            style: const TextStyle(color: AppTheme.mutedText, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
              const SizedBox(height: 28),
              const Text(
                'Request a new reference',
                style: TextStyle(
                  color: AppTheme.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              if (_loadingFacilitators)
                const LoadingView(message: 'Loading facilitators...')
              else if (_facilitators.isEmpty)
                const Text(
                  'No facilitators available yet.',
                  style: TextStyle(color: AppTheme.mutedText),
                )
              else
                ..._facilitators.map(
                  (f) => ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(f.fullName, style: const TextStyle(color: AppTheme.white)),
                    subtitle: Text(f.email, style: const TextStyle(color: AppTheme.mutedText)),
                    trailing: IconButton(
                      icon: const Icon(Icons.send_outlined, color: AppTheme.red),
                      onPressed: () => _requestRecommendation(f),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}
