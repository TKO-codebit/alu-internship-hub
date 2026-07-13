import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/widgets/common_widgets.dart';
import '../../../core/widgets/opportunity_card.dart';
import '../../../data/models/user_model.dart';
import '../../bookmarks/cubit/bookmark_cubit.dart';
import '../bloc/opportunity_bloc.dart';
import 'opportunity_detail_screen.dart';

class DiscoverScreen extends StatefulWidget {
  const DiscoverScreen({super.key, required this.user});

  final UserModel user;

  @override
  State<DiscoverScreen> createState() => _DiscoverScreenState();
}

class _DiscoverScreenState extends State<DiscoverScreen> {
  @override
  void initState() {
    super.initState();
    context.read<OpportunityBloc>().add(const OpportunitySubscriptionRequested());
    context.read<BookmarkCubit>().watch(widget.user.id);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Discover'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Chip(
              label: Text(widget.user.campus),
              avatar: const Icon(Icons.location_on_outlined, size: 18),
            ),
          ),
        ],
      ),
      body: BlocBuilder<OpportunityBloc, OpportunityState>(
        builder: (context, state) {
          return RefreshIndicator(
            onRefresh: () async {
              context.read<OpportunityBloc>().add(const OpportunitySubscriptionRequested());
            },
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                const Text(
                  'Verified startup opportunities',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Real experiences from ALU founders who need your skills.',
                  style: TextStyle(color: Colors.white70),
                ),
                const SizedBox(height: 20),
                FilterBar(
                  selectedCategory: state.selectedCategory,
                  selectedCampus: state.selectedCampus,
                  onCategoryChanged: (value) {
                    context.read<OpportunityBloc>().add(
                          OpportunityFilterChanged(category: value),
                        );
                  },
                  onCampusChanged: (value) {
                    context.read<OpportunityBloc>().add(
                          OpportunityFilterChanged(campus: value),
                        );
                  },
                  onSearchChanged: (value) {
                    context.read<OpportunityBloc>().add(
                          OpportunityFilterChanged(searchQuery: value),
                        );
                  },
                ),
                const SizedBox(height: 20),
                if (state.status == OpportunityStatus.loading)
                  const LoadingView(message: 'Fetching opportunities...')
                else if (state.status == OpportunityStatus.failure)
                  EmptyStateView(
                    icon: Icons.error_outline,
                    title: 'Could not load opportunities',
                    subtitle: state.errorMessage ?? 'Pull to refresh and try again.',
                  )
                else if (state.opportunities.isEmpty)
                  const EmptyStateView(
                    icon: Icons.search_off,
                    title: 'No opportunities yet',
                    subtitle: 'Check back soon or adjust your filters.',
                  )
                else
                  ...state.opportunities.map((opportunity) {
                    return OpportunityCard(
                      opportunity: opportunity,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => OpportunityDetailScreen(
                              user: widget.user,
                              opportunity: opportunity,
                            ),
                          ),
                        );
                      },
                    );
                  }),
              ],
            ),
          );
        },
      ),
    );
  }
}
