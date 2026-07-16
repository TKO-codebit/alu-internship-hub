import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'core/constants/app_constants.dart';
import 'core/theme/app_theme.dart';
import 'data/repositories/firebase_repositories.dart';
import 'features/applications/cubit/application_cubit.dart';
import 'features/auth/bloc/auth_bloc.dart';
import 'features/bookmarks/cubit/bookmark_cubit.dart';
import 'features/onboarding/onboarding_screen.dart';
import 'features/opportunities/bloc/opportunity_bloc.dart';
import 'features/recommendations/cubit/recommendation_cubit.dart';
import 'features/shell/app_shell.dart';
import 'features/startups/cubit/startup_cubit.dart';

class CampusLaunchpadApp extends StatelessWidget {
  const CampusLaunchpadApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider(create: (_) => AuthRepository()),
        RepositoryProvider(create: (_) => StartupRepository()),
        RepositoryProvider(create: (_) => OpportunityRepository()),
        RepositoryProvider(create: (_) => ApplicationRepository()),
        RepositoryProvider(create: (_) => BookmarkRepository()),
        RepositoryProvider(create: (_) => RecommendationRepository()),
        RepositoryProvider(create: (_) => NotificationRepository()),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (context) => AuthBloc(
              authRepository: context.read<AuthRepository>(),
            )..add(const AuthStarted()),
          ),
          BlocProvider(
            create: (context) => OpportunityBloc(
              repository: context.read<OpportunityRepository>(),
            ),
          ),
          BlocProvider(
            create: (context) => ApplicationCubit(
              repository: context.read<ApplicationRepository>(),
            ),
          ),
          BlocProvider(
            create: (context) => BookmarkCubit(
              repository: context.read<BookmarkRepository>(),
            ),
          ),
          BlocProvider(
            create: (context) => StartupCubit(
              repository: context.read<StartupRepository>(),
            ),
          ),
          BlocProvider(
            create: (context) => RecommendationCubit(
              repository: context.read<RecommendationRepository>(),
            ),
          ),
        ],
        child: MaterialApp(
          title: AppConstants.appName,
          debugShowCheckedModeBanner: false,
          theme: AppTheme.darkTheme,
          home: const AuthGate(),
        ),
      ),
    );
  }
}

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        if (state is AuthLoading || state is AuthInitial) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator(color: AppTheme.gold)),
          );
        }
        if (state is AuthAuthenticated) {
          return AppShell(user: state.user);
        }
        return const OnboardingScreen();
      },
    );
  }
}
