import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/constants/app_constants.dart';
import '../../data/models/user_model.dart';
import '../admin/admin_verification_screen.dart';
import '../applications/views/applications_screen.dart';
import '../bookmarks/views/bookmarks_screen.dart';
import '../opportunities/views/discover_screen.dart';
import '../opportunities/views/post_opportunity_screen.dart';
import '../profile/profile_screen.dart';
import '../recommendations/views/facilitator_requests_screen.dart';
import '../recommendations/views/student_recommendations_screen.dart';
import '../startups/views/startup_setup_screen.dart';

class AppShell extends StatefulWidget {
  const AppShell({super.key, required this.user});

  final UserModel user;

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _index, children: _buildPages()),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _index,
        onTap: (value) => setState(() => _index = value),
        items: _buildNavItems(),
      ),
      floatingActionButton: _buildFab(),
    );
  }

  List<Widget> _buildPages() {
    switch (widget.user.role) {
      case UserRole.student:
        return [
          DiscoverScreen(user: widget.user),
          ApplicationsScreen(user: widget.user),
          StudentRecommendationsScreen(user: widget.user),
          BookmarksScreen(user: widget.user),
          ProfileScreen(user: widget.user),
        ];
      case UserRole.startup:
        return [
          DiscoverScreen(user: widget.user),
          ApplicationsScreen(user: widget.user),
          StartupSetupScreen(user: widget.user),
          ProfileScreen(user: widget.user),
        ];
      case UserRole.facilitator:
        return [
          DiscoverScreen(user: widget.user),
          FacilitatorRequestsScreen(user: widget.user),
          ProfileScreen(user: widget.user),
        ];
      case UserRole.admin:
        return [
          DiscoverScreen(user: widget.user),
          const AdminVerificationScreen(),
          ProfileScreen(user: widget.user),
        ];
    }
  }

  List<BottomNavigationBarItem> _buildNavItems() {
    switch (widget.user.role) {
      case UserRole.student:
        return const [
          BottomNavigationBarItem(icon: Icon(Icons.explore_outlined), label: 'Discover'),
          BottomNavigationBarItem(icon: Icon(Icons.assignment_outlined), label: 'Applications'),
          BottomNavigationBarItem(icon: Icon(Icons.rate_review_outlined), label: 'References'),
          BottomNavigationBarItem(icon: Icon(Icons.bookmark_outline), label: 'Saved'),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: 'Profile'),
        ];
      case UserRole.startup:
        return const [
          BottomNavigationBarItem(icon: Icon(Icons.explore_outlined), label: 'Discover'),
          BottomNavigationBarItem(icon: Icon(Icons.inbox_outlined), label: 'Applicants'),
          BottomNavigationBarItem(icon: Icon(Icons.storefront_outlined), label: 'Startup'),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: 'Profile'),
        ];
      case UserRole.facilitator:
        return const [
          BottomNavigationBarItem(icon: Icon(Icons.explore_outlined), label: 'Discover'),
          BottomNavigationBarItem(icon: Icon(Icons.inbox_outlined), label: 'Requests'),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: 'Profile'),
        ];
      case UserRole.admin:
        return const [
          BottomNavigationBarItem(icon: Icon(Icons.explore_outlined), label: 'Discover'),
          BottomNavigationBarItem(icon: Icon(Icons.verified_user_outlined), label: 'Verify'),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: 'Profile'),
        ];
    }
  }

  FloatingActionButton? _buildFab() {
    if (widget.user.role != UserRole.startup) return null;
    return FloatingActionButton.extended(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => PostOpportunityScreen(user: widget.user),
          ),
        );
      },
      icon: const Icon(Icons.add),
      label: const Text('Post role'),
    );
  }
}
