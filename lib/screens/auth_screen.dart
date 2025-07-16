import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/supabase_service.dart';
import '../ui_constants.dart';
import '../widgets/message_modal.dart'; // For showing success/error messages
import 'homepage_screen.dart'; // Import HomepageScreen for navigation

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  bool _isLogin = true; // True for login, false for signup
  bool _isLoading = false;

  // Login Controllers
  final TextEditingController _loginEmailController = TextEditingController();
  final TextEditingController _loginPasswordController = TextEditingController();

  // Signup Controllers
  final TextEditingController _signupFullNameController = TextEditingController();
  final TextEditingController _signupEmailController = TextEditingController();
  final TextEditingController _signupPasswordController = TextEditingController();
  final TextEditingController _signupConfirmPasswordController = TextEditingController();
  final TextEditingController _signupPhoneNumberController = TextEditingController();
  final TextEditingController _signupCityController = TextEditingController();
  final TextEditingController _signupCountryController = TextEditingController();
  final TextEditingController _signupTelegramUsernameController = TextEditingController();

  String _signupGender = 'Male'; // Default gender for signup
  final _loginFormKey = GlobalKey<FormState>(); // Added for login form validation
  final _signupFormKey = GlobalKey<FormState>(); // Added for signup form validation

  @override
  void dispose() {
    _loginEmailController.dispose();
    _loginPasswordController.dispose();
    _signupFullNameController.dispose();
    _signupEmailController.dispose();
    _signupPasswordController.dispose();
    _signupConfirmPasswordController.dispose();
    _signupPhoneNumberController.dispose();
    _signupCityController.dispose();
    _signupCountryController.dispose();
    _signupTelegramUsernameController.dispose();
    super.dispose();
  }

  Future<void> _signIn() async {
    if (!_loginFormKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final AuthResponse response = await supabaseService.signIn(
        email: _loginEmailController.text.trim(),
        password: _loginPasswordController.text.trim(),
      );

      if (response.user != null) {
        MessageModal.show(
          context,
          MessageType.success,
          'Success',
          'You have successfully logged in!',
        );
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

  Future<void> _signUp() async {
    if (!_signupFormKey.currentState!.validate()) {
      return;
    }

    if (_signupPasswordController.text != _signupConfirmPasswordController.text) {
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
        email: _signupEmailController.text.trim(),
        password: _signupPasswordController.text.trim(),
        fullName: _signupFullNameController.text.trim(),
        phoneNumber: _signupPhoneNumberController.text.trim(),
        city: _signupCityController.text.trim(),
        country: _signupCountryController.text.trim(),
        telegramUsername: _signupTelegramUsernameController.text.trim(),
        gender: _signupGender,
      );

      if (response.user != null) {
        MessageModal.show(
          context,
          MessageType.success,
          'Success',
          'Account created successfully! Please check your email for verification.',
        );
        setState(() {
          _isLogin = true; // Switch to login view after successful signup
          _signupFullNameController.clear();
          _signupEmailController.clear();
          _signupPasswordController.clear();
          _signupConfirmPasswordController.clear();
          _signupPhoneNumberController.clear();
          _signupCityController.clear();
          _signupCountryController.clear();
          _signupTelegramUsernameController.clear();
          _signupGender = 'Male';
        });
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
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackground, // Use the new background color
      body: Center(
        child: SingleChildScrollView(
          padding: kDefaultPadding,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'FoundIt',
                style: GoogleFonts.poppins(
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                  color: kPrimaryBlack,
                ),
              ),
              const SizedBox(height: kExtraLargeSpacing),
              _buildToggleButtons(),
              const SizedBox(height: kLargeSpacing),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 300), // Use a fixed duration
                transitionBuilder: (Widget child, Animation<double> animation) {
                  return FadeTransition(opacity: animation, child: child);
                },
                child: _isLogin
                    ? _buildLoginSection(key: const ValueKey('login'))
                    : _buildSignupSection(key: const ValueKey('signup')),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildToggleButtons() {
    return Container(
      decoration: BoxDecoration(
        color: kBackground,
        borderRadius: kCircularBorderRadius,
        boxShadow: [
          kNeumorphicShadowDark,
          kNeumorphicShadowLight,
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildToggleButton('Login', true),
          _buildToggleButton('Sign Up', false),
        ],
      ),
    );
  }

  Widget _buildToggleButton(String text, bool isLoginButton) {
    final bool isSelected = _isLogin == isLoginButton;
    return GestureDetector(
      onTap: () {
        setState(() {
          _isLogin = isLoginButton;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: kLargeSpacing, vertical: kMediumSpacing),
        decoration: BoxDecoration(
          color: isSelected ? kPrimaryYellow : kBackground, // Yellow for selected, background for unselected
          borderRadius: kCircularBorderRadius,
          boxShadow: isSelected
              ? [
                  kNeumorphicInnerShadowDark, // Inner shadow for pressed effect
                  kNeumorphicInnerShadowLight,
                ]
              : [],
        ),
        child: Text(
          text,
          style: GoogleFonts.poppins(
            color: isSelected ? kPrimaryWhite : kPrimaryBlack, // White text on yellow, black otherwise
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ),
    );
  }

  Widget _buildLoginSection({Key? key}) {
    return Form(
      key: _loginFormKey,
      child: Column(
        key: key,
        children: [
          _buildTextField(
            controller: _loginEmailController,
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
            controller: _loginPasswordController,
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
            text: _isLoading ? 'Logging In...' : 'Login',
            onPressed: _isLoading ? null : _signIn,
          ),
        ],
      ),
    );
  }

  Widget _buildSignupSection({Key? key}) {
    return Form(
      key: _signupFormKey,
      child: Column(
        key: key,
        children: [
          _buildTextField(
            controller: _signupFullNameController,
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
            controller: _signupEmailController,
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
            controller: _signupPhoneNumberController,
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
            controller: _signupCityController,
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
            controller: _signupCountryController,
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
            controller: _signupTelegramUsernameController,
            labelText: 'Telegram Username (Optional)',
            icon: Icons.telegram, // Using Material icon for now, FontAwesomeIcons.telegram is also an option
          ),
          const SizedBox(height: kMediumSpacing),
          _buildGenderSelection(),
          const SizedBox(height: kMediumSpacing),
          _buildTextField(
            controller: _signupPasswordController,
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
            controller: _signupConfirmPasswordController,
            labelText: 'Confirm Password',
            icon: Icons.lock_reset,
            obscureText: true,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please confirm your password';
              }
              if (value != _signupPasswordController.text) {
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
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String labelText,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    bool obscureText = false,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: kBackground,
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
        maxLines: maxLines,
        style: GoogleFonts.poppins(color: kPrimaryBlack),
        decoration: InputDecoration(
          labelText: labelText,
          labelStyle: GoogleFonts.poppins(color: kGrey),
          prefixIcon: Icon(icon, color: kGrey),
          fillColor: kBackground,
          filled: true,
          enabledBorder: OutlineInputBorder(
            borderRadius: kSmallBorderRadius,
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: kSmallBorderRadius,
            borderSide: BorderSide(color: kPrimaryYellow, width: 2),
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
                groupValue: _signupGender,
                onChanged: (String? value) {
                  setState(() {
                    _signupGender = value!;
                  });
                },
                activeColor: kPrimaryYellow,
              ),
              Text('Male', style: GoogleFonts.poppins(color: kPrimaryBlack)),
              const SizedBox(width: kMediumSpacing),
              Radio<String>(
                value: 'Female',
                groupValue: _signupGender,
                onChanged: (String? value) {
                  setState(() {
                    _signupGender = value!;
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
