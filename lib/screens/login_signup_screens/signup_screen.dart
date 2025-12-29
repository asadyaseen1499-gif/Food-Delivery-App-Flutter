import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../firebase/auth_service.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/loading_overlay.dart';
import '../../widgets/app_styles.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final AuthService _authService = AuthService();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  bool _isLoading = false;
  bool _obscurePassword = true;
  String? _backendEmailError;

  void _submitForm() async {
    setState(() => _backendEmailError = null);
    FocusScope.of(context).unfocus();

    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      try {
        await _authService.signUp(
          _emailController.text.trim(),
          _passwordController.text.trim(),
        );

        if (!mounted) return;

        // HIDE LOADING OVERLAY BEFORE SHOWING SUCCESS DIALOG
        setState(() => _isLoading = false);

        // --- SHOW THEMED SUCCESS DIALOG ---
        await showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) {
            return Dialog(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              elevation: 0,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // 1. Themed Icon Bubble
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.deepOrange.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.check_rounded,
                        size: 48,
                        color: Colors.deepOrange,
                      ),
                    ),
                    const SizedBox(height: 24),
                    // 2. Subtitle
                    Text(
                      "Your account has been created",
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: Colors.grey[600],
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ).timeout(const Duration(seconds: 2), onTimeout: () {
          if (mounted && Navigator.canPop(context)) {
            Navigator.pop(context);
          }
        });

        // --- NAVIGATE TO LOGIN ---
        if (!mounted) return;
        Navigator.pop(context);

      } catch (e) {
        // ERROR HANDLING
        setState(() => _isLoading = false);
        String errorText = e.toString().toLowerCase();

        if (errorText.contains('email-already-in-use')) {
          setState(() => _backendEmailError = "This email is already registered.");
        } else if (errorText.contains('invalid-email')) {
          setState(() => _backendEmailError = "Please enter a valid email address.");
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red),
          );
        }
        _formKey.currentState!.validate();
      }
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      // Keep this TRUE so the keyboard doesn't hide your input fields
      resizeToAvoidBottomInset: true,
      body: Stack(
        children: [
          // 1. SCROLL VIEW
          SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(height: MediaQuery.of(context).size.height * 0.15),

                  Text("Create Account", style: GoogleFonts.poppins(fontSize: 28, fontWeight: FontWeight.bold)),
                  Text("Sign up to get started!", style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey[600])),
                  const SizedBox(height: 30),

                  // NAME
                  TextFormField(
                    controller: _nameController,
                    decoration: AppStyles.inputDecoration("Full Name", Icons.person_outline),
                    validator: (val) => val!.isEmpty ? "Please enter your name" : null,
                  ),
                  const SizedBox(height: 20),

                  // EMAIL
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    onChanged: (_) {
                      if(_backendEmailError != null) setState(() => _backendEmailError = null);
                    },
                    validator: (val) {
                      if (_backendEmailError != null) return _backendEmailError;
                      if (val == null || !val.contains('@')) return 'Invalid email';
                      return null;
                    },
                    decoration: AppStyles.inputDecoration("Email Address", Icons.email_outlined),
                  ),
                  const SizedBox(height: 20),

                  // PASSWORD
                  TextFormField(
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    validator: (val) => val!.length < 6 ? "Password must be 6+ chars" : null,
                    decoration: AppStyles.inputDecoration("Password", Icons.lock_outline).copyWith(
                      suffixIcon: IconButton(
                        icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility, color: Colors.grey),
                        onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // CONFIRM PASSWORD
                  TextFormField(
                    controller: _confirmPasswordController,
                    obscureText: _obscurePassword,
                    validator: (val) {
                      if (val != _passwordController.text) return "Passwords do not match";
                      return null;
                    },
                    decoration: AppStyles.inputDecoration("Confirm Password", Icons.lock_outline).copyWith(
                      suffixIcon: IconButton(
                        icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility, color: Colors.grey),
                        onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),

                  // BUTTON
                  CustomButton(
                    text: "Sign Up",
                    onPressed: _submitForm,
                  ),

                  const SizedBox(height: 20),
                  Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                    Text("Already have an account? ", style: TextStyle(color: Colors.grey[700])),
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: const Text("Sign In", style: TextStyle(color: Colors.deepOrange, fontWeight: FontWeight.bold)),
                    ),
                  ]),
                  const SizedBox(height: 50),
                ],
              ),
            ),
          ),

          if (_isLoading) const LoadingOverlay(),
        ],
      ),
    );
  }}