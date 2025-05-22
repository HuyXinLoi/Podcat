import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../blocs/auth/auth_bloc.dart';
import '../../models/category.dart';
import '../../models/playlist.dart';
import '../../models/podcast.dart';
import '../../views/auth/login_screen.dart';
import '../../views/auth/register_screen.dart';
import '../../views/category/category_podcasts_screen.dart';
import '../../views/home/home_screen.dart';
import '../../views/home/tabs/discover_tab.dart';
import '../../views/home/tabs/library_tab.dart';
import '../../views/home/tabs/profile_tab.dart';
import '../../views/home/tabs/search_tab.dart';
import '../../views/playlist/playlist_detail_screen.dart';
import '../../views/playlist/playlist_form_screen.dart';
import '../../views/podcast/podcast_detail_screen.dart';
import '../../views/podcast/podcast_player_screen.dart';
import '../../views/profile/edit_profile_screen.dart';
import '../../views/splash_screen.dart';

class AppRouter {
  static final GlobalKey<NavigatorState> _rootNavigatorKey =
      GlobalKey<NavigatorState>(debugLabel: 'root');
  static final GlobalKey<NavigatorState> _shellNavigatorKey =
      GlobalKey<NavigatorState>(debugLabel: 'shell');

  static final GoRouter router = GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/',
    debugLogDiagnostics: true,
    redirect: (context, state) {
      final authState = context.read<AuthBloc>().state;
      final isLoggedIn = authState.status == AuthStatus.authenticated;

      final isSplash = state.matchedLocation == '/';
      final isLoginOrRegister = state.matchedLocation == '/login' ||
          state.matchedLocation == '/register';

      if (!isLoggedIn && !isLoginOrRegister && !isSplash) {
        return '/login';
      }

      return null;
    },
    routes: [
      GoRoute(
        name: 'splash',
        path: '/',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        name: 'login',
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        name: 'register',
        path: '/register',
        builder: (context, state) => const RegisterScreen(),
      ),
      ShellRoute(
        navigatorKey: _shellNavigatorKey,
        builder: (context, state, child) => HomeScreen(child: child),
        routes: [
          GoRoute(
            name: 'discover',
            path: '/discover',
            builder: (context, state) => const DiscoverTab(),
          ),
          GoRoute(
            name: 'search',
            path: '/search',
            builder: (context, state) => const SearchTab(),
          ),
          GoRoute(
            name: 'library',
            path: '/library',
            builder: (context, state) => const LibraryTab(),
          ),
          GoRoute(
            name: 'profile',
            path: '/profile',
            builder: (context, state) => const ProfileTab(),
          ),
        ],
      ),
      GoRoute(
        name: 'podcast-detail',
        path: '/podcast/:id',
        builder: (context, state) {
          final podcastId = state.pathParameters['id']!;
          return PodcastDetailScreen(podcastId: podcastId);
        },
      ),
      GoRoute(
        name: 'podcast-play',
        path: '/podcast/:id/play',
        builder: (context, state) {
          final podcast = state.extra as Podcast?;
          if (podcast == null) {
            return const Scaffold(
                body: Center(child: Text('Podcast not found')));
          }
          return PodcastPlayerScreen(podcast: podcast);
        },
      ),
      GoRoute(
        name: 'category',
        path: '/category/:id',
        builder: (context, state) {
          final category = state.extra as Category?;
          if (category == null) {
            return const Scaffold(
                body: Center(child: Text('Category not found')));
          }
          return CategoryPodcastsScreen(category: category);
        },
      ),
      GoRoute(
        name: 'playlist-create',
        path: '/playlist/create',
        builder: (context, state) => const PlaylistFormScreen(),
      ),
      GoRoute(
        name: 'playlist-detail',
        path: '/playlist/:id',
        builder: (context, state) {
          final playlist = state.extra as Playlist?;
          if (playlist == null) {
            return const Scaffold(
                body: Center(child: Text('Playlist not found')));
          }
          return PlaylistDetailScreen(playlist: playlist);
        },
      ),
      GoRoute(
        name: 'edit-profile',
        path: '/profile/edit',
        builder: (context, state) => const EditProfileScreen(),
      ),
    ],
  );
}
