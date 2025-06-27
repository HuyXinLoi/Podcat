import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:podcat/blocs/auth/auth_bloc.dart';
import 'package:podcat/blocs/category/category_bloc.dart';
import 'package:podcat/blocs/podcast/podcast_bloc.dart';
import 'package:podcat/widgets/mini_player.dart';
import 'package:podcat/views/home/tabs/discover_tab.dart';
import 'package:podcat/views/home/tabs/library_tab.dart';
import 'package:podcat/views/home/tabs/profile_tab.dart';
import 'package:podcat/views/home/tabs/search_tab.dart';

class HomeScreen extends StatefulWidget {
  final int initialIndex;
  final Widget? child;

  const HomeScreen({
    super.key,
    this.initialIndex = 0,
    this.child,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late int _currentIndex;
  final List<Widget> _tabs = [
    const DiscoverTab(),
    const SearchTab(),
    const LibraryTab(),
    const ProfileTab(),
  ];

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    context.read<CategoryBloc>().add(LoadCategories());
    context.read<PodcastBloc>().add(const LoadPodcasts());
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state.status == AuthStatus.unauthenticated) {
          context.go('/login');
        }
      },
      child: Scaffold(
        body: Stack(
          children: [
            Positioned.fill(
              child: widget.child ?? _tabs[_currentIndex],
            ),
            const Positioned(
              bottom: 1,
              left: 0,
              right: 0,
              child: Padding(
                padding: EdgeInsets.only(left: 8, right: 8),
                child: MiniPlayer(),
              ),
            ),
          ],
        ),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });

            switch (index) {
              case 0:
                context.go('/discover');
                break;
              case 1:
                context.go('/search');
                break;
              case 2:
                context.go('/library');
                break;
              case 3:
                context.go('/profile');
                break;
            }
          },
          type: BottomNavigationBarType.fixed,
          items: [
            BottomNavigationBarItem(
              icon: const Icon(Icons.home),
              label: l10n.discover,
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.search),
              label: l10n.search,
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.library_music),
              label: l10n.library,
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.person),
              label: l10n.profile,
            ),
          ],
        ),
      ),
    );
  }
}
