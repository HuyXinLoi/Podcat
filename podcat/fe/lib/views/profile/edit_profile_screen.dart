import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:podcat/core/utils/app_localizations.dart';
import 'package:podcat/core/utils/responsive_helper.dart';

import '../../blocs/auth/auth_bloc.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _bioController = TextEditingController();
  final _avatarUrlController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _initializeControllers();
  }

  void _initializeControllers() {
    final user = context.read<AuthBloc>().state.user;
    if (user != null) {
      _nameController.text = user.name ?? '';
      _bioController.text = user.bio ?? '';
      _avatarUrlController.text = user.avatarUrl ?? '';
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _bioController.dispose();
    _avatarUrlController.dispose();
    super.dispose();
  }

  void _saveProfile() {
    if (_formKey.currentState!.validate()) {
      context.read<AuthBloc>().add(
            UpdateUserProfile(
              profileData: {
                'name': _nameController.text.trim(),
                'bio': _bioController.text.trim(),
                'avatarUrl': _avatarUrlController.text.trim(),
              },
            ),
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = ResponsiveHelper.isDesktop(context);
    final isTablet = ResponsiveHelper.isTablet(context);
    final user = context.watch<AuthBloc>().state.user;

    if (user == null) {
      return Scaffold(
        appBar: AppBar(title: Text(context.tr('edit_profile'))),
        body: Center(
          child: Text(
            context.tr('user_not_found'),
            style: TextStyle(
              fontSize: ResponsiveHelper.getFontSize(context, 18),
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(context.tr('edit_profile')),
      ),
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state.status == AuthStatus.authenticated) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(context.tr('profile_updated'))),
            );
            Navigator.pop(context);
          } else if (state.status == AuthStatus.error) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                  content: Text(state.error ?? context.tr('update_failed'))),
            );
          }
        },
        child: SingleChildScrollView(
          padding: ResponsiveHelper.getPadding(context),
          child: Center(
            child: Container(
              constraints: BoxConstraints(
                maxWidth: isDesktop
                    ? 600
                    : isTablet
                        ? 500
                        : double.infinity,
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: CircleAvatar(
                        radius: ResponsiveHelper.isMobile(context) ? 60 : 80,
                        backgroundImage: (user.avatarUrl != null &&
                                user.avatarUrl!.isNotEmpty)
                            ? NetworkImage(user.avatarUrl!)
                            : null,
                        child: (user.avatarUrl == null ||
                                user.avatarUrl!.isEmpty)
                            ? Text(
                                (user.name?.isNotEmpty ?? false)
                                    ? user.name![0].toUpperCase()
                                    : (user.username?.isNotEmpty ?? false)
                                        ? user.username![0].toUpperCase()
                                        : '',
                                style: TextStyle(
                                  fontSize:
                                      ResponsiveHelper.getFontSize(context, 40),
                                ),
                              )
                            : null,
                      ),
                    ),
                    SizedBox(
                        height: ResponsiveHelper.isMobile(context) ? 24 : 32),
                    Text(
                      context.tr('name'),
                      style: TextStyle(
                        fontSize: ResponsiveHelper.getFontSize(context, 16),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        hintText: context.tr('enter_name'),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                    SizedBox(
                        height: ResponsiveHelper.isMobile(context) ? 16 : 24),
                    Text(
                      context.tr('bio'),
                      style: TextStyle(
                        fontSize: ResponsiveHelper.getFontSize(context, 16),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _bioController,
                      decoration: InputDecoration(
                        hintText: context.tr('enter_bio'),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      maxLines: 3,
                    ),
                    SizedBox(
                        height: ResponsiveHelper.isMobile(context) ? 16 : 24),
                    Text(
                      context.tr('avatar_url'),
                      style: TextStyle(
                        fontSize: ResponsiveHelper.getFontSize(context, 16),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _avatarUrlController,
                      decoration: InputDecoration(
                        hintText: context.tr('enter_avatar_url'),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                    SizedBox(
                        height: ResponsiveHelper.isMobile(context) ? 32 : 40),
                    BlocBuilder<AuthBloc, AuthState>(
                      builder: (context, state) {
                        return SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: state.status == AuthStatus.loading
                                ? null
                                : _saveProfile,
                            style: ElevatedButton.styleFrom(
                              padding: EdgeInsets.symmetric(
                                vertical: ResponsiveHelper.isMobile(context)
                                    ? 12
                                    : 16,
                              ),
                            ),
                            child: state.status == AuthStatus.loading
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : Text(
                                    context.tr('save'),
                                    style: TextStyle(
                                      fontSize: ResponsiveHelper.getFontSize(
                                          context, 16),
                                    ),
                                  ),
                          ),
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
    );
  }
}
