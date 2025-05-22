import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:podcat/blocs/playlist/playlist_bloc.dart';
import 'package:podcat/core/utils/responsive_helper.dart';
import 'package:podcat/generated/app_localizations.dart';

class PlaylistFormScreen extends StatefulWidget {
  const PlaylistFormScreen({super.key});

  @override
  State<PlaylistFormScreen> createState() => _PlaylistFormScreenState();
}

class _PlaylistFormScreenState extends State<PlaylistFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _createPlaylist() {
    if (_formKey.currentState!.validate()) {
      context.read<PlaylistBloc>().add(
            CreatePlaylist(name: _nameController.text.trim()),
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isDesktop = ResponsiveHelper.isDesktop(context);
    final isTablet = ResponsiveHelper.isTablet(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.createPlaylist),
      ),
      body: BlocListener<PlaylistBloc, PlaylistState>(
        listener: (context, state) {
          if (state.status == PlaylistStatus.loaded) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(l10n.playlistCreated)),
            );
            Navigator.pop(context);
          } else if (state.status == PlaylistStatus.error) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.error ?? l10n.createFailed),
              ),
            );
          }
        },
        child: Center(
          child: SingleChildScrollView(
            padding: ResponsiveHelper.getPadding(context),
            child: Center(
              child: Container(
                constraints: BoxConstraints(
                  maxWidth: isDesktop
                      ? 500
                      : isTablet
                          ? 450
                          : double.infinity,
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Icon(
                        Icons.playlist_add,
                        size: ResponsiveHelper.getFontSize(context, 70),
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      SizedBox(
                          height: ResponsiveHelper.isMobile(context) ? 24 : 32),
                      Text(
                        //
                        l10n.createPlaylist,
                        style: TextStyle(
                          fontSize: ResponsiveHelper.getFontSize(context, 24),
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(
                          height: ResponsiveHelper.isMobile(context) ? 16 : 24),
                      TextFormField(
                        controller: _nameController,
                        decoration: InputDecoration(
                          labelText: l10n.playlistName,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return l10n.notFound;
                          }
                          return null;
                        },
                      ),
                      SizedBox(
                          height: ResponsiveHelper.isMobile(context) ? 24 : 32),
                      BlocBuilder<PlaylistBloc, PlaylistState>(
                        builder: (context, state) {
                          return Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              TextButton(
                                onPressed:
                                    state.status == PlaylistStatus.loading
                                        ? null
                                        : () => Navigator.pop(context),
                                child: Text(l10n.cancel),
                              ),
                              const SizedBox(width: 16),
                              ElevatedButton(
                                onPressed:
                                    state.status == PlaylistStatus.loading
                                        ? null
                                        : _createPlaylist,
                                child: state.status == PlaylistStatus.loading
                                    ? const SizedBox(
                                        height: 20,
                                        width: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: Colors.white,
                                        ),
                                      )
                                    : Text(l10n.create),
                              ),
                            ],
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
