import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../core/constants/app_constants.dart';
import '../../core/theme/app_theme.dart';
import '../../data/models/opportunity_model.dart';
import '../../features/bookmarks/cubit/bookmark_cubit.dart';

class OpportunityCard extends StatelessWidget {
  const OpportunityCard({
    super.key,
    required this.opportunity,
    required this.onTap,
    this.showBookmark = true,
  });

  final OpportunityModel opportunity;
  final VoidCallback onTap;
  final bool showBookmark;

  @override
  Widget build(BuildContext context) {
    final bookmarkState = context.watch<BookmarkCubit>().state;
    final isBookmarked = bookmarkState.bookmarkedIds.contains(opportunity.id);

    return Card(
      margin: const EdgeInsets.only(bottom: 14),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: AppTheme.gold.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(Icons.rocket_launch_rounded, color: AppTheme.gold),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          opportunity.title,
                          style: const TextStyle(
                            color: AppTheme.white,
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          opportunity.startupName,
                          style: const TextStyle(color: AppTheme.mutedText),
                        ),
                      ],
                    ),
                  ),
                  if (showBookmark)
                    IconButton(
                      onPressed: bookmarkState.isUpdating
                          ? null
                          : () {
                              // Bookmark toggle handled by parent via userId in shell
                            },
                      icon: Icon(
                        isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                        color: AppTheme.gold,
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _metaChip(Icons.category_outlined, opportunity.category),
                  _metaChip(Icons.place_outlined, opportunity.campus),
                  _metaChip(Icons.schedule, '${opportunity.durationWeeks} wks'),
                ],
              ),
              if (opportunity.skillsRequired.isNotEmpty) ...[
                const SizedBox(height: 12),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: opportunity.skillsRequired
                      .take(4)
                      .map(
                        (skill) => Chip(
                          label: Text(skill, style: const TextStyle(fontSize: 12)),
                          visualDensity: VisualDensity.compact,
                        ),
                      )
                      .toList(),
                ),
              ],
              const SizedBox(height: 10),
              Text(
                'Posted ${DateFormat.MMMd().format(opportunity.createdAt)}',
                style: const TextStyle(color: AppTheme.mutedText, fontSize: 12),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _metaChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppTheme.softNavy,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppTheme.mutedText),
          const SizedBox(width: 4),
          Text(label, style: const TextStyle(color: AppTheme.softWhite, fontSize: 12)),
        ],
      ),
    );
  }
}

class FilterBar extends StatelessWidget {
  const FilterBar({
    super.key,
    required this.selectedCategory,
    required this.selectedCampus,
    required this.onCategoryChanged,
    required this.onCampusChanged,
    required this.onSearchChanged,
  });

  final String selectedCategory;
  final String selectedCampus;
  final ValueChanged<String> onCategoryChanged;
  final ValueChanged<String> onCampusChanged;
  final ValueChanged<String> onSearchChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextField(
          decoration: const InputDecoration(
            hintText: 'Search roles, startups, or skills',
            prefixIcon: Icon(Icons.search),
          ),
          onChanged: onSearchChanged,
        ),
        const SizedBox(height: 12),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _filterChip('All', selectedCategory, onCategoryChanged),
              ...AppConstants.opportunityCategories.map(
                (category) => _filterChip(category, selectedCategory, onCategoryChanged),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _filterChip('All', selectedCampus, onCampusChanged),
              ...AppConstants.aluCampuses.map(
                (campus) => _filterChip(campus, selectedCampus, onCampusChanged),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _filterChip(String label, String selected, ValueChanged<String> onChanged) {
    final isSelected = selected == label;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (_) => onChanged(label),
        selectedColor: AppTheme.gold.withValues(alpha: 0.25),
        checkmarkColor: AppTheme.gold,
      ),
    );
  }
}
