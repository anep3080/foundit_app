import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../ui_constants.dart'; // Import your constants file
import '../services/supabase_service.dart'; // Import SupabaseService
import '../widgets/message_modal.dart'; // Import MessageModal

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _countryController = TextEditingController();
  final TextEditingController _telegramUsernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  String _gender = 'Male'; // Default gender
  bool _isLoading = false;
  final _formKey = GlobalKey<FormState>(); // Added for form validation

  Future<void> _signUp() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_passwordController.text != _confirmPasswordController.text) {
      MessageModal.show(
        context,
        MessageType.error,
        'Signup Failed',
        'Passwords do not match.',
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final AuthResponse response = await supabaseService.signUp(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
        fullName: _fullNameController.text.trim(),
        phoneNumber: _phoneNumberController.text.trim(),
        city: _cityController.text.trim(),
        country: _countryController.text.trim(),
        telegramUsername: _telegramUsernameController.text.trim(),
        gender: _gender,
      );

      if (response.user != null) {
        MessageModal.show(
          context,
          MessageType.success,
          'Success',
          'Account created successfully! Please check your email for verification.',
        );
        // Navigate to login screen after successful signup
        Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
      }
    } on AuthException catch (e) {
      MessageModal.show(
        context,
        MessageType.error,
        'Signup Failed',
        e.message,
      );
    } catch (e) {
      MessageModal.show(
        context,
        MessageType.error,
        'Signup Error',
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
    _fullNameController.dispose();
    _emailController.dispose();
    _phoneNumberController.dispose();
    _cityController.dispose();
    _countryController.dispose();
    _telegramUsernameController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
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
          'Sign Up',
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
                  'Create Your Account',
                  style: GoogleFonts.poppins(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: kPrimaryBlack,
                  ),
                ),
                const SizedBox(height: kLargeSpacing),
                _buildTextField(
                  controller: _fullNameController,
                  labelText: 'Full Name',
                  icon: Icons.person,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your full name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: kMediumSpacing),
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
                  controller: _phoneNumberController,
                  labelText: 'Phone Number',
                  icon: Icons.phone,
                  keyboardType: TextInputType.phone,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your phone number';
                    }
                    if (!RegExp(r'^\+?[0-9]{10,}$').hasMatch(value)) {
                      return 'Please enter a valid phone number';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: kMediumSpacing),
                _buildTextField(
                  controller: _cityController,
                  labelText: 'City',
                  icon: Icons.location_city,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your city';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: kMediumSpacing),
                _buildTextField(
                  controller: _countryController,
                  labelText: 'Country',
                  icon: Icons.public,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your country';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: kMediumSpacing),
                _buildTextField(
                  controller: _telegramUsernameController,
                  labelText: 'Telegram Username (Optional)',
                  icon: FontAwesomeIcons.telegram,
                ),
                const SizedBox(height: kMediumSpacing),
                _buildGenderSelection(),
                const SizedBox(height: kMediumSpacing),
                _buildTextField(
                  controller: _passwordController,
                  labelText: 'Password',
                  icon: Icons.lock,
                  obscureText: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a password';
                    }
                    if (value.length < 6) {
                      return 'Password must be at least 6 characters long';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: kMediumSpacing),
                _buildTextField(
                  controller: _confirmPasswordController,
                  labelText: 'Confirm Password',
                  icon: Icons.lock_reset,
                  obscureText: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please confirm your password';
                    }
                    if (value != _passwordController.text) {
                      return 'Passwords do not match';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: kLargeSpacing),
                _buildPrimaryButton(
                  text: _isLoading ? 'Signing Up...' : 'Sign Up',
                  onPressed: _isLoading ? null : _signUp,
                ),
                const SizedBox(height: kLargeSpacing),
                GestureDetector(
                  onTap: () {
                    Navigator.pop(context); // Go back to login screen
                  },
                  child: Text.rich(
                    TextSpan(
                      text: 'Already have an account? ',
                      style: GoogleFonts.poppins(color: kGrey),
                      children: [
                        TextSpan(
                          text: 'Login',
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

  Widget _buildGenderSelection() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: kSmallSpacing),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Gender',
            style: GoogleFonts.poppins(fontWeight: FontWeight.w600, color: kPrimaryBlack),
          ),
          Row(
            children: [
              Radio<String>(
                value: 'Male',
                groupValue: _gender,
                onChanged: (String? value) {
                  setState(() {
                    _gender = value!;
                  });
                },
                activeColor: kPrimaryYellow, // Use yellow for radio active color
              ),
              Text('Male', style: GoogleFonts.poppins(color: kPrimaryBlack)),
              const SizedBox(width: kMediumSpacing),
              Radio<String>(
                value: 'Female',
                groupValue: _gender,
                onChanged: (String? value) {
                  setState(() {
                    _gender = value!;
                  });
                },
                activeColor: kPrimaryYellow,
              ),
              Text('Female', style: GoogleFonts.poppins(color: kPrimaryBlack)),
              const SizedBox(width: kMediumSpacing),
            ],
          ),
        ],
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
}
