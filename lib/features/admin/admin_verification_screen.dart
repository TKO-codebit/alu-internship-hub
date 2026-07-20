import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/common_widgets.dart';
import '../startups/cubit/startup_cubit.dart';
class AdminVerificationScreen extends StatefulWidget {
  const AdminVerificationScreen({super.key});

  @override
  State<AdminVerificationScreen> createState() => _AdminVerificationScreenState();
}

class _AdminVerificationScreenState extends State<AdminVerificationScreen> {
  @override
  void initState() {
    super.initState();
    context.read<StartupCubit>().watchPendingVerifications();
  }

  Future<void> _reject(String startupId) async {
    final controller = TextEditingController();
    final reason = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reject startup'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(hintText: 'Reason for rejection'),
          maxLines: 3,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, controller.text.trim()),
            child: const Text('Reject'),
          ),
        ],
      ),
    );
    controller.dispose();

    if (reason != null && reason.isNotEmpty && mounted) {
      await context.read<StartupCubit>().verify(
            startupId: startupId,
            status: VerificationStatus.rejected,
            rejectionReason: reason,
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Verify startups')),
      body: BlocBuilder<StartupCubit, StartupState>(
        builder: (context, state) {
          if (state.pendingStartups.isEmpty) {
            return const EmptyStateView(
              icon: Icons.verified_outlined,
              title: 'No pending verifications',
              subtitle: 'New startup profiles awaiting review will appear here.',
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(20),
            itemCount: state.pendingStartups.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final startup = state.pendingStartups[index];
              return Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        startup.name,
                        style: const TextStyle(
                          color: AppTheme.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '${startup.sector} · ${startup.campus} · ${startup.teamSize} members',
                        style: const TextStyle(color: AppTheme.mutedText),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        startup.description,
                        style: const TextStyle(color: AppTheme.softWhite, height: 1.4),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () => _reject(startup.id),
                              child: const Text('Reject'),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () => context.read<StartupCubit>().verify(
                                    startupId: startup.id,
                                    status: VerificationStatus.approved,
                                  ),
                              child: const Text('Approve'),
                            ),
                          ),
                        ],
                      ),
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
