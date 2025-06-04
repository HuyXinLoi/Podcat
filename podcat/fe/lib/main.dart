import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:podcat/blocs/audio_player/audio_player_bloc.dart';
import 'package:podcat/blocs/auth/auth_bloc.dart';
import 'package:podcat/blocs/category/category_bloc.dart';
import 'package:podcat/blocs/favorite/favorite_bloc.dart';
import 'package:podcat/blocs/language/language_bloc.dart';
import 'package:podcat/blocs/playlist/playlist_bloc.dart';
import 'package:podcat/blocs/podcast/podcast_bloc.dart';
import 'package:podcat/core/base/route.dart';
import 'package:podcat/core/theme/theme.dart';
import 'package:podcat/repositories/auth_repository.dart';
import 'package:podcat/repositories/category_repository.dart';
import 'package:podcat/repositories/favorite_repository.dart';
import 'package:podcat/repositories/playlist_repository.dart';
import 'package:podcat/repositories/podcast_repository.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // await JustAudioBackground.init(
  //   androidNotificationChannelId: 'com.yourcompany.podcat.channel.audio',
  //   androidNotificationChannelName: 'Podcat Audio Playback',
  //   androidNotificationOngoing: true,
  // );
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
          BlocProvider(
            create: (context) => AudioPlayerBloc(),
          ),
        ],
        child: BlocBuilder<LanguageBloc, LanguageState>(
          builder: (context, state) {
            return MaterialApp.router(
              title: 'DUYNH',
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
