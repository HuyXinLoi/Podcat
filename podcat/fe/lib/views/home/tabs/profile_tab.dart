import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:podcat/blocs/auth/auth_bloc.dart';
import 'package:podcat/blocs/language/language_bloc.dart';
import 'package:podcat/core/utils/responsive_helper.dart';
import 'package:podcat/views/auth/login_screen.dart';
import 'package:podcat/views/profile/edit_profile_screen.dart';

class ProfileTab extends StatelessWidget {
  const ProfileTab({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.profile),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const EditProfileScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, state) {
          if (state.status == AuthStatus.loading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state.status == AuthStatus.unauthenticated) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(l10n.notLoggedIn),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (_) => const LoginScreen()),
                      );
                    },
                    child: Text(l10n.login),
                  ),
                ],
              ),
            );
          }

          final user = state.user;
          if (user == null) {
            return Center(child: Text(l10n.userProfileNotFound));
          }

          return SingleChildScrollView(
            padding: ResponsiveHelper.getPadding(context),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                CircleAvatar(
                  radius: ResponsiveHelper.isMobile(context) ? 60 : 80,
                  backgroundImage: user.avatarUrl != null
                      ? NetworkImage(user.avatarUrl!)
                      : null,
                  child: user.avatarUrl == null
                      ? Text(
                          user.name?.substring(0, 1).toUpperCase() ??
                              user.username.substring(0, 1).toUpperCase(),
                          style: TextStyle(
                            fontSize: ResponsiveHelper.getFontSize(context, 40),
                          ),
                        )
                      : null,
                ),
                SizedBox(height: ResponsiveHelper.isMobile(context) ? 16 : 24),
                Text(
                  user.name ?? user.username,
                  style: TextStyle(
                    fontSize: ResponsiveHelper.getFontSize(context, 24),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '@${user.username}',
                  style: TextStyle(
                    fontSize: ResponsiveHelper.getFontSize(context, 16),
                    color: Colors.grey[600],
                  ),
                ),
                if (user.bio != null) ...[
                  SizedBox(
                      height: ResponsiveHelper.isMobile(context) ? 16 : 24),
                  Text(
                    user.bio!,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: ResponsiveHelper.getFontSize(context, 16),
                    ),
                  ),
                ],
                SizedBox(height: ResponsiveHelper.isMobile(context) ? 24 : 32),
                _buildStatsSection(context, user, l10n),
                SizedBox(height: ResponsiveHelper.isMobile(context) ? 24 : 32),
                _buildLanguageSection(context, l10n),
                SizedBox(height: ResponsiveHelper.isMobile(context) ? 24 : 32),
                _buildSettingsSection(context, l10n),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatsSection(BuildContext context, user, AppLocalizations l10n) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildStatCard(
          context,
          l10n.podcasts,
          user.podcastCount.toString(),
        ),
        const SizedBox(width: 16),
        _buildStatCard(
          context,
          l10n.playlists,
          user.playlistCount.toString(),
        ),
      ],
    );
  }

  Widget _buildStatCard(BuildContext context, String label, String value) {
    return Expanded(
      child: Card(
        child: Padding(
          padding:
              EdgeInsets.all(ResponsiveHelper.isMobile(context) ? 16.0 : 24.0),
          child: Column(
            children: [
              Text(
                value,
                style: TextStyle(
                  fontSize: ResponsiveHelper.getFontSize(context, 24),
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: ResponsiveHelper.getFontSize(context, 14),
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLanguageSection(BuildContext context, AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.language,
          style: TextStyle(
            fontSize: ResponsiveHelper.getFontSize(context, 18),
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: BlocBuilder<LanguageBloc, LanguageState>(
              builder: (context, state) {
                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildLanguageButton(
                      context,
                      'English',
                      const Locale('en', ''),
                      state.locale.languageCode == 'en',
                    ),
                    _buildLanguageButton(
                      context,
                      'Tiếng Việt',
                      const Locale('vi', ''),
                      state.locale.languageCode == 'vi',
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLanguageButton(
    BuildContext context,
    String label,
    Locale locale,
    bool isSelected,
  ) {
    return ElevatedButton(
      onPressed: () {
        context.read<LanguageBloc>().add(ChangeLanguage(locale: locale));
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: isSelected
            ? Theme.of(context).colorScheme.primary
            : Theme.of(context).colorScheme.surface,
        foregroundColor:
            isSelected ? Colors.white : Theme.of(context).colorScheme.onSurface,
      ),
      child: Text(label),
    );
  }

  Widget _buildSettingsSection(BuildContext context, AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.settings,
          style: TextStyle(
            fontSize: ResponsiveHelper.getFontSize(context, 18),
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Card(
          child: Column(
            children: [
              ListTile(
                leading: const Icon(Icons.notifications),
                title: Text(l10n.notifications),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  // Navigate to notifications settings
                },
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.security),
                title: Text(l10n.privacy),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  // Navigate to privacy settings
                },
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.help),
                title: Text(l10n.helpSupport),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  // Navigate to help & support
                },
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.logout, color: Colors.red),
                title: Text(
                  l10n.logout,
                  style: const TextStyle(color: Colors.red),
                ),
                onTap: () async {
                  final confirmed = await showDialog<bool>(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: Text(l10n.logout),
                      content: Text(l10n.logoutConfirmation),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          child: Text(l10n.cancel),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pop(context, true),
                          child: Text(l10n.logout),
                        ),
                      ],
                    ),
                  );

                  if (confirmed == true) {
                    context.read<AuthBloc>().add(LogoutRequested());
                  }
                },
              ),
            ],
          ),
        ),
      ],
    );
  }
}
