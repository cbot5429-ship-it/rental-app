import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../main.dart' show supabase;
import '../widgets/common/app_button.dart';
import '../widgets/common/app_text_field.dart';
import '../widgets/common/app_card.dart';
import '../theme/app_theme.dart';

// ============================================================
// LOGIN SCREEN - Modern Split Layout with Social Login
// ============================================================
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with SingleTickerProviderStateMixin {
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _loading = false;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );
    _slideAnimation = Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _signIn() async {
    if (_emailCtrl.text.trim().isEmpty || _passCtrl.text.isEmpty) return;
    setState(() => _loading = true);
    try {
      await supabase.auth.signInWithPassword(
        email: _emailCtrl.text.trim(),
        password: _passCtrl.text,
      );
    } on AuthException catch (e) {
      _showError(e.message);
    } catch (e) {
      _showError('Something went wrong: $e');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _sendPasswordReset() async {
    if (_emailCtrl.text.trim().isEmpty) {
      _showError('Enter your email first');
      return;
    }
    try {
      await supabase.auth.resetPasswordForEmail(_emailCtrl.text.trim());
      _showInfo('Password reset link sent. Check your email.');
    } catch (e) {
      _showError('$e');
    }
  }

  Future<void> _signInWithGoogle() async {
    setState(() => _loading = true);
    try {
      await supabase.auth.signInWithOAuth(OAuthProvider.google);
    } catch (e) {
      _showError('Google sign-in failed: $e');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _showError(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: Theme.of(context).colorScheme.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.md)),
      ),
    );
  }

  void _showInfo(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.md)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;
    final isTablet = size.width > 600;

    return Scaffold(
      body: Stack(
        children: [
          // Animated background gradient
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _animationController,
              builder: (context, child) {
                return Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        theme.colorScheme.primary.withOpacity(0.08 * _animationController.value),
                        theme.colorScheme.secondary.withOpacity(0.05 * _animationController.value),
                        theme.scaffoldBackgroundColor,
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          // Floating decorative shapes
          if (isTablet) ...[
            Positioned(
              top: -100,
              right: -100,
              child: Opacity(
                opacity: 0.1 * _animationController.value,
                child: Container(
                  width: 300,
                  height: 300,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [theme.colorScheme.primary, theme.colorScheme.primary.withOpacity(0)],
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: -150,
              left: -150,
              child: Opacity(
                opacity: 0.08 * _animationController.value,
                child: Container(
                  width: 400,
                  height: 400,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [theme.colorScheme.secondary, theme.colorScheme.secondary.withOpacity(0)],
                    ),
                  ),
                ),
              ),
            ),
          ],

          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(
                  horizontal: isTablet ? AppSpacing.xxxl : AppSpacing.xl,
                  vertical: AppSpacing.xl,
                ),
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: SlideTransition(
                    position: _slideAnimation,
                    child: ConstrainedBox(
                      constraints: BoxConstraints(maxWidth: isTablet ? 480 : double.infinity),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Logo & Branding
                          _buildHeader(theme),
                          const SizedBox(height: AppSpacing.xxxl),

                          // Login Card
                          _buildLoginCard(theme),
                          const SizedBox(height: AppSpacing.xl),

                          // Social Login
                          _buildSocialLogin(theme),
                          const SizedBox(height: AppSpacing.xl),

                          // Sign Up Link
                          _buildSignUpLink(theme),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(ThemeData theme) {
    return Column(
      children: [
        // App Logo with animation
        AnimatedBuilder(
          animation: _animationController,
          builder: (context, child) {
            return Transform.scale(
              scale: 0.8 + (0.2 * _animationController.value),
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [theme.colorScheme.primary, theme.colorScheme.secondary],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(AppRadius.xxl),
                  boxShadow: [
                    BoxShadow(
                      color: theme.colorScheme.primary.withOpacity(0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: const Icon(Icons.home_work, color: Colors.white, size: 40),
              ),
            );
          },
        ),
        const SizedBox(height: AppSpacing.lg),
        Text(
          'Welcome Back',
          style: theme.textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.w800,
            letterSpacing: -0.5,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          'Sign in to find your perfect rental',
          style: theme.textTheme.bodyLarge?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildLoginCard(ThemeData theme) {
    return AppCard.level2(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Form(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Email Field
            AppTextField(
              controller: _emailCtrl,
              label: 'Email Address',
              hint: 'you@example.com',
              prefixIcon: Icons.email_outlined,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              autofillHints: const [AutofillHints.email],
              validator: (value) {
                if (value == null || value.trim().isEmpty) return 'Email is required';
                if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value.trim())) {
                  return 'Enter a valid email';
                }
                return null;
              },
            ),
            const SizedBox(height: AppSpacing.md),

            // Password Field
            AppPasswordField(
              controller: _passCtrl,
              label: 'Password',
              hint: '••••••••',
              prefixIcon: Icons.lock_outline,
              textInputAction: TextInputAction.done,
              autofillHints: const [AutofillHints.password],
              onChanged: (value) => setState(() {}),
              validator: (value) {
                if (value == null || value.isEmpty) return 'Password is required';
                return null;
              },
            ),

            // Forgot Password
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: _sendPasswordReset,
                child: Text(
                  'Forgot Password?',
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),

            const SizedBox(height: AppSpacing.lg),

            // Login Button
            AppPrimaryButton(
              label: 'Sign In',
              onPressed: _loading ? null : _signIn,
              loading: _loading,
              icon: Icons.login,
            ),

            // Divider
            const SizedBox(height: AppSpacing.lg),
            _buildDivider(theme),
            const SizedBox(height: AppSpacing.lg),

            // Quick Actions
            Row(
              children: [
                Expanded(
                  child: AppOutlineButton(
                    label: 'Continue as Guest',
                    onPressed: () {
                      // Handle guest mode
                    },
                    icon: Icons.person_outline,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDivider(ThemeData theme) {
    return Row(
      children: [
        Expanded(child: Divider(color: theme.dividerColor, thickness: 1)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
          child: Text(
            'OR',
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Expanded(child: Divider(color: theme.dividerColor, thickness: 1)),
      ],
    );
  }

  Widget _buildSocialLogin(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AppOutlineButton(
          label: 'Continue with Google',
          onPressed: _loading ? null : _signInWithGoogle,
          loading: _loading,
          icon: Icons.g_mobiledata,
        ),
        const SizedBox(height: AppSpacing.md),
        AppOutlineButton(
          label: 'Continue with Apple',
          onPressed: () {},
          icon: Icons.apple,
        ),
      ],
    );
  }

  Widget _buildSignUpLink(ThemeData theme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          "Don't have an account? ",
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        TextButton(
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const SignUpScreen()),
          ),
          style: TextButton.styleFrom(
            padding: EdgeInsets.zero,
            minimumSize: Size.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          child: Text(
            'Sign Up',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}

// ============================================================
// SIGN UP SCREEN - Modern Split Layout with Password Strength
// ============================================================
class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> with SingleTickerProviderStateMixin {
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  bool _loading = false;
  bool _agreeToTerms = false;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  int get _passwordStrength {
    final password = _passCtrl.text;
    if (password.isEmpty) return 0;
    int strength = 0;
    if (password.length >= 8) strength++;
    if (RegExp(r'[A-Z]').hasMatch(password)) strength++;
    if (RegExp(r'[a-z]').hasMatch(password)) strength++;
    if (RegExp(r'[0-9]').hasMatch(password)) strength++;
    if (RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(password)) strength++;
    return strength.clamp(0, 5);
  }

  String get _strengthLabel {
    switch (_passwordStrength) {
      case 0:
        return '';
      case 1:
        return 'Very Weak';
      case 2:
        return 'Weak';
      case 3:
        return 'Fair';
      case 4:
        return 'Strong';
      case 5:
        return 'Very Strong';
      default:
        return '';
    }
  }

  Color get _strengthColor {
    switch (_passwordStrength) {
      case 0:
        return Colors.transparent;
      case 1:
        return Colors.red;
      case 2:
        return Colors.orange;
      case 3:
        return Colors.amber;
      case 4:
        return Colors.lightGreen;
      case 5:
        return Colors.green;
      default:
        return Colors.transparent;
    }
  }

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );
    _slideAnimation = Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic),
    );
    _animationController.forward();

    _passCtrl.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passCtrl.dispose();
    _confirmCtrl.dispose();
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _signUp() async {
    if (_nameCtrl.text.trim().isEmpty ||
        _emailCtrl.text.trim().isEmpty ||
        _passCtrl.text.isEmpty ||
        _confirmCtrl.text.isEmpty) {
      _showError('Fill in all fields');
      return;
    }
    if (_passCtrl.text != _confirmCtrl.text) {
      _showError('Passwords do not match');
      return;
    }
    if (_passCtrl.text.length < 8) {
      _showError('Password must be at least 8 characters');
      return;
    }
    if (!_agreeToTerms) {
      _showError('Please agree to Terms of Service');
      return;
    }
    setState(() => _loading = true);
    try {
      final res = await supabase.auth.signUp(
        email: _emailCtrl.text.trim(),
        password: _passCtrl.text,
        data: {'full_name': _nameCtrl.text.trim()},
      );

      if (res.session == null) {
        _showInfo('Account created. Check your email to confirm before logging in.');
        if (mounted) Navigator.pop(context);
      } else {
        if (mounted) Navigator.pop(context);
      }
    } on AuthException catch (e) {
      _showError(e.message);
    } catch (e) {
      _showError('$e');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _signUpWithGoogle() async {
    setState(() => _loading = true);
    try {
      await supabase.auth.signInWithOAuth(OAuthProvider.google);
    } catch (e) {
      _showError('Google sign-up failed: $e');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _showError(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: Theme.of(context).colorScheme.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.md)),
      ),
    );
  }

  void _showInfo(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.md)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;
    final isTablet = size.width > 600;

    return Scaffold(
      body: Stack(
        children: [
          // Animated background gradient
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _animationController,
              builder: (context, child) {
                return Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        theme.colorScheme.primary.withOpacity(0.08 * _animationController.value),
                        theme.colorScheme.secondary.withOpacity(0.05 * _animationController.value),
                        theme.scaffoldBackgroundColor,
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          // Floating decorative shapes
          if (isTablet) ...[
            Positioned(
              top: -100,
              right: -100,
              child: Opacity(
                opacity: 0.1 * _animationController.value,
                child: Container(
                  width: 300,
                  height: 300,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [theme.colorScheme.primary, theme.colorScheme.primary.withOpacity(0)],
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: -150,
              left: -150,
              child: Opacity(
                opacity: 0.08 * _animationController.value,
                child: Container(
                  width: 400,
                  height: 400,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [theme.colorScheme.secondary, theme.colorScheme.secondary.withOpacity(0)],
                    ),
                  ),
                ),
              ),
            ),
          ],

          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(
                  horizontal: isTablet ? AppSpacing.xxxl : AppSpacing.xl,
                  vertical: AppSpacing.xl,
                ),
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: SlideTransition(
                    position: _slideAnimation,
                    child: ConstrainedBox(
                      constraints: BoxConstraints(maxWidth: isTablet ? 480 : double.infinity),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Back Button
                          Align(
                            alignment: Alignment.centerLeft,
                            child: AppIconButton(
                              icon: Icons.arrow_back,
                              onPressed: () => Navigator.pop(context),
                              size: 44,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.md),

                          // Logo & Branding
                          _buildHeader(theme),
                          const SizedBox(height: AppSpacing.xxxl),

                          // Sign Up Card
                          _buildSignUpCard(theme),
                          const SizedBox(height: AppSpacing.xl),

                          // Social Sign Up
                          _buildSocialSignUp(theme),
                          const SizedBox(height: AppSpacing.xl),

                          // Login Link
                          _buildLoginLink(theme),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(ThemeData theme) {
    return Column(
      children: [
        AnimatedBuilder(
          animation: _animationController,
          builder: (context, child) {
            return Transform.scale(
              scale: 0.8 + (0.2 * _animationController.value),
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [theme.colorScheme.primary, theme.colorScheme.secondary],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(AppRadius.xxl),
                  boxShadow: [
                    BoxShadow(
                      color: theme.colorScheme.primary.withOpacity(0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: const Icon(Icons.home_work, color: Colors.white, size: 40),
              ),
            );
          },
        ),
        const SizedBox(height: AppSpacing.lg),
        Text(
          'Create Account',
          style: theme.textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.w800,
            letterSpacing: -0.5,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          'Join thousands finding their perfect home',
          style: theme.textTheme.bodyLarge?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildSignUpCard(ThemeData theme) {
    return AppCard.level2(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Form(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Full Name
            AppTextField(
              controller: _nameCtrl,
              label: 'Full Name',
              hint: 'John Doe',
              prefixIcon: Icons.person_outline,
              textInputAction: TextInputAction.next,
              autofillHints: const [AutofillHints.name],
              validator: (value) {
                if (value == null || value.trim().isEmpty) return 'Name is required';
                if (value.trim().length < 2) return 'Name too short';
                return null;
              },
            ),
            const SizedBox(height: AppSpacing.md),

            // Email
            AppTextField(
              controller: _emailCtrl,
              label: 'Email Address',
              hint: 'you@example.com',
              prefixIcon: Icons.email_outlined,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              autofillHints: const [AutofillHints.email],
              validator: (value) {
                if (value == null || value.trim().isEmpty) return 'Email is required';
                if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value.trim())) {
                  return 'Enter a valid email';
                }
                return null;
              },
            ),
            const SizedBox(height: AppSpacing.md),

            // Password with Strength Indicator
            _buildPasswordField(theme),
            const SizedBox(height: AppSpacing.md),

            // Confirm Password
            AppPasswordField(
              controller: _confirmCtrl,
              label: 'Confirm Password',
              hint: '••••••••',
              prefixIcon: Icons.lock_outline,
              textInputAction: TextInputAction.done,
              autofillHints: const [AutofillHints.newPassword],
              onChanged: (value) => setState(() {}),
              validator: (value) {
                if (value == null || value.isEmpty) return 'Please confirm password';
                if (value != _passCtrl.text) return 'Passwords do not match';
                return null;
              },
            ),

            const SizedBox(height: AppSpacing.md),

            // Terms Checkbox
            _buildTermsCheckbox(theme),

            const SizedBox(height: AppSpacing.lg),

            // Sign Up Button
            AppPrimaryButton(
              label: 'Create Account',
              onPressed: _loading ? null : _signUp,
              loading: _loading,
              icon: Icons.person_add,
            ),

            // Divider
            const SizedBox(height: AppSpacing.lg),
            _buildDivider(theme),
            const SizedBox(height: AppSpacing.lg),

            // Quick Action
            Row(
              children: [
                Expanded(
                  child: AppOutlineButton(
                    label: 'Continue as Guest',
                    onPressed: () {},
                    icon: Icons.person_outline,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPasswordField(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppPasswordField(
          controller: _passCtrl,
          label: 'Password',
          hint: 'At least 8 characters',
          prefixIcon: Icons.lock_outline,
          textInputAction: TextInputAction.next,
          autofillHints: const [AutofillHints.newPassword],
          validator: (value) {
            if (value == null || value.isEmpty) return 'Password is required';
            if (value.length < 8) return 'Password must be at least 8 characters';
            return null;
          },
        ),

        // Password Strength Indicator
        if (_passCtrl.text.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.sm),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  // Strength Bars
                  Expanded(
                    child: Row(
                      children: List.generate(5, (index) {
                        final isActive = index < _passwordStrength;
                        return Expanded(
                          child: AnimatedContainer(
                            duration: AppDuration.normal,
                            curve: AppCurves.standard,
                            height: 6,
                            margin: EdgeInsets.only(right: index < 4 ? AppSpacing.xs : 0),
                            decoration: BoxDecoration(
                              color: isActive ? _strengthColor : theme.colorScheme.surfaceContainerHighest,
                              borderRadius: BorderRadius.circular(AppRadius.round),
                            ),
                          ),
                        );
                      }),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  // Strength Label
                  AnimatedSwitcher(
                    duration: AppDuration.normal,
                    child: Text(
                      _strengthLabel,
                      key: ValueKey(_strengthLabel),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: _strengthColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),

              // Password Requirements
              const SizedBox(height: AppSpacing.sm),
              _buildPasswordRequirements(theme),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildPasswordRequirements(ThemeData theme) {
    final password = _passCtrl.text;
    final requirements = [
      (password.length >= 8, 'At least 8 characters'),
      (RegExp(r'[A-Z]').hasMatch(password), 'One uppercase letter'),
      (RegExp(r'[a-z]').hasMatch(password), 'One lowercase letter'),
      (RegExp(r'[0-9]').hasMatch(password), 'One number'),
      (RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(password), 'One special character'),
    ];

    return Wrap(
      spacing: AppSpacing.md,
      runSpacing: AppSpacing.xs,
      children: requirements.map((req) {
        final (met, label) = req;
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: 4),
          decoration: BoxDecoration(
            color: met ? Colors.green.withOpacity(0.1) : theme.colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(AppRadius.round),
            border: Border.all(
              color: met ? Colors.green : theme.dividerColor,
              width: 0.5,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                met ? Icons.check_circle : Icons.circle_outlined,
                size: 12,
                color: met ? Colors.green : theme.colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: 4),
              Text(
                label,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: met ? Colors.green : theme.colorScheme.onSurfaceVariant,
                  fontWeight: met ? FontWeight.w600 : FontWeight.w500,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildTermsCheckbox(ThemeData theme) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Checkbox(
          value: _agreeToTerms,
          onChanged: (value) => setState(() => _agreeToTerms = value ?? false),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.sm)),
        ),
        const SizedBox(width: AppSpacing.xs),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 8),
            child: RichText(
              text: TextSpan(
                style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                children: [
                  const TextSpan(text: 'I agree to the '),
                  TextSpan(
                    text: 'Terms of Service',
                    style: TextStyle(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.w600,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                  const TextSpan(text: ' and '),
                  TextSpan(
                    text: 'Privacy Policy',
                    style: TextStyle(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.w600,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDivider(ThemeData theme) {
    return Row(
      children: [
        Expanded(child: Divider(color: theme.dividerColor, thickness: 1)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
          child: Text(
            'OR',
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Expanded(child: Divider(color: theme.dividerColor, thickness: 1)),
      ],
    );
  }

  Widget _buildSocialSignUp(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AppOutlineButton(
          label: 'Sign up with Google',
          onPressed: _loading ? null : _signUpWithGoogle,
          loading: _loading,
          icon: Icons.g_mobiledata,
        ),
        const SizedBox(height: AppSpacing.md),
        AppOutlineButton(
          label: 'Sign up with Apple',
          onPressed: () {},
          icon: Icons.apple,
        ),
      ],
    );
  }

  Widget _buildLoginLink(ThemeData theme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Already have an account? ',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context),
          style: TextButton.styleFrom(
            padding: EdgeInsets.zero,
            minimumSize: Size.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          child: Text(
            'Sign In',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}