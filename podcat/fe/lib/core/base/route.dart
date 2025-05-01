import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:podcat/blocs/auth/auth_bloc.dart';
import 'package:podcat/models/category.dart';
import 'package:podcat/models/playlist.dart';
import 'package:podcat/models/podcast.dart';
import 'package:podcat/views/auth/login_screen.dart';
import 'package:podcat/views/auth/register_screen.dart';
import 'package:podcat/views/category/category_podcasts_screen.dart';
import 'package:podcat/views/home/home_screen.dart';
import 'package:podcat/views/playlist/playlist_detail_screen.dart';
import 'package:podcat/views/playlist/playlist_form_screen.dart';
import 'package:podcat/views/podcast/podcast_detail_screen.dart';
import 'package:podcat/views/podcast/podcast_player_screen.dart';
import 'package:podcat/views/profile/edit_profile_screen.dart';
import 'package:podcat/views/splash_screen.dart';

class AppRouter {
  static final GlobalKey<NavigatorState> _rootNavigatorKey =
      GlobalKey<NavigatorState>(debugLabel: 'root');
  static final GlobalKey<NavigatorState> _shellNavigatorKey =
      GlobalKey<NavigatorState>(debugLabel: 'shell');

  static final GoRouter router = GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/',
    debugLogDiagnostics: true,
    redirect: (BuildContext context, GoRouterState state) {
      final authState = context.read<AuthBloc>().state;
      final isLoggedIn = authState.status == AuthStatus.authenticated;

      // Allow access to splash, login, and register screens without authentication
      if (state.matchedLocation == '/' ||
          state.matchedLocation == '/login' ||
          state.matchedLocation == '/register') {
        return null;
      }

      // Redirect to login if not logged in
      if (!isLoggedIn) {
        return '/login';
      }

      return null;
    },
    routes: [
      // Splash screen
      GoRoute(
        path: '/',
        builder: (context, state) => const SplashScreen(),
      ),

      // Auth routes
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterScreen(),
      ),

      // Home screen with shell for bottom navigation
      ShellRoute(
        navigatorKey: _shellNavigatorKey,
        builder: (context, state, child) => HomeScreen(child: child),
        routes: [
          // Discover tab
          GoRoute(
            path: '/discover',
            builder: (context, state) => const HomeScreen(initialIndex: 0),
          ),

          // Search tab
          GoRoute(
            path: '/search',
            builder: (context, state) => const HomeScreen(initialIndex: 1),
          ),

          // Library tab
          GoRoute(
            path: '/library',
            builder: (context, state) => const HomeScreen(initialIndex: 2),
          ),

          // Profile tab
          GoRoute(
            path: '/profile',
            builder: (context, state) => const HomeScreen(initialIndex: 3),
          ),
        ],
      ),

      // Podcast detail
      GoRoute(
        path: '/podcast/:id',
        builder: (context, state) {
          final podcastId = state.pathParameters['id']!;
          return PodcastDetailScreen(podcastId: podcastId);
        },
      ),

      // Podcast player
      GoRoute(
        path: '/podcast/:id/play',
        builder: (context, state) {
          final podcast = state.extra as Podcast;
          return PodcastPlayerScreen(podcast: podcast);
        },
      ),

      // Category podcasts
      GoRoute(
        path: '/category/:id',
        builder: (context, state) {
          final category = state.extra as Category;
          return CategoryPodcastsScreen(category: category);
        },
      ),

      // Playlist form
      GoRoute(
        path: '/playlist/create',
        builder: (context, state) => const PlaylistFormScreen(),
      ),

      // Playlist detail
      GoRoute(
        path: '/playlist/:id',
        builder: (context, state) {
          final playlist = state.extra as Playlist;
          return PlaylistDetailScreen(playlist: playlist);
        },
      ),

      // Edit profile
      GoRoute(
        path: '/profile/edit',
        builder: (context, state) => const EditProfileScreen(),
      ),
    ],
  );
}
