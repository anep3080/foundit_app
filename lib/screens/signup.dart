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
        'Password Mismatch',
        'The passwords do not match. Please try again.',
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
        userType: 'user', // All sign-ups are 'user' by default
      );

      if (response.user != null) {
        MessageModal.show(
          context,
          MessageType.success,
          'Success!',
          'Account created successfully. Please check your email to verify your account if email confirmation is enabled.',
        );
        // Navigate to login after successful signup
        Navigator.pushReplacementNamed(context, '/login');
      } else {
        MessageModal.show(
          context,
          MessageType.error,
          'Signup Failed',
          'An unknown error occurred. Please try again.',
        );
      }
    } on AuthException catch (e) {
      debugPrint('Supabase Sign Up Error: ${e.message}');
      MessageModal.show(
        context,
        MessageType.error,
        'Signup Failed',
        e.message.contains('User already registered')
            ? 'This email is already registered. Please login or use a different email.'
            : 'An error occurred: ${e.message}',
      );
    } catch (e) {
      debugPrint('General Sign Up Error: $e');
      MessageModal.show(
        context,
        MessageType.error,
        'Signup Failed',
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
      backgroundColor: kPrimaryYellowGreen,
      appBar: AppBar(
        backgroundColor: kDarkRed,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: kWhite),
          onPressed: () {
            Navigator.pop(context); // Go back to the previous screen (Login)
          },
        ),
        title: Text(
          'Create Account',
          style: GoogleFonts.poppins(
            color: kWhite,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _signUp,
            style: TextButton.styleFrom(foregroundColor: kWhite),
            child: _isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      color: kWhite,
                      strokeWidth: 2,
                    ),
                  )
                : Text(
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
            padding: const EdgeInsets.all(20.0), // Fixed: Use direct value instead of kDefaultPadding.left
            decoration: BoxDecoration(
              color: kLightYellow,
              borderRadius: kDefaultBorderRadius, // Use kDefaultBorderRadius
              boxShadow: const [kDefaultBoxShadow], // Use kDefaultBoxShadow
            ),
            constraints: const BoxConstraints(maxWidth: 1000),
            child: Form( // Added Form widget for validation
              key: _formKey,
              child: Row(
                children: [
                  // Left Panel (Visual branding)
                  Expanded(
                    flex: 1,
                    child: Container(
                      decoration: BoxDecoration(
                        color: kPrimaryYellowGreen,
                        borderRadius: kSmallBorderRadius, // Use kSmallBorderRadius
                      ),
                      padding: const EdgeInsets.all(20.0), // Fixed: Use direct value instead of kDefaultPadding.left
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _buildVerticalText('S'),
                          _buildVerticalText('I'),
                          _buildVerticalText('G'),
                          _buildVerticalText('N'),
                          const SizedBox(height: kLargeSpacing), // Use kLargeSpacing
                          _buildVerticalText('U'),
                          _buildVerticalText('P'),
                        ],
                      ),
                    ),
                  ),
                  // Right Panel (Form)
                  Expanded(
                    flex: 2,
                    child: Padding(
                      padding: const EdgeInsets.all(20.0), // Fixed: Use direct value instead of kDefaultPadding.left
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Create Your Account',
                            style: GoogleFonts.poppins(
                              fontSize: 30,
                              fontWeight: FontWeight.bold,
                              color: kDarkRed,
                            ),
                          ),
                          const SizedBox(height: kLargeSpacing), // Use kLargeSpacing
                          _buildTextField(
                            _fullNameController,
                            'Full Name',
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Full Name is required';
                              }
                              return null;
                            },
                          ),
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
                          _buildTextField(
                            _phoneNumberController,
                            'Phone Number',
                            keyboardType: TextInputType.phone,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Phone Number is required';
                              }
                              // Basic phone number validation (can be more robust)
                              if (!RegExp(r'^[0-9]+$').hasMatch(value)) {
                                return 'Enter a valid phone number';
                              }
                              return null;
                            },
                          ),
                          _buildFormRow([
                            _buildTextField(_cityController, 'City'),
                            _buildTextField(_countryController, 'Country'),
                          ]),
                          _buildTextField(_telegramUsernameController, 'Telegram Username'),
                          _buildGenderRadioButtons(),
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
                          _buildTextField(
                            _confirmPasswordController,
                            'Confirm Password',
                            obscureText: true,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Confirm Password is required';
                              }
                              if (value != _passwordController.text) {
                                return 'Passwords do not match';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: kLargeSpacing), // Use kLargeSpacing
                          // The submit button is now in the AppBar
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
    );
  }

  Widget _buildVerticalText(String text) {
    return RotatedBox(
      quarterTurns: -1,
      child: Text(
        text,
        style: GoogleFonts.poppins(
          fontSize: 48,
          fontWeight: FontWeight.bold,
          color: kDarkRed,
          letterSpacing: 8,
        ),
      ),
    );
  }

  Widget _buildFormRow(List<Widget> children) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: children.map((child) => Expanded(child: Padding(
        padding: const EdgeInsets.only(right: kMediumSpacing), // Use kMediumSpacing for gap
        child: child,
      ))).toList(),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String hintText, {
    bool obscureText = false,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator, // Added validator
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: kSmallSpacing), // Use kSmallSpacing
      child: TextFormField( // Changed to TextFormField for validation
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
      ),
    );
  }

  Widget _buildGenderRadioButtons() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: kSmallSpacing), // Use kSmallSpacing
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Gender',
            style: GoogleFonts.poppins(fontWeight: FontWeight.w600, color: const Color(0xFF333333)),
          ),
          const SizedBox(height: kSmallSpacing), // Use kSmallSpacing
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
                activeColor: kDarkRed,
              ),
              Text('Male', style: GoogleFonts.poppins()),
              const SizedBox(width: kMediumSpacing), // Use kMediumSpacing
              Radio<String>(
                value: 'Female',
                groupValue: _gender,
                onChanged: (String? value) {
                  setState(() {
                    _gender = value!;
                  });
                },
                activeColor: kDarkRed,
              ),
              Text('Female', style: GoogleFonts.poppins()),
              const SizedBox(width: kMediumSpacing), // Use kMediumSpacing
              Radio<String>(
                value: 'Other',
                groupValue: _gender,
                onChanged: (String? value) {
                  setState(() {
                    _gender = value!;
                  });
                },
                activeColor: kDarkRed,
              ),
              Text('Other', style: GoogleFonts.poppins()),
            ],
          ),
        ],
      ),
    );
  }
}
