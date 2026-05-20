import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import '../utils/transitions.dart';
import 'main_layout.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with SingleTickerProviderStateMixin {
  final _emailController = TextEditingController(text: 'ajdyreambonanza@gmail.com');
  final _passwordController = TextEditingController(text: '123456');
  bool _obscurePassword = true;
  final _formKey = GlobalKey<FormState>();

  late AnimationController _animController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animController,
      curve: const Interval(0.0, 0.8, curve: Curves.easeOut),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0.0, 0.05),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animController,
      curve: const Interval(0.2, 1.0, curve: Curves.easeOutCubic),
    ));
    _animController.forward();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _animController.dispose();
    super.dispose();
  }

  void _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;
    
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final success = await auth.login(
      _emailController.text.trim(),
      _passwordController.text,
    );

    if (success && mounted) {
      Navigator.of(context).pushReplacement(
        FadeSlidePageRoute(page: const MainLayout()),
      );
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.error_outline, color: Colors.white),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  auth.error ?? 'Login Failed',
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
              ),
            ],
          ),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.redAccent,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          margin: const EdgeInsets.all(16),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = context.watch<AuthProvider>().isLoading;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      body: Stack(
        children: [
          // Background soft gradient blobs
          Positioned(
            top: -100,
            left: -50,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: theme.colorScheme.primary.withOpacity(isDark ? 0.15 : 0.08),
              ),
            ),
          ),
          Positioned(
            bottom: -50,
            right: -50,
            child: Container(
              width: 350,
              height: 350,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: theme.colorScheme.secondary.withOpacity(isDark ? 0.12 : 0.06),
              ),
            ),
          ),
          // Blur layer for background blobs
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 90, sigmaY: 90),
              child: const SizedBox.shrink(),
            ),
          ),
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 28.0, vertical: 24.0),
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: SlideTransition(
                    position: _slideAnimation,
                    child: Form(
                      key: _formKey,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Custom styled logo
                          Center(
                            child: Container(
                              padding: const EdgeInsets.all(18),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: LinearGradient(
                                  colors: [
                                    theme.colorScheme.primary,
                                    theme.colorScheme.secondary,
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: theme.colorScheme.primary.withOpacity(0.3),
                                    blurRadius: 20,
                                    offset: const Offset(0, 10),
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.school_rounded,
                                size: 48,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          const SizedBox(height: 28),
                          Text(
                            'Student Companion',
                            textAlign: TextAlign.center,
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontSize: 30,
                              fontWeight: FontWeight.w800,
                              letterSpacing: -1,
                              height: 1.2,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Manage your tasks and view grades',
                            textAlign: TextAlign.center,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontSize: 15,
                            ),
                          ),
                          const SizedBox(height: 40),
                          // Form card
                          Card(
                            elevation: isDark ? 0 : 4,
                            shadowColor: Colors.black.withOpacity(0.04),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                              side: BorderSide(
                                color: isDark ? theme.colorScheme.outline : Colors.transparent,
                                width: 1,
                              ),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(24.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  Text(
                                    'Sign In',
                                    style: theme.textTheme.titleMedium?.copyWith(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  const SizedBox(height: 20),
                                  TextFormField(
                                    controller: _emailController,
                                    decoration: const InputDecoration(
                                      labelText: 'Email Address',
                                      prefixIcon: Icon(Icons.email_outlined),
                                    ),
                                    keyboardType: TextInputType.emailAddress,
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Please enter your email';
                                      }
                                      if (!value.contains('@')) {
                                        return 'Please enter a valid email';
                                      }
                                      return null;
                                    },
                                  ),
                                  const SizedBox(height: 18),
                                  TextFormField(
                                    controller: _passwordController,
                                    decoration: InputDecoration(
                                      labelText: 'Password',
                                      prefixIcon: const Icon(Icons.lock_outline_rounded),
                                      suffixIcon: IconButton(
                                        icon: Icon(
                                          _obscurePassword
                                              ? Icons.visibility_off_outlined
                                              : Icons.visibility_outlined,
                                        ),
                                        onPressed: () {
                                          setState(() {
                                            _obscurePassword = !_obscurePassword;
                                          });
                                        },
                                      ),
                                    ),
                                    obscureText: _obscurePassword,
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Please enter your password';
                                      }
                                      return null;
                                    },
                                  ),
                                  const SizedBox(height: 24),
                                  SizedBox(
                                    height: 52,
                                    child: ElevatedButton(
                                      onPressed: isLoading ? null : _handleLogin,
                                      style: ElevatedButton.styleFrom(
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(14),
                                        ),
                                        backgroundColor: theme.colorScheme.primary,
                                        foregroundColor: Colors.white,
                                      ),
                                      child: isLoading
                                          ? const SizedBox(
                                              width: 24,
                                              height: 24,
                                              child: CircularProgressIndicator(
                                                color: Colors.white,
                                                strokeWidth: 2.5,
                                              ),
                                            )
                                          : const Text(
                                              'Login',
                                              style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
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
}
