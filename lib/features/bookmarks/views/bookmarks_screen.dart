import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/common_widgets.dart';
import '../../../core/widgets/opportunity_card.dart';
import '../../../data/models/opportunity_model.dart';
import '../../../data/models/user_model.dart';
import '../../../data/repositories/firebase_repositories.dart';
import '../../opportunities/views/opportunity_detail_screen.dart';
import '../cubit/bookmark_cubit.dart';

class BookmarksScreen extends StatefulWidget {
  const BookmarksScreen({super.key, required this.user});

  final UserModel user;

  @override
  State<BookmarksScreen> createState() => _BookmarksScreenState();
}

class _BookmarksScreenState extends State<BookmarksScreen> {
  List<OpportunityModel> _opportunities = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    context.read<BookmarkCubit>().watch(widget.user.id);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadBookmarks(context.read<BookmarkCubit>().state.bookmarkedIds);
    });
  }

  Future<void> _loadBookmarks(Set<String> ids) async {
    if (ids.isEmpty) {
      setState(() {
        _opportunities = [];
        _loading = false;
      });
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final repo = context.read<OpportunityRepository>();
      final items = <OpportunityModel>[];
      for (final id in ids) {
        final opp = await repo.getById(id);
        if (opp != null && opp.isActive) items.add(opp);
      }
      if (mounted) {
        setState(() {
          _opportunities = items;
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _loading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Saved roles')),
      body: BlocConsumer<BookmarkCubit, BookmarkState>(
        listener: (context, state) => _loadBookmarks(state.bookmarkedIds),
        builder: (context, state) {
          if (_loading) {
            return const LoadingView(message: 'Loading saved roles...');
          }
          if (_error != null) {
            return EmptyStateView(
              icon: Icons.error_outline,
              title: 'Could not load bookmarks',
              subtitle: _error!,
            );
          }
          if (state.bookmarkedIds.isEmpty || _opportunities.isEmpty) {
            return const EmptyStateView(
              icon: Icons.bookmark_border,
              title: 'No saved roles',
              subtitle: 'Bookmark opportunities from Discover to find them here.',
            );
          }

          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              const Text(
                'Your saved opportunities',
                style: TextStyle(
                  color: AppTheme.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              ..._opportunities.map(
                (opportunity) => OpportunityCard(
                  opportunity: opportunity,
                  userId: widget.user.id,
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
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
