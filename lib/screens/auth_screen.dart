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
  String _signupGender = 'Male'; // Default for signup

  final _loginFormKey = GlobalKey<FormState>();
  final _signupFormKey = GlobalKey<FormState>();

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

  Future<void> _handleLogin() async {
    if (!_loginFormKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await supabaseService.signIn(
        email: _loginEmailController.text.trim(),
        password: _loginPasswordController.text.trim(),
      );
      // On successful login, explicitly navigate to HomepageScreen and remove all previous routes
      if (mounted) { // Check if the widget is still in the tree
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const HomepageScreen()),
          (Route<dynamic> route) => false, // This predicate removes all routes below the new one
        );
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
        'Login Failed',
        'An unexpected error occurred: ${e.toString()}',
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _handleSignUp() async {
    if (!_signupFormKey.currentState!.validate()) {
      return;
    }

    if (_signupPasswordController.text != _signupConfirmPasswordController.text) {
      MessageModal.show(
        context,
        MessageType.error,
        'Password Mismatch',
        'Password and Confirm Password do not match.',
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await supabaseService.signUp(
        email: _signupEmailController.text.trim(),
        password: _signupPasswordController.text.trim(),
        fullName: _signupFullNameController.text.trim(),
        phoneNumber: _signupPhoneNumberController.text.trim(),
        city: _signupCityController.text.trim(),
        country: _signupCountryController.text.trim(),
        telegramUsername: _signupTelegramUsernameController.text.trim(),
        gender: _signupGender,
        userType: 'user', // Default to 'user' for new signups
      );
      MessageModal.show(
        context,
        MessageType.success,
        'Sign Up Successful!',
        'Your account has been created. You can now log in.',
      );
      // After successful signup, switch to login form and clear previous routes
      if (mounted) { // Check if the widget is still in the tree
        setState(() {
          _isLogin = true; // Switch to login form after successful signup
        });
        _loginEmailController.text = _signupEmailController.text; // Pre-fill login email
        // You might want to also clear the signup controllers here
        _signupFullNameController.clear();
        _signupEmailController.clear();
        _signupPasswordController.clear();
        _signupConfirmPasswordController.clear();
        _signupPhoneNumberController.clear();
        _signupCityController.clear();
        _signupCountryController.clear();
        _signupTelegramUsernameController.clear();
        _signupGender = 'Male';
      }
    } on AuthException catch (e) {
      MessageModal.show(
        context,
        MessageType.error,
        'Sign Up Failed',
        e.message,
      );
    } catch (e) {
      MessageModal.show(
        context,
        MessageType.error,
        'Sign Up Failed',
        'An unexpected error occurred: ${e.toString()}',
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kPrimaryYellowGreen,
      body: Center(
        child: SingleChildScrollView(
          padding: kDefaultPadding,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'FoundIt',
                style: GoogleFonts.poppins(
                  fontSize: kDisplayLarge.fontSize,
                  fontWeight: kDisplayLarge.fontWeight,
                  color: kDarkRed,
                ),
              ),
              const SizedBox(height: kExtraLargeSpacing),
              Container(
                padding: kDefaultPadding,
                decoration: BoxDecoration(
                  color: kLightYellow,
                  borderRadius: kDefaultBorderRadius,
                  boxShadow: const [kDefaultBoxShadow],
                ),
                child: AnimatedSwitcher(
                  duration: kMediumAnimationDuration, // Smooth transition
                  child: _isLogin ? _buildLoginForm() : _buildSignUpForm(),
                ),
              ),
              const SizedBox(height: kMediumSpacing),
              TextButton(
                onPressed: _isLoading
                    ? null
                    : () {
                        setState(() {
                          _isLogin = !_isLogin;
                          // Clear controllers when switching forms
                          _loginEmailController.clear();
                          _loginPasswordController.clear();
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
                      },
                child: Text(
                  _isLogin
                      ? 'Don\'t have an account? Sign Up'
                      : 'Already have an account? Log In',
                  style: GoogleFonts.poppins(
                    color: kDarkRed,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLoginForm() {
    return Form(
      key: _loginFormKey,
      child: Column(
        key: const ValueKey<bool>(true), // Unique key for AnimatedSwitcher
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Log In',
            style: GoogleFonts.poppins(
              fontSize: kTitleLarge.fontSize,
              fontWeight: kTitleLarge.fontWeight,
              color: kTitleLarge.color,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: kLargeSpacing),
          _buildTextField(
            _loginEmailController,
            'Email',
            Icons.email,
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
          const SizedBox(height: kMediumSpacing),
          _buildTextField(
            _loginPasswordController,
            'Password',
            Icons.lock,
            obscureText: true,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Password is required';
              }
              return null;
            },
          ),
          const SizedBox(height: kLargeSpacing),
          ElevatedButton(
            onPressed: _isLoading ? null : _handleLogin,
            child: _isLoading
                ? const CircularProgressIndicator(color: kWhite, strokeWidth: 2)
                : Text('Log In', style: kLabelLarge),
          ),
        ],
      ),
    );
  }

  Widget _buildSignUpForm() {
    return Form(
      key: _signupFormKey,
      child: Column(
        key: const ValueKey<bool>(false), // Unique key for AnimatedSwitcher
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Sign Up',
            style: GoogleFonts.poppins(
              fontSize: kTitleLarge.fontSize,
              fontWeight: kTitleLarge.fontWeight,
              color: kTitleLarge.color,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: kLargeSpacing),
          _buildTextField(
            _signupFullNameController,
            'Full Name',
            Icons.person,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Full Name is required';
              }
              return null;
            },
          ),
          const SizedBox(height: kMediumSpacing),
          _buildTextField(
            _signupEmailController,
            'Email',
            Icons.email,
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
          const SizedBox(height: kMediumSpacing),
          _buildTextField(
            _signupPasswordController,
            'Password',
            Icons.lock,
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
          const SizedBox(height: kMediumSpacing),
          _buildTextField(
            _signupConfirmPasswordController,
            'Confirm Password',
            Icons.lock_reset,
            obscureText: true,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Confirm Password is required';
              }
              if (value != _signupPasswordController.text) {
                return 'Passwords do not match';
              }
              return null;
            },
          ),
          const SizedBox(height: kMediumSpacing),
          _buildTextField(
            _signupPhoneNumberController,
            'Phone Number',
            Icons.phone,
            keyboardType: TextInputType.phone,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Phone Number is required';
              }
              if (!RegExp(r'^[0-9]+$').hasMatch(value)) {
                return 'Enter a valid phone number';
              }
              return null;
            },
          ),
          const SizedBox(height: kMediumSpacing),
          _buildTextField(
            _signupCityController,
            'City',
            Icons.location_city,
          ),
          const SizedBox(height: kMediumSpacing),
          _buildTextField(
            _signupCountryController,
            'Country',
            Icons.public,
          ),
          const SizedBox(height: kMediumSpacing),
          _buildTextField(
            _signupTelegramUsernameController,
            'Telegram Username',
            Icons.alternate_email,
          ),
          const SizedBox(height: kMediumSpacing),
          _buildGenderRadioButtons(),
          const SizedBox(height: kLargeSpacing),
          ElevatedButton(
            onPressed: _isLoading ? null : _handleSignUp,
            child: _isLoading
                ? const CircularProgressIndicator(color: kWhite, strokeWidth: 2)
                : Text('Sign Up', style: kLabelLarge),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String hintText,
    IconData icon, {
    bool obscureText = false,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      style: GoogleFonts.poppins(color: kBlack, fontSize: kBodyMedium.fontSize),
      decoration: InputDecoration(
        hintText: hintText,
        prefixIcon: Icon(icon, color: kGrey),
      ),
      validator: validator,
    );
  }

  Widget _buildGenderRadioButtons() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Gender',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600, color: const Color(0xFF333333)),
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
              activeColor: kDarkRed,
            ),
            Text('Male', style: GoogleFonts.poppins(color: kBlack)),
            const SizedBox(width: kMediumSpacing),
            Radio<String>(
              value: 'Female',
              groupValue: _signupGender,
              onChanged: (String? value) {
                setState(() {
                  _signupGender = value!;
                });
              },
              activeColor: kDarkRed,
            ),
            Text('Female', style: GoogleFonts.poppins(color: kBlack)),
            const SizedBox(width: kMediumSpacing),
            Radio<String>(
              value: 'Other',
              groupValue: _signupGender,
              onChanged: (String? value) {
                setState(() {
                  _signupGender = value!;
                });
              },
              activeColor: kDarkRed,
            ),
            Text('Other', style: GoogleFonts.poppins(color: kBlack)),
          ],
        ),
      ],
    );
  }
}
