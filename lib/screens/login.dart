import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../ui_constants.dart'; // Import your constants file
import '../services/supabase_service.dart'; // Import SupabaseService
import '../widgets/message_modal.dart'; // Import MessageModal

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;
  final _formKey = GlobalKey<FormState>(); // Added for form validation

  Future<void> _signIn() async {
    // Validate all fields before attempting sign-in
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final AuthResponse response = await supabaseService.signIn(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      if (response.user != null) {
        // Successfully logged in
        MessageModal.show(
          context,
          MessageType.success,
          'Success',
          'You have successfully logged in!',
        );
        // Navigate to homepage and remove all previous routes
        Navigator.of(context).pushNamedAndRemoveUntil('/homepage', (route) => false);
      }
    } on AuthException catch (e) {
      MessageModal.show(
        context,
        MessageType.error,
        'Login Failed',
        e.message,
      );
    } catch (e) {
      MessageModal.show(
        context,
        MessageType.error,
        'Login Error',
        'An unexpected error occurred: ${e.toString()}',
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackground, // Use the new background color
      appBar: AppBar(
        backgroundColor: kBackground, // Match app bar background
        elevation: 0,
        title: Text(
          'Login',
          style: GoogleFonts.poppins(
            color: kPrimaryBlack,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: kDefaultPadding,
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Welcome Back!',
                  style: GoogleFonts.poppins(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: kPrimaryBlack,
                  ),
                ),
                const SizedBox(height: kLargeSpacing),
                _buildTextField(
                  controller: _emailController,
                  labelText: 'Email',
                  icon: Icons.email,
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your email';
                    }
                    if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                      return 'Please enter a valid email address';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: kMediumSpacing),
                _buildTextField(
                  controller: _passwordController,
                  labelText: 'Password',
                  icon: Icons.lock,
                  obscureText: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your password';
                    }
                    if (value.length < 6) {
                      return 'Password must be at least 6 characters long';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: kLargeSpacing),
                _buildPrimaryButton(
                  text: _isLoading ? 'Signing In...' : 'Sign In',
                  onPressed: _isLoading ? null : _signIn,
                ),
                const SizedBox(height: kLargeSpacing),
                Text(
                  'Or sign in with',
                  style: GoogleFonts.poppins(color: kGrey),
                ),
                const SizedBox(height: kMediumSpacing),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildSocialIconButton(FontAwesomeIcons.google, () {
                      MessageModal.show(context, MessageType.info, 'Coming Soon', 'Google sign-in is not yet implemented.');
                    }),
                    const SizedBox(width: kMediumSpacing),
                    _buildSocialIconButton(FontAwesomeIcons.apple, () {
                      MessageModal.show(context, MessageType.info, 'Coming Soon', 'Apple sign-in is not yet implemented.');
                    }),
                  ],
                ),
                const SizedBox(height: kLargeSpacing),
                GestureDetector(
                  onTap: () {
                    Navigator.pushNamed(context, '/signup');
                  },
                  child: Text.rich(
                    TextSpan(
                      text: 'Don\'t have an account? ',
                      style: GoogleFonts.poppins(color: kGrey),
                      children: [
                        TextSpan(
                          text: 'Sign Up',
                          style: GoogleFonts.poppins(
                            color: kPrimaryYellow, // Use yellow for links
                            fontWeight: FontWeight.bold,
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
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String labelText,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    bool obscureText = false,
    String? Function(String?)? validator,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: kBackground, // Match background for Neumorphism
        borderRadius: kSmallBorderRadius,
        boxShadow: [
          kNeumorphicShadowDark,
          kNeumorphicShadowLight,
        ],
      ),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        obscureText: obscureText,
        style: GoogleFonts.poppins(color: kPrimaryBlack),
        decoration: InputDecoration(
          labelText: labelText,
          labelStyle: GoogleFonts.poppins(color: kGrey),
          prefixIcon: Icon(icon, color: kGrey),
          fillColor: kBackground, // Match background
          filled: true,
          enabledBorder: OutlineInputBorder(
            borderRadius: kSmallBorderRadius,
            borderSide: BorderSide.none, // No border for Neumorphism
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: kSmallBorderRadius,
            borderSide: BorderSide(color: kPrimaryYellow, width: 2), // Yellow accent on focus
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: kSmallBorderRadius,
            borderSide: const BorderSide(color: kRedError, width: 2),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: kSmallBorderRadius,
            borderSide: const BorderSide(color: kRedError, width: 2),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: kMediumSpacing, vertical: kMediumSpacing),
        ),
        validator: validator,
      ),
    );
  }

  Widget _buildPrimaryButton({
    required String text,
    required VoidCallback? onPressed,
  }) {
    return GestureDetector(
      onTapDown: (_) {
        if (onPressed != null) {
          setState(() {
            // Apply inner shadow on press down for debossed effect
            // This is a simplified visual feedback for Neumorphism
          });
        }
      },
      onTapUp: (_) {
        if (onPressed != null) {
          setState(() {
            // Revert to outer shadow on press up
          });
        }
      },
      onTapCancel: () {
        if (onPressed != null) {
          setState(() {
            // Revert to outer shadow if tap is cancelled
          });
        }
      },
      onTap: onPressed,
      child: Container(
        width: double.infinity,
        padding: kMediumPadding,
        decoration: BoxDecoration(
          color: kPrimaryBlack, // Primary button color
          borderRadius: kSmallBorderRadius,
          boxShadow: onPressed != null
              ? [
                  kNeumorphicShadowDark,
                  kNeumorphicShadowLight,
                ]
              : [], // No shadow if disabled
        ),
        child: Center(
          child: _isLoading
              ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    color: kPrimaryWhite,
                    strokeWidth: 2,
                  ),
                )
              : Text(
                  text,
                  style: GoogleFonts.poppins(
                    color: kPrimaryWhite,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
        ),
      ),
    );
  }

  Widget _buildSocialIconButton(IconData icon, VoidCallback onPressed) {
    return Container(
      decoration: BoxDecoration(
        color: kBackground, // Match background for Neumorphism
        shape: BoxShape.circle,
        boxShadow: [
          kNeumorphicShadowDark,
          kNeumorphicShadowLight,
        ],
      ),
      child: IconButton(
        onPressed: onPressed,
        icon: Icon(icon, size: 35, color: kGrey),
        padding: const EdgeInsets.all(kSmallSpacing),
      ),
    );
  }
}
