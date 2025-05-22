import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:podcat/generated/app_localizations.dart';

import 'blocs/auth/auth_bloc.dart';
import 'blocs/category/category_bloc.dart';
import 'blocs/favorite/favorite_bloc.dart';
import 'blocs/language/language_bloc.dart';
import 'blocs/playlist/playlist_bloc.dart';
import 'blocs/podcast/podcast_bloc.dart';
import 'core/base/route.dart';
import 'core/theme/theme.dart';

import 'repositories/auth_repository.dart';
import 'repositories/category_repository.dart';
import 'repositories/favorite_repository.dart';
import 'repositories/playlist_repository.dart';
import 'repositories/podcast_repository.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider(create: (context) => AuthRepository()),
        RepositoryProvider(create: (context) => PodcastRepository()),
        RepositoryProvider(create: (context) => CategoryRepository()),
        RepositoryProvider(create: (context) => FavoriteRepository()),
        RepositoryProvider(create: (context) => PlaylistRepository()),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (context) => LanguageBloc()..add(LoadLanguage()),
          ),
          BlocProvider(
            create: (context) => AuthBloc(
              authRepository: context.read<AuthRepository>(),
            )..add(CheckAuth()),
          ),
          BlocProvider(
            create: (context) => PodcastBloc(
              podcastRepository: context.read<PodcastRepository>(),
            ),
          ),
          BlocProvider(
            create: (context) => CategoryBloc(
              categoryRepository: context.read<CategoryRepository>(),
            ),
          ),
          BlocProvider(
            create: (context) => FavoriteBloc(
              favoriteRepository: context.read<FavoriteRepository>(),
            ),
          ),
          BlocProvider(
            create: (context) => PlaylistBloc(
              playlistRepository: context.read<PlaylistRepository>(),
            ),
          ),
        ],
        child: BlocBuilder<LanguageBloc, LanguageState>(
          builder: (context, state) {
            return MaterialApp.router(
              title: 'Podcat',
              debugShowCheckedModeBanner: false,
              theme: AppTheme.lightTheme,
              darkTheme: AppTheme.darkTheme,
              themeMode: ThemeMode.system,
              locale: state.locale,
              supportedLocales: AppLocalizations.supportedLocales,
              localizationsDelegates: const [
                AppLocalizations.delegate,
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
              ],
              routerConfig: AppRouter.router,
            );
          },
        ),
      ),
    );
  }
}
