import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:podcat/generated/app_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:podcat/blocs/auth/auth_bloc.dart';
import 'package:podcat/core/utils/responsive_helper.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    // Add a small delay for splash screen
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    final authState = context.read<AuthBloc>().state;

    if (authState.status == AuthStatus.authenticated) {
      _navigateToHome();
    } else if (authState.status == AuthStatus.unauthenticated) {
      _navigateToLogin();
    }
  }

  void _navigateToHome() {
    context.go('/discover');
  }

  void _navigateToLogin() {
    context.go('/login');
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state.status == AuthStatus.authenticated) {
          _navigateToHome();
        } else if (state.status == AuthStatus.unauthenticated) {
          _navigateToLogin();
        }
      },
      child: Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'assets/images/logo.png',
                width: ResponsiveHelper.isMobile(context) ? 120 : 180,
                height: ResponsiveHelper.isMobile(context) ? 120 : 180,
                errorBuilder: (context, error, stackTrace) {
                  return Icon(
                    Icons.headphones,
                    size: ResponsiveHelper.isMobile(context) ? 80 : 120,
                    color: Colors.purple,
                  );
                },
              ),
              SizedBox(height: ResponsiveHelper.isMobile(context) ? 20 : 32),
              Text(
                l10n.appName,
                style: TextStyle(
                  fontSize: ResponsiveHelper.getFontSize(context, 28),
                  fontWeight: FontWeight.bold,
                  color: Colors.purple,
                ),
              ),
              SizedBox(height: ResponsiveHelper.isMobile(context) ? 12 : 16),
              Text(
                l10n.appSlogan,
                style: TextStyle(
                  fontSize: ResponsiveHelper.getFontSize(context, 16),
                  color: Colors.grey,
                ),
              ),
              SizedBox(height: ResponsiveHelper.isMobile(context) ? 40 : 60),
              const CircularProgressIndicator(),
            ],
          ),
        ),
      ),
    );
  }
}
