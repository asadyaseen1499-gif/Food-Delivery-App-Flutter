import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../firebase/auth_service.dart';
import '../tabs/home_screen.dart';
import 'forgot_password_screen.dart';
import 'signup_screen.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/loading_overlay.dart';
import '../../widgets/app_styles.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final AuthService _authService = AuthService();

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _isLoading = false;
  bool _obscurePassword = true;
  String? _backendPasswordError;
  String? _backendEmailError;

  // --- 1. EMAIL/PASS LOGIN ---
  void _submitLogin() async {
    setState(() {
      _backendPasswordError = null;
      _backendEmailError = null;
    });
    FocusScope.of(context).unfocus();

    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      try {
        await _authService.signIn(
          _emailController.text.trim(),
          _passwordController.text.trim(),
        );

        if (!mounted) return;
        Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const HomeScreen())
        );

      } catch (e) {
        if (!mounted) return;
        String errorText = e.toString().toLowerCase();

        if (errorText.contains('password') || errorText.contains('credential') || errorText.contains('invalid-login')) {
          setState(() => _backendPasswordError = "Incorrect password or email");
        } else if (errorText.contains('user-not-found') || errorText.contains('no user') || errorText.contains('invalid-email')) {
          setState(() => _backendEmailError = "No account found with this email");
        } else if (errorText.contains('network') || errorText.contains('connection')) {
          _showMessage("Network error. Please check your internet.", Colors.red);
        } else {
          _showMessage("Error: ${e.toString()}", Colors.red);
        }

        _formKey.currentState!.validate();

      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  // --- 2. GOOGLE LOGIN ---
  void _handleGoogleSignIn() async {
    setState(() => _isLoading = true);
    try {
      final user = await _authService.signInWithGoogle();
      if (!mounted) return;

      if (user != null) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const HomeScreen()),
              (route) => false,
        );
      }
    } catch (e) {
      if (mounted) _showMessage("Google Sign In Failed", Colors.red);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showMessage(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: color, behavior: SnackBarBehavior.floating),
    );
  }

  @override
  Widget build(BuildContext context) {
    // USE ANNOTATED REGION FOR PRECISE CONTROL
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,

        // Navigation Bar (Bottom)
        systemNavigationBarColor: Colors.white,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: Colors.white,
        resizeToAvoidBottomInset: false,
        body: Stack(
          children: [
            // 2. CENTER WIDGET (No ScrollView)
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    // 3. CENTER CONTENT VERTICALLY
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [

                      // HEADER ICON
                      Center(
                        child: Container(
                          height: 100, width: 100,
                          decoration: BoxDecoration(
                              color: Colors.deepOrange.shade50.withValues(alpha: 0.5),
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(color: Colors.deepOrange.withValues(alpha: 0.1), blurRadius: 20, offset: const Offset(0, 10))
                              ]
                          ),
                          child: const Icon(Icons.fastfood_rounded, size: 50, color: Colors.deepOrange),
                        ),
                      ),

                      const SizedBox(height: 30),

                      Text(
                          "Let's Sign You In",
                          style: GoogleFonts.poppins(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.black87)
                      ),
                      const SizedBox(height: 5),
                      Text(
                        "Welcome back, you've been missed!",
                        style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey[500]),
                      ),
                      const SizedBox(height: 30),

                      // EMAIL INPUT
                      TextFormField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        onChanged: (_) {
                          if(_backendEmailError != null) setState(() => _backendEmailError = null);
                        },
                        validator: (value) {
                          if (_backendEmailError != null) return _backendEmailError;
                          if (value == null || !value.contains('@')) return 'Please enter a valid email';
                          return null;
                        },
                        decoration: AppStyles.inputDecoration("Email Address", Icons.email_outlined),
                      ),
                      const SizedBox(height: 15),

                      // PASSWORD INPUT
                      TextFormField(
                        controller: _passwordController,
                        obscureText: _obscurePassword,
                        onChanged: (_) {
                          if(_backendPasswordError != null) setState(() => _backendPasswordError = null);
                        },
                        validator: (value) {
                          if (_backendPasswordError != null) return _backendPasswordError;
                          if (value == null || value.length < 6) return 'Password must be at least 6 characters';
                          return null;
                        },
                        decoration: AppStyles.inputDecoration("Password", Icons.lock_outline).copyWith(
                          suffixIcon: IconButton(
                            icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility, color: Colors.grey),
                            onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                          ),
                        ),
                      ),

                      // FORGOT PASSWORD
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () {
                            // NAVIGATE TO FORGOT PASSWORD SCREEN
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const ForgotPasswordScreen()),
                            );
                          },
                          child: Text(
                              "Forgot Password?",
                              style: TextStyle(color: Colors.deepOrange.shade400, fontWeight: FontWeight.w600)
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),

                      // SIGN IN BUTTON
                      CustomButton(
                        text: "Sign In",
                        onPressed: _submitLogin,
                      ),

                      const SizedBox(height: 25),

                      // DIVIDER
                      Row(children: [
                        Expanded(child: Divider(color: Colors.grey[200])),
                        Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            child: Text("Or", style: TextStyle(color: Colors.grey[400], fontWeight: FontWeight.w500))
                        ),
                        Expanded(child: Divider(color: Colors.grey[200])),
                      ]),

                      const SizedBox(height: 25),

                      // GOOGLE BUTTON
                      Container(
                        width: double.infinity,
                        height: 55,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(30),
                          border: Border.all(color: Colors.grey.shade200),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withValues(alpha: 0.05),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: _isLoading ? null : _handleGoogleSignIn,
                            borderRadius: BorderRadius.circular(30),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Image.asset(
                                  'assets/images/google.jpg',
                                  height: 24,
                                  width: 24,
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  "Continue with Google",
                                  style: GoogleFonts.poppins(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.black87,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 30),

                      // FOOTER
                      Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                        Text("Don't have an account? ", style: TextStyle(color: Colors.grey[600])),
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const SignupScreen()),
                            );
                          },
                          child: const Text("Sign Up", style: TextStyle(color: Colors.deepOrange, fontWeight: FontWeight.bold)),
                        ),
                      ]),
                    ],
                  ),
                ),
              ),
            ),
            if (_isLoading) const LoadingOverlay(),
          ],
        ),
      ),
    );
  }
}