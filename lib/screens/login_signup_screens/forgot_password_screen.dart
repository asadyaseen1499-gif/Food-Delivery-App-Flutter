import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../firebase/auth_service.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/loading_overlay.dart';
import '../../widgets/app_styles.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final AuthService _authService = AuthService();
  final TextEditingController _emailController = TextEditingController();

  bool _isLoading = false;
  String? _backendError;

  void _submit() async {
    setState(() => _backendError = null);
    FocusScope.of(context).unfocus();

    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      try {
        // 1. Call Firebase to send the link
        await _authService.resetPassword(_emailController.text.trim());

        if (!mounted) return;
        setState(() => _isLoading = false);

        // 2. Show Success Bubble (Dialog)
        _showSuccessDialog();

      } on FirebaseAuthException catch (e) {
        if (!mounted) return;

        if (e.code == 'user-not-found') {
          setState(() => _backendError = "No account found with this email.");
        } else if (e.code == 'invalid-email') {
          setState(() => _backendError = "Please enter a valid email address.");
        } else {
          _showMessage("Error: ${e.message}", Colors.red);
        }
        _formKey.currentState!.validate();
        setState(() => _isLoading = false);

      } catch (e) {
        _showMessage("Network Error", Colors.red);
        setState(() => _isLoading = false);
      }
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Success Bubble Icon
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.deepOrange.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.mark_email_read_rounded, size: 48, color: Colors.deepOrange),
                ),
                const SizedBox(height: 24),

                Text(
                  "Check Your Email",
                  style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black87),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10),

                Text(
                  "We have sent a password reset link to ${_emailController.text}.\nClick the link to set a new password.",
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey[600], height: 1.5),
                ),
                const SizedBox(height: 30),

                // Button to go back to Login
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepOrange,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: () {
                      Navigator.pop(context); // Close Dialog
                      Navigator.pop(context); // Go back to Login Screen
                    },
                    child: const Text("Back to Login", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showMessage(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: color, behavior: SnackBarBehavior.floating),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      // Removed AppBar
      body: Stack(
        children: [
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 120), // Top spacing

                    Text("Forgot Password?", style: GoogleFonts.poppins(fontSize: 28, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 10),
                    Text(
                      "Don't worry! It happens. Please enter the email address associated with your account.",
                      style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey[600], height: 1.5),
                    ),

                    const SizedBox(height: 50),

                    // EMAIL INPUT
                    Text(
                      "Email Address",
                      style: GoogleFonts.poppins(fontWeight: FontWeight.w600, color: Colors.black87),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      onChanged: (_) {
                        if(_backendError != null) setState(() => _backendError = null);
                      },
                      validator: (value) {
                        if (_backendError != null) return _backendError;
                        if (value == null || !value.contains('@')) return 'Please enter a valid email';
                        return null;
                      },
                      decoration: AppStyles.inputDecoration("Enter your email", Icons.email_outlined),
                    ),
                    const SizedBox(height: 30),

                    // SUBMIT BUTTON
                    CustomButton(
                      text: "Send Reset Link",
                      onPressed: _submit,
                    ),

                    const SizedBox(height: 30),

                    // Back to Login Link (Since we removed the top arrow)
                    Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                      Text("Remember Password? ", style: TextStyle(color: Colors.grey[700])),
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: const Text("Sign In", style: TextStyle(color: Colors.deepOrange, fontWeight: FontWeight.bold)),
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
    );
  }
}
