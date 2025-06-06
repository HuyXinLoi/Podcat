import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:podcat/blocs/auth/auth_bloc.dart';
import 'package:podcat/blocs/language/language_bloc.dart';
import 'package:podcat/core/utils/responsive_helper.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.8, curve: Curves.easeOut),
      ),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.2, 1.0, curve: Curves.elasticOut),
      ),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    _animationController.dispose();
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
    final l10n = AppLocalizations.of(context)!;
    final isDesktop = ResponsiveHelper.isDesktop(context);
    final isTablet = ResponsiveHelper.isTablet(context);
    final theme = Theme.of(context);

    return Scaffold(
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state.status == AuthStatus.authenticated) {
            context.go('/discover');
          }
        },
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                theme.colorScheme.primary,
                theme.colorScheme.secondary,
              ],
            ),
          ),
          child: SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: ResponsiveHelper.getPadding(context),
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: SlideTransition(
                    position: _slideAnimation,
                    child: Container(
                      constraints: BoxConstraints(
                        maxWidth: isDesktop
                            ? 480
                            : isTablet
                                ? 420
                                : double.infinity,
                      ),
                      child: Card(
                        elevation: 0,
                        shadowColor: Colors.transparent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(32),
                        ),
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(32),
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                theme.colorScheme.surface,
                                theme.colorScheme.surface,
                              ],
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black,
                                blurRadius: 30,
                                offset: const Offset(0, 15),
                              ),
                            ],
                          ),
                          child: Padding(
                            padding: EdgeInsets.all(
                                ResponsiveHelper.isMobile(context) ? 32 : 40),
                            child: Form(
                              key: _formKey,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  _buildHeader(context, theme, l10n),
                                  SizedBox(
                                      height: ResponsiveHelper.isMobile(context)
                                          ? 40
                                          : 48),
                                  _buildForm(context, theme, l10n),
                                  SizedBox(
                                      height: ResponsiveHelper.isMobile(context)
                                          ? 32
                                          : 40),
                                  _buildLoginButton(context, theme, l10n),
                                  SizedBox(
                                      height: ResponsiveHelper.isMobile(context)
                                          ? 24
                                          : 32),
                                  _buildRegisterLink(context, theme, l10n),
                                  SizedBox(
                                      height: ResponsiveHelper.isMobile(context)
                                          ? 24
                                          : 32),
                                  _buildLanguageSelector(context, theme),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
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

  Widget _buildHeader(
      BuildContext context, ThemeData theme, AppLocalizations l10n) {
    return Column(
      children: [
        Hero(
          tag: 'app_logo',
          child: Container(
            width: ResponsiveHelper.isMobile(context) ? 80 : 100,
            height: ResponsiveHelper.isMobile(context) ? 80 : 100,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  theme.colorScheme.primary,
                  theme.colorScheme.secondary,
                ],
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: theme.colorScheme.primary,
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Icon(
              Icons.headphones_rounded,
              size: ResponsiveHelper.getFontSize(context, 40),
              color: Colors.white,
            ),
          ),
        ),
        SizedBox(height: ResponsiveHelper.isMobile(context) ? 24 : 32),
        Text(
          l10n.welcomeToPodcat,
          style: TextStyle(
            fontSize: ResponsiveHelper.getFontSize(context, 28),
            fontWeight: FontWeight.w800,
            color: theme.colorScheme.onSurface,
            letterSpacing: -0.5,
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: ResponsiveHelper.isMobile(context) ? 8 : 12),
        Text(
          l10n.signInToContinue,
          style: TextStyle(
            fontSize: ResponsiveHelper.getFontSize(context, 16),
            color: theme.colorScheme.onSurface,
            fontWeight: FontWeight.w500,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildForm(
      BuildContext context, ThemeData theme, AppLocalizations l10n) {
    return Column(
      children: [
        TextFormField(
          controller: _usernameController,
          decoration: InputDecoration(
            labelText: l10n.username,
            prefixIcon: Icon(
              Icons.person_rounded,
              color: theme.colorScheme.primary,
            ),
            hintText: l10n.pleaseEnterUsername,
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return l10n.pleaseEnterUsername;
            }
            return null;
          },
          textInputAction: TextInputAction.next,
        ),
        SizedBox(height: ResponsiveHelper.isMobile(context) ? 20 : 24),
        TextFormField(
          controller: _passwordController,
          obscureText: _obscurePassword,
          decoration: InputDecoration(
            labelText: l10n.password,
            prefixIcon: Icon(
              Icons.lock_rounded,
              color: theme.colorScheme.primary,
            ),
            hintText: l10n.pleaseEnterPassword,
            suffixIcon: IconButton(
              icon: Icon(
                _obscurePassword
                    ? Icons.visibility_rounded
                    : Icons.visibility_off_rounded,
                color: theme.colorScheme.onSurface,
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
          onFieldSubmitted: (_) => _login(),
        ),
      ],
    );
  }

  Widget _buildLoginButton(
      BuildContext context, ThemeData theme, AppLocalizations l10n) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (state.error != null) ...[
              Container(
                padding:
                    const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: theme.colorScheme.errorContainer,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: theme.colorScheme.error,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.error_outline_rounded,
                      color: theme.colorScheme.onErrorContainer,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        state.error!,
                        style: TextStyle(
                          color: theme.colorScheme.onErrorContainer,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    theme.colorScheme.primary,
                    theme.colorScheme.secondary,
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: theme.colorScheme.primary,
                    blurRadius: 15,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: ElevatedButton(
                onPressed: state.status == AuthStatus.loading ? null : _login,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  padding: EdgeInsets.symmetric(
                    vertical: ResponsiveHelper.isMobile(context) ? 18 : 22,
                  ),
                ),
                child: state.status == AuthStatus.loading
                    ? SizedBox(
                        height: 24,
                        width: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          color: Colors.white,
                        ),
                      )
                    : Text(
                        l10n.login,
                        style: TextStyle(
                          fontSize: ResponsiveHelper.getFontSize(context, 16),
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildRegisterLink(
      BuildContext context, ThemeData theme, AppLocalizations l10n) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          l10n.dontHaveAccount,
          style: TextStyle(
            color: theme.colorScheme.onSurface,
            fontWeight: FontWeight.w500,
          ),
        ),
        TextButton(
          onPressed: _navigateToRegister,
          child: Text(
            l10n.register,
            style: TextStyle(
              fontWeight: FontWeight.w700,
              color: theme.colorScheme.primary,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLanguageSelector(BuildContext context, ThemeData theme) {
    return Column(
      children: [
        Container(
          height: 1,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.transparent,
                theme.dividerTheme.color!,
                Colors.transparent,
              ],
            ),
          ),
        ),
        const SizedBox(height: 20),
        Text(
          'Language / Ngôn ngữ',
          style: TextStyle(
            fontSize: ResponsiveHelper.getFontSize(context, 14),
            color: theme.colorScheme.onSurface,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildLanguageButton(
              'English',
              const Locale('en'),
              context.read<LanguageBloc>().state.locale.languageCode == 'en',
              theme,
            ),
            const SizedBox(width: 16),
            _buildLanguageButton(
              'Tiếng Việt',
              const Locale('vi'),
              context.read<LanguageBloc>().state.locale.languageCode == 'vi',
              theme,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildLanguageButton(
      String label, Locale locale, bool isSelected, ThemeData theme) {
    return InkWell(
      onTap: () {
        context.read<LanguageBloc>().add(ChangeLanguage(locale: locale));
      },
      borderRadius: BorderRadius.circular(25),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? theme.colorScheme.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(25),
          border: Border.all(
            color: isSelected
                ? theme.colorScheme.primary
                : theme.colorScheme.onSurface,
            width: 1.5,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected
                ? theme.colorScheme.onPrimary
                : theme.colorScheme.onSurface,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
