import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:podcat/blocs/auth/auth_bloc.dart';
import 'package:podcat/blocs/language/language_bloc.dart';
import 'package:podcat/core/utils/responsive_helper.dart';
import 'package:podcat/generated/app_localizations.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _login() {
    if (_formKey.currentState!.validate()) {
      context.read<AuthBloc>().add(
            LoginRequested(
              username: _usernameController.text.trim(),
              password: _passwordController.text,
            ),
          );
    }
  }

  void _navigateToRegister() {
    context.push('/register');
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isDesktop = ResponsiveHelper.isDesktop(context);
    final isTablet = ResponsiveHelper.isTablet(context);

    return Scaffold(
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state.status == AuthStatus.authenticated) {
            context.go('/discover');
          }
        },
        child: SafeArea(
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
                          Icons.headphones,
                          size: ResponsiveHelper.getFontSize(context, 70),
                          color: Colors.purple,
                        ),
                        SizedBox(
                            height:
                                ResponsiveHelper.isMobile(context) ? 20 : 32),
                        Text(
                          l10n.welcomeToPodcat,
                          style: TextStyle(
                            fontSize: ResponsiveHelper.getFontSize(context, 24),
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(
                            height:
                                ResponsiveHelper.isMobile(context) ? 8 : 12),
                        Text(
                          l10n.signInToContinue,
                          style: TextStyle(
                            fontSize: ResponsiveHelper.getFontSize(context, 16),
                            color: Colors.grey,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(
                            height:
                                ResponsiveHelper.isMobile(context) ? 24 : 36),
                        TextFormField(
                          controller: _usernameController,
                          decoration: InputDecoration(
                            labelText: l10n.username,
                            prefixIcon: const Icon(Icons.person),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return l10n.pleaseEnterUsername;
                            }
                            return null;
                          },
                        ),
                        SizedBox(
                            height:
                                ResponsiveHelper.isMobile(context) ? 16 : 24),
                        TextFormField(
                          controller: _passwordController,
                          obscureText: _obscurePassword,
                          decoration: InputDecoration(
                            labelText: l10n.password,
                            prefixIcon: const Icon(Icons.lock),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscurePassword
                                    ? Icons.visibility
                                    : Icons.visibility_off,
                              ),
                              onPressed: () {
                                setState(() {
                                  _obscurePassword = !_obscurePassword;
                                });
                              },
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return l10n.pleaseEnterPassword;
                            }
                            return null;
                          },
                        ),
                        SizedBox(
                            height:
                                ResponsiveHelper.isMobile(context) ? 24 : 36),
                        BlocBuilder<AuthBloc, AuthState>(
                          builder: (context, state) {
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                if (state.error != null)
                                  Padding(
                                    padding: const EdgeInsets.only(bottom: 16),
                                    child: Text(
                                      state.error!,
                                      style: const TextStyle(
                                        color: Colors.red,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ElevatedButton(
                                  onPressed: state.status == AuthStatus.loading
                                      ? null
                                      : _login,
                                  style: ElevatedButton.styleFrom(
                                    padding: EdgeInsets.symmetric(
                                      vertical:
                                          ResponsiveHelper.isMobile(context)
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
                                          l10n.login,
                                          style: TextStyle(
                                            fontSize:
                                                ResponsiveHelper.getFontSize(
                                                    context, 16),
                                          ),
                                        ),
                                ),
                              ],
                            );
                          },
                        ),
                        SizedBox(
                            height:
                                ResponsiveHelper.isMobile(context) ? 16 : 24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(l10n.dontHaveAccount),
                            TextButton(
                              onPressed: _navigateToRegister,
                              child: Text(l10n.register),
                            ),
                          ],
                        ),
                        SizedBox(
                            height:
                                ResponsiveHelper.isMobile(context) ? 16 : 24),
                        _buildLanguageSelector(),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLanguageSelector() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        TextButton(
          onPressed: () {
            context.read<LanguageBloc>().add(
                  const ChangeLanguage(locale: Locale('en')),
                );
          },
          child: const Text('English'),
        ),
        const SizedBox(width: 16),
        TextButton(
          onPressed: () {
            context.read<LanguageBloc>().add(
                  const ChangeLanguage(locale: Locale('vi')),
                );
          },
          child: const Text('Tiếng Việt'),
        ),
      ],
    );
  }
}
