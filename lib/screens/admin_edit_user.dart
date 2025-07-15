import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart'; // Import Supabase types
import '../ui_constants.dart'; // Import your constants file
import '../services/supabase_service.dart'; // Import SupabaseService
import '../widgets/message_modal.dart'; // Import MessageModal

class AdminEditUserScreen extends StatefulWidget {
  final String userId; // User ID is passed for editing

  const AdminEditUserScreen({super.key, required this.userId});

  @override
  State<AdminEditUserScreen> createState() => _AdminEditUserScreenState();
}

class _AdminEditUserScreenState extends State<AdminEditUserScreen> {
  // Controllers for editing
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _countryController = TextEditingController();
  final TextEditingController _telegramUsernameController =
      TextEditingController();
  final TextEditingController _newPasswordController =
      TextEditingController(); // For admin-initiated password reset
  final TextEditingController _confirmNewPasswordController =
      TextEditingController();

  String _gender = 'Male';
  String _userType = 'user'; // 'user' or 'admin'
  bool _isLoading = true; // To manage loading state for fetching/updating user
  final _formKey = GlobalKey<FormState>(); // For form validation

  @override
  void initState() {
    super.initState();
    _fetchUserDetails();
  }

  Future<void> _fetchUserDetails() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final Map<String, dynamic> userData = await supabaseService.client
          .from('profiles')
          .select()
          .eq('id', widget.userId)
          .single();

