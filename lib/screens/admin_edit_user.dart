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
  final TextEditingController _telegramUsernameController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController(); // For admin-initiated password reset
  final TextEditingController _confirmNewPasswordController = TextEditingController();

  String _gender = 'Male'; // Default gender
  String _userType = 'user'; // Default user type
  bool _isLoading = true; // To manage loading state for fetching/updating user

  @override
  void initState() {
    super.initState();
    _fetchUserDetails();
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

  Future<void> _fetchUserDetails() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final response = await supabaseService.client
          .from('profiles')
          .select('*')
          .eq('id', widget.userId)
          .single();

      _fullNameController.text = response['full_name'] ?? '';
      _emailController.text = response['email'] ?? ''; // Assuming email is stored in profiles table for admin view
      _phoneNumberController.text = response['phone_number'] ?? '';
      _cityController.text = response['city'] ?? '';
      _countryController.text = response['country'] ?? '';
      _telegramUsernameController.text = response['telegram_username'] ?? '';
      _gender = response['gender'] ?? 'Male';
      _userType = response['user_type'] ?? 'user';
    } catch (e) {
      debugPrint('Error fetching user details for admin: $e');
      MessageModal.show(context, MessageType.error, 'Error', 'Failed to load user data.');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _updateUser() async {
    setState(() {
      _isLoading = true;
    });

    if (_newPasswordController.text.isNotEmpty && _newPasswordController.text != _confirmNewPasswordController.text) {
      MessageModal.show(context, MessageType.error, 'Update Failed', 'New password and confirm password do not match.');
      setState(() {
        _isLoading = false;
      });
      return;
    }

    try {
      // Update profile data
      await supabaseService.client.from('profiles').update({
        'full_name': _fullNameController.text.trim(),
        'phone_number': _phoneNumberController.text.trim(),
        'city': _cityController.text.trim(),
        'country': _countryController.text.trim(),
        'telegram_username': _telegramUsernameController.text.trim(),
        'gender': _gender,
        'user_type': _userType,
      }).eq('id', widget.userId);

      // If a new password is provided, update user's auth password
      if (_newPasswordController.text.isNotEmpty) {
        // This operation typically requires admin privileges on the backend
        // or a specific Supabase function for admin password reset.
        // For simplicity, this example assumes direct update if allowed by RLS.
        // In a real app, you'd likely call a secure backend function.
        // Supabase client.auth.admin.updateUserById is not directly available client-side for security.
        // You would need to set up a custom edge function or a server-side API.
        // For now, we'll simulate it as if it's possible.
        MessageModal.show(context, MessageType.info, 'Password Reset', 'Password reset functionality requires backend implementation. This is a placeholder.');
      }

      MessageModal.show(context, MessageType.success, 'Success', 'User profile updated successfully!');
      Navigator.of(context).pop(); // Go back to admin homepage
    } on PostgrestException catch (e) {
      debugPrint('Supabase Update Error: ${e.message}');
      MessageModal.show(context, MessageType.error, 'Update Failed', e.message);
    } catch (e) {
      debugPrint('General Update Error: $e');
      MessageModal.show(context, MessageType.error, 'Update Failed', 'An unexpected error occurred: ${e.toString()}');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackground, // Use new background color
      appBar: AppBar(
        backgroundColor: kBackground, // Match app bar background
        elevation: 0,
        title: Text(
          'Edit User',
          style: GoogleFonts.poppins(
            color: kPrimaryBlack,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: kPrimaryBlack),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: kPrimaryYellow))
          : SingleChildScrollView(
              padding: kDefaultPadding,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Editing User ID: ${widget.userId}',
                    style: GoogleFonts.poppins(color: kGrey, fontSize: 16),
                  ),
                  const SizedBox(height: kLargeSpacing),
                  _buildForm(),
                  const SizedBox(height: kLargeSpacing),
                  _buildActionButton(
                    text: 'Save Changes',
                    color: kPrimaryGreen, // Green for save
                    onPressed: _updateUser,
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildForm() {
    return Container(
      padding: kMediumPadding,
      decoration: BoxDecoration(
        color: kBackground,
        borderRadius: kDefaultBorderRadius,
        boxShadow: [
          kNeumorphicShadowDark,
          kNeumorphicShadowLight,
        ],
      ),
      child: Column(
        children: [
          _buildFormRow([
            _buildTextField(
              controller: _fullNameController,
              labelText: 'Full Name',
              icon: Icons.person,
            ),
            _buildTextField(
              controller: _emailController,
              labelText: 'Email',
              icon: Icons.email,
              keyboardType: TextInputType.emailAddress,
              enabled: false, // Email is usually not editable by admin directly here
            ),
          ]),
          const SizedBox(height: kMediumSpacing),
          _buildFormRow([
            _buildTextField(
              controller: _phoneNumberController,
              labelText: 'Phone Number',
              icon: Icons.phone,
              keyboardType: TextInputType.phone,
            ),
            _buildTextField(
              controller: _cityController,
              labelText: 'City',
              icon: Icons.location_city,
            ),
          ]),
          const SizedBox(height: kMediumSpacing),
          _buildFormRow([
            _buildTextField(
              controller: _countryController,
              labelText: 'Country',
              icon: Icons.public,
            ),
            _buildTextField(
              controller: _telegramUsernameController,
              labelText: 'Telegram Username',
              icon: FontAwesomeIcons.telegram,
            ),
          ]),
          const SizedBox(height: kMediumSpacing),
          _buildGenderSelection(),
          const SizedBox(height: kMediumSpacing),
          _buildUserTypeSelection(),
          const SizedBox(height: kLargeSpacing),
          Text(
            'Admin Password Reset (Optional)',
            style: GoogleFonts.poppins(fontWeight: FontWeight.w600, color: kPrimaryBlack),
          ),
          const SizedBox(height: kSmallSpacing),
          _buildTextField(
            controller: _newPasswordController,
            labelText: 'New Password',
            icon: Icons.lock,
            obscureText: true,
          ),
          const SizedBox(height: kMediumSpacing),
          _buildTextField(
            controller: _confirmNewPasswordController,
            labelText: 'Confirm New Password',
            icon: Icons.lock_reset,
            obscureText: true,
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
    bool enabled = true,
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
        enabled: enabled,
        style: GoogleFonts.poppins(color: enabled ? kPrimaryBlack : kGrey),
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
          disabledBorder: OutlineInputBorder(
            borderRadius: kSmallBorderRadius,
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: kMediumSpacing, vertical: kMediumSpacing),
        ),
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
                activeColor: kPrimaryYellow,
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

  Widget _buildUserTypeSelection() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: kSmallSpacing),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'User Type',
            style: GoogleFonts.poppins(fontWeight: FontWeight.w600, color: kPrimaryBlack),
          ),
          const SizedBox(height: kSmallSpacing),
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
                activeColor: kPrimaryYellow,
              ),
              Text('User', style: GoogleFonts.poppins(color: kPrimaryBlack)),
              const SizedBox(width: kMediumSpacing),
              Radio<String>(
                value: 'admin',
                groupValue: _userType,
                onChanged: (String? value) {
                  setState(() {
                    _userType = value!;
                  });
                },
                activeColor: kPrimaryYellow,
              ),
              Text('Admin', style: GoogleFonts.poppins(color: kPrimaryBlack)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFormRow(List<Widget> children) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: children.map((child) => Expanded(child: Padding(
        padding: const EdgeInsets.only(right: kMediumSpacing),
        child: child,
      ))).toList(),
    );
  }

  Widget _buildActionButton({
    required String text,
    required Color color,
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
          color: color, // Use the passed color
          borderRadius: kSmallBorderRadius,
          boxShadow: onPressed != null
              ? [
                  kNeumorphicShadowDark,
                  kNeumorphicShadowLight,
                ]
              : [], // No shadow if disabled
        ),
        child: Center(
          child: Text(
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
