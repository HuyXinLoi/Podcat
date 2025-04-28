import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:podcat/views/favorites/favorites_screen.dart';
import 'package:podcat/views/home/home_screen.dart';
import 'package:podcat/views/introduction/introduction_screen.dart';
import 'package:podcat/views/playlist/playlist_screen.dart';
import 'package:podcat/views/profile/profile_screen.dart';
import 'package:podcat/views/search/search_screen.dart';
import 'package:podcat/widgets/bottom_nav_bar.dart';

final GoRouter router = GoRouter(
  initialLocation: '/',
  routes: [
    ShellRoute(
      navigatorKey: GlobalKey<NavigatorState>(),
      builder: (context, state, child) {
        return BottomNavBar(child: child);
      },
      routes: [
        GoRoute(path: '/home', builder: (context, state) => const HomeScreen()),
        GoRoute(
            path: '/search', builder: (context, state) => const SearchScreen()),
        GoRoute(
            path: '/favorites',
            builder: (context, state) => const FavoritesScreen()),
        GoRoute(
            path: '/playlist',
            builder: (context, state) => const PlaylistScreen()),
        GoRoute(
            path: '/profile',
            builder: (context, state) => const ProfileScreen()),
      ],
    ),
    GoRoute(path: '/', builder: (context, state) => const OnBoardingPage()),
    // GoRoute(
    //   path: '/podcast/:id',
    //   builder: (context, state) {
    //     final id = state.pathParameters['id'];
    //     return PodcastDetailScreen(podcastId: id!);
    //   },
    // ),
  ],
);