      _fullNameController.text = userData['full_name'] ?? '';
      _emailController.text = userData['email'] ?? '';
      _phoneNumberController.text = userData['phone_number'] ?? '';
      _cityController.text = userData['city'] ?? '';
      _countryController.text = userData['country'] ?? '';
      _telegramUsernameController.text = userData['telegram_username'] ?? '';
      _gender = userData['gender'] ?? 'Male';
      _userType = userData['user_type'] ?? 'user';
    } catch (e) {
      debugPrint('Error fetching user details for admin edit: $e');
      MessageModal.show(
        context,
        MessageType.error,
        'Error',
        'Failed to load user details: $e',
      );
      Navigator.pop(context); // Go back if user cannot be loaded
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _updateUser() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Update password if new password fields are filled
      if (_newPasswordController.text.isNotEmpty) {
        if (_newPasswordController.text != _confirmNewPasswordController.text) {
          MessageModal.show(
            context,
            MessageType.error,
            'Password Mismatch',
            'New password and confirm new password do not match.',
          );
          setState(() {
            _isLoading = false;
          });
          return;
        }
        // Admin initiating password update for another user.
        // Supabase's client.auth.updateUser only updates the *current* user.
        // For admin-initiated password resets, you would typically use a Supabase Function
        // or a server-side API that calls the Admin API.
        // For this example, we'll simulate it by showing a success message,
        // but a direct client-side update of another user's password is not possible.
        // If you need this, you'll need to implement a Supabase Function.
        MessageModal.show(
          context,
          MessageType.success,
          'Password Reset Initiated',
          'Password reset for this user would be handled via an admin API or function (not directly supported client-side).',
        );
        _newPasswordController.clear();
        _confirmNewPasswordController.clear();
      }

      // Prepare data for profile update
      final Map<String, dynamic> updates = {
        'full_name': _fullNameController.text.trim(),
        'phone_number': _phoneNumberController.text.trim(),
        'city': _cityController.text.trim(),
        'country': _countryController.text.trim(),
        'telegram_username': _telegramUsernameController.text.trim(),
        'gender': _gender,
        'user_type': _userType,
      };

      // Update profile in Supabase
      await supabaseService.client
          .from('profiles')
          .update(updates)
          .eq('id', widget.userId);

      MessageModal.show(
        context,
        MessageType.success,
        'Success!',
        'User profile updated successfully.',
      );
      Navigator.pop(context); // Go back to admin homepage after update
    } catch (e) {
      debugPrint('Error updating user profile (admin): $e');
      MessageModal.show(
        context,
        MessageType.error,
        'Error',
        'Failed to update user profile: $e',
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
    _newPasswordController.dispose();
    _confirmNewPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kPrimaryYellowGreen,
      appBar: AppBar(
        backgroundColor: kDarkRed,
        title: Text(
          'Edit User',
          style: GoogleFonts.poppins(
            color: kWhite,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: kWhite),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        actions: [
          IconButton(
            icon: _isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      color: kWhite,
                      strokeWidth: 2,
                    ),
                  )
                : const Icon(Icons.check, color: kWhite),
            onPressed: _isLoading ? null : _updateUser,
          ),
          const SizedBox(width: kSmallSpacing), // Consistent spacing
        ],
      ),
      body:
          _isLoading &&
              _fullNameController
                  .text
                  .isEmpty // Show loading only when initially fetching
          ? const Center(child: CircularProgressIndicator(color: kDarkRed))
          : SingleChildScrollView(
              padding: kDefaultPadding, // Use kDefaultPadding
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'User Details',
                      style: GoogleFonts.poppins(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: kDarkRed,
                      ),
                    ),
                    const SizedBox(height: kLargeSpacing), // Consistent spacing
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
                      editable: false,
                    ), // Email usually not editable
                    _buildTextField(
                      _phoneNumberController,
                      'Phone Number',
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
                    _buildFormRow([
                      _buildTextField(_cityController, 'City'),
                      _buildTextField(_countryController, 'Country'),
                    ]),
                    _buildTextField(
                      _telegramUsernameController,
                      'Telegram Username',
                    ),
                    _buildGenderRadioButtons(),
                    _buildUserTypeRadioButtons(),
                    const SizedBox(height: kLargeSpacing), // Consistent spacing
                    Text(
                      'Reset Password (Admin Only)',
                      style: GoogleFonts.poppins(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: kDarkRed,
                      ),
                    ),
                    const SizedBox(
                      height: kMediumSpacing,
                    ), // Consistent spacing
                    _buildTextField(
                      _newPasswordController,
                      'New Password',
                      obscureText: true,
                      validator: (value) {
                        if (_newPasswordController.text.isNotEmpty &&
                            (value == null || value.length < 6)) {
                          return 'Password must be at least 6 characters';
                        }
                        return null;
                      },
                    ),
                    _buildTextField(
                      _confirmNewPasswordController,
                      'Confirm New Password',
                      obscureText: true,
                      validator: (value) {
                        if (_newPasswordController.text.isNotEmpty &&
                            value != _newPasswordController.text) {
                          return 'Passwords do not match';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: kLargeSpacing), // Consistent spacing
                    // The save button is now in the AppBar
                  ],
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
    bool editable = true,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: kSmallSpacing,
      ), // Consistent spacing
      child: TextFormField(
        controller: controller,
        obscureText: obscureText,
        keyboardType: keyboardType,
        readOnly: !editable, // Make read-only if not editable
        style: GoogleFonts.poppins(color: editable ? kBlack : kGrey),
        decoration: InputDecoration(
          hintText: hintText,
          filled: true,
          fillColor: editable ? kWhite : kLightGrey,
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
            borderSide: const BorderSide(
              color: kDarkRed,
              width: 2,
            ), // Thicker border on focus
          ),
          errorBorder: OutlineInputBorder(
            // Error border style
            borderRadius: kSmallBorderRadius,
            borderSide: const BorderSide(color: kRedError, width: 2),
          ),
          focusedErrorBorder: OutlineInputBorder(
            // Focused error border style
            borderRadius: kSmallBorderRadius,
            borderSide: const BorderSide(color: kRedError, width: 2),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: kMediumSpacing,
            vertical: kMediumSpacing,
          ), // Consistent padding
        ),
        validator: validator,
      ),
    );
  }

  Widget _buildGenderRadioButtons() {
    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: kSmallSpacing,
      ), // Consistent spacing
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Gender',
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w600,
              color: const Color(0xFF333333),
            ),
          ),
          const SizedBox(height: kSmallSpacing), // Consistent spacing
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
              const SizedBox(width: kMediumSpacing), // Consistent spacing
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
              const SizedBox(width: kMediumSpacing), // Consistent spacing
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

  Widget _buildUserTypeRadioButtons() {
    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: kSmallSpacing,
      ), // Consistent spacing
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'User Type',
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w600,
              color: const Color(0xFF333333),
            ),
          ),
          const SizedBox(height: kSmallSpacing), // Consistent spacing
          Row(
            children: [
              Radio<String>(
                value: 'user',
                groupValue: _userType,
                onChanged: (String? value) {
                  setState(() {
                    _userType = value!;
                  });
                },
                activeColor: kDarkRed,
              ),
              Text('User', style: GoogleFonts.poppins()),
              const SizedBox(width: kMediumSpacing), // Consistent spacing
              Radio<String>(
                value: 'admin',
                groupValue: _userType,
                onChanged: (String? value) {
                  setState(() {
                    _userType = value!;
                  });
                },
                activeColor: kDarkRed,
              ),
              Text('Admin', style: GoogleFonts.poppins()),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFormRow(List<Widget> children) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: children
          .map(
            (child) => Expanded(
              child: Padding(
                padding: const EdgeInsets.only(
                  right: kMediumSpacing,
                ), // Consistent spacing
                child: child,
              ),
            ),
          )
          .toList(),
    );
  }
}
