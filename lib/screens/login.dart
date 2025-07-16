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
          'Success!',
          'You have successfully logged in.',
        );
        // Navigation is now handled by the StreamBuilder in main.dart
      } else {
        // This case should ideally not be reached if an AuthException is thrown
        MessageModal.show(
          context,
          MessageType.error,
          'Login Failed',
          'An unknown error occurred. Please try again.',
        );
      }
    } on AuthException catch (e) {
      debugPrint('Supabase Sign In Error: ${e.message}');
      MessageModal.show(
        context,
        MessageType.error,
        'Login Failed',
        e.message.contains('Invalid login credentials')
            ? 'Invalid email or password. Please try again.'
            : 'An error occurred: ${e.message}',
      );
    } catch (e) {
      debugPrint('General Sign In Error: $e');
      MessageModal.show(
        context,
        MessageType.error,
        'Login Failed',
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
      backgroundColor: kPrimaryYellowGreen, // pale yellow
      appBar: AppBar(
        backgroundColor: kDarkRed,
        title: Text(
          'Login',
          style: GoogleFonts.poppins(
            color: kWhite,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pushNamed(context, '/signup');
            },
            style: TextButton.styleFrom(foregroundColor: kWhite),
            child: Text(
              'Sign Up',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: kSmallSpacing), // Use kSmallSpacing
        ],
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: kDefaultPadding, // Use kDefaultPadding
          child: Container(
            padding: const EdgeInsets.all(kLargeSpacing), // Use kLargeSpacing for inner padding
            decoration: BoxDecoration(
              color: kLightYellow, // Light yellow background
              borderRadius: kDefaultBorderRadius, // Use kDefaultBorderRadius
              boxShadow: const [kDefaultBoxShadow], // Use kDefaultBoxShadow
            ),
            constraints: const BoxConstraints(maxWidth: 400),
            child: Form( // Added Form widget for validation
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Welcome Back!',
                    style: GoogleFonts.poppins(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: kDarkRed,
                    ),
                  ),
                  Text(
                    'Login to continue',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      color: kGrey, // Use kGrey for secondary text
                    ),
                  ),
                  const SizedBox(height: kLargeSpacing), // Use kLargeSpacing
                  _buildTextField(
                    _emailController,
                    'Email',
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Email is required';
                      }
                      if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                        return 'Enter a valid email';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: kMediumSpacing), // Use kMediumSpacing
                  _buildTextField(
                    _passwordController,
                    'Password',
                    obscureText: true,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Password is required';
                      }
                      if (value.length < 6) {
                        return 'Password must be at least 6 characters';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: kSmallSpacing), // Use kSmallSpacing
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {
                        debugPrint('Forgot Password?');
                        // Implement navigation to forgot password screen
                      },
                      child: Text(
                        'Forgot Password?',
                        style: GoogleFonts.poppins(
                          color: kDarkRed,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: kMediumSpacing), // Use kMediumSpacing
                  ElevatedButton(
                    onPressed: _isLoading ? null : _signIn,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: kDarkRed, // Dark red button
                      foregroundColor: kWhite,
                      padding: const EdgeInsets.symmetric(vertical: kMediumSpacing), // Use kMediumSpacing
                      shape: RoundedRectangleBorder(
                        borderRadius: kSmallBorderRadius, // Use kSmallBorderRadius
                      ),
                      minimumSize: const Size(double.infinity, 50),
                      elevation: 5, // Add a slight elevation for depth
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(color: kWhite, strokeWidth: 2),
                          )
                        : Text(
                            'Login',
                            style: GoogleFonts.poppins(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                  const SizedBox(height: kLargeSpacing), // Use kLargeSpacing
                  Text(
                    'Or login with',
                    style: GoogleFonts.poppins(color: kGrey), // Use kGrey
                  ),
                  const SizedBox(height: kMediumSpacing), // Use kMediumSpacing
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildSocialIconButton(FontAwesomeIcons.google, () { debugPrint('Google login'); }),
                      const SizedBox(width: kMediumSpacing), // Use kMediumSpacing
                      _buildSocialIconButton(FontAwesomeIcons.facebook, () { debugPrint('Facebook login'); }),
                      const SizedBox(width: kMediumSpacing), // Use kMediumSpacing
                      _buildSocialIconButton(FontAwesomeIcons.twitter, () { debugPrint('Twitter login'); }),
                    ],
                  ),
                  const SizedBox(height: kLargeSpacing), // Use kLargeSpacing
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String hintText, {
    bool obscureText = false,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator, // Added validator
  }) {
    return TextFormField( // Changed to TextFormField for validation
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      style: GoogleFonts.poppins(color: kBlack),
      decoration: InputDecoration(
        hintText: hintText,
        filled: true,
        fillColor: kWhite,
        border: OutlineInputBorder(
          borderRadius: kSmallBorderRadius, // Use kSmallBorderRadius
          borderSide: const BorderSide(color: Color(0xFFCCCCCC)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: kSmallBorderRadius, // Use kSmallBorderRadius
          borderSide: const BorderSide(color: Color(0xFFCCCCCC)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: kSmallBorderRadius, // Use kSmallBorderRadius
          borderSide: const BorderSide(color: kDarkRed, width: 2), // Thicker border on focus
        ),
        errorBorder: OutlineInputBorder( // Error border style
          borderRadius: kSmallBorderRadius,
          borderSide: const BorderSide(color: kRedError, width: 2),
        ),
        focusedErrorBorder: OutlineInputBorder( // Focused error border style
          borderRadius: kSmallBorderRadius,
          borderSide: const BorderSide(color: kRedError, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: kMediumSpacing, vertical: kMediumSpacing), // Consistent padding
      ),
      validator: validator, // Assign the validator
    );
  }

  Widget _buildSocialIconButton(IconData icon, VoidCallback onPressed) {
    return Container(
      decoration: BoxDecoration(
        color: kWhite,
        shape: BoxShape.circle,
        boxShadow: const [kButtonBoxShadow], // Use kButtonBoxShadow
      ),
      child: IconButton(
        onPressed: onPressed,
        icon: Icon(icon, size: 35, color: kGrey), // Use kGrey for social icons
        padding: const EdgeInsets.all(kSmallSpacing), // Consistent padding
      ),
    );
  }
}
