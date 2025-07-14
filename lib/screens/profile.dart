import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart'; // For image picking
import 'dart:io'; // For File
import 'package:path/path.dart' as p; // For path operations
import 'package:uuid/uuid.dart'; // For generating unique file names
import 'package:supabase_flutter/supabase_flutter.dart'; // Import Supabase types
import '../ui_constants.dart'; // Import your constants file
import '../services/supabase_service.dart'; // Import SupabaseService
import '../widgets/message_modal.dart'; // Import MessageModal
// Removed: import 'package:flutter/services.dart'; // Not needed for navigation to login screen

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _isEditing = false;
  bool _removePhoto = false;
  bool _isLoading = true; // To manage loading state for fetching/updating profile

  // Controllers for editing
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _countryController = TextEditingController();
  final TextEditingController _telegramUsernameController = TextEditingController();
  final TextEditingController _currentPasswordController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmNewPasswordController = TextEditingController();

  String _gender = 'Male';
  String? _profileImageUrl; // Placeholder image URL
  File? _selectedProfileImageFile; // To hold the newly selected image file

  final _formKey = GlobalKey<FormState>(); // For form validation

  @override
  void initState() {
    super.initState();
    _fetchUserProfile();
  }

  Future<void> _fetchUserProfile() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final User? currentUser = supabaseService.currentUser;
      if (currentUser == null) {
        MessageModal.show(context, MessageType.error, 'Error', 'User not logged in.');
        Navigator.pop(context); // Go back if no user
        return;
      }

      final Map<String, dynamic> userData = await supabaseService.client
          .from('profiles')
          .select()
          .eq('id', currentUser.id)
          .single();

      _fullNameController.text = userData['full_name'] ?? '';
      _emailController.text = userData['email'] ?? '';
      _phoneNumberController.text = userData['phone_number'] ?? '';
      _cityController.text = userData['city'] ?? '';
      _countryController.text = userData['country'] ?? '';
      _telegramUsernameController.text = userData['telegram_username'] ?? '';
      _gender = userData['gender'] ?? 'Male';
      _profileImageUrl = userData['profile_image_url'];

    } catch (e) {
      debugPrint('Error fetching user profile: $e');
      MessageModal.show(
        context,
        MessageType.error,
        'Error',
        'Failed to load profile details: ${e.toString()}',
      );
      Navigator.pop(context); // Go back if profile cannot be loaded
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery, imageQuality: 70);

    if (image != null) {
      setState(() {
        _selectedProfileImageFile = File(image.path);
        _profileImageUrl = null; // Clear network URL if new image is picked
        _removePhoto = false; // Ensure remove photo is unchecked
      });
    }
  }

  Future<String?> _uploadImage(File imageFile) async {
    try {
      final String fileName = '${const Uuid().v4()}${p.extension(imageFile.path)}';
      final String path = 'profile_images/${supabaseService.currentUser!.id}/$fileName'; // User-specific folder

      await supabaseService.client.storage
          .from('profile-pictures') // Correctly referencing 'profile-pictures'
          .upload(path, imageFile,
              fileOptions: const FileOptions(cacheControl: '3600', upsert: false));

      final String imageUrl = supabaseService.client.storage
          .from('profile-pictures') // Correctly referencing 'profile-pictures'
          .getPublicUrl(path);

      return imageUrl;
    } on StorageException catch (e) {
      debugPrint('Error uploading profile image to Supabase Storage: ${e.message}');
      MessageModal.show(
        context,
        MessageType.error,
        'Upload Failed',
        'Failed to upload profile image: ${e.message}',
      );
      return null;
    } catch (e) {
      debugPrint('General image upload error: $e');
      MessageModal.show(
        context,
        MessageType.error,
        'Upload Failed',
        'An unexpected error occurred during image upload: $e',
      );
      return null;
    }
  }

  Future<void> _updateProfile() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    String? finalProfileImageUrl = _profileImageUrl;

    if (_removePhoto) {
      finalProfileImageUrl = null; // Set to null if user wants to remove photo
      // TODO: Implement actual deletion from Supabase Storage here if needed
      // This would involve calling supabaseService.client.storage.from('profile-pictures').remove(...)
    } else if (_selectedProfileImageFile != null) {
      // If a new image is selected, upload it
      finalProfileImageUrl = await _uploadImage(_selectedProfileImageFile!);
      if (finalProfileImageUrl == null) {
        setState(() { _isLoading = false; });
        return; // Stop if image upload failed
      }
    }

    try {
      final User? currentUser = supabaseService.currentUser;
      if (currentUser == null) {
        MessageModal.show(context, MessageType.error, 'Error', 'User not logged in.');
        setState(() { _isLoading = false; });
        return;
      }

      // Update auth.users email if changed
      if (_emailController.text.trim() != currentUser.email) {
        await supabaseService.client.auth.updateUser(UserAttributes(
          email: _emailController.text.trim(),
        ));
      }

      // Update password if new password fields are filled
      if (_newPasswordController.text.isNotEmpty) {
        if (_newPasswordController.text != _confirmNewPasswordController.text) {
          MessageModal.show(
            context,
            MessageType.error,
            'Password Mismatch',
            'New password and confirm new password do not match.',
          );
          setState(() { _isLoading = false; });
          return;
        }
        // For security, Supabase requires current password for client-side password change.
        // If you want to allow password change without current password, you'd need a server-side function.
        // For now, we'll assume the current password field is used for re-authentication if needed.
        // A simple client-side password update:
        await supabaseService.client.auth.updateUser(UserAttributes(
          password: _newPasswordController.text.trim(),
        ));
        MessageModal.show(context, MessageType.success, 'Password Updated', 'Your password has been updated.');
        _currentPasswordController.clear();
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
        'profile_image_url': finalProfileImageUrl,
      };

      // Update profile in Supabase
      await supabaseService.client
          .from('profiles')
          .update(updates)
          .eq('id', currentUser.id);

      MessageModal.show(
        context,
        MessageType.success,
        'Success!',
        'Profile updated successfully.',
      );
      _fetchUserProfile(); // Re-fetch to update UI with latest data
      setState(() {
        _isEditing = false; // Exit editing mode
      });
    } on AuthException catch (e) {
      debugPrint('Supabase Auth Error during profile update: ${e.message}');
      MessageModal.show(
        context,
        MessageType.error,
        'Update Failed',
        'Authentication error: ${e.message}',
      );
    } catch (e) {
      debugPrint('General Profile Update Error: $e');
      MessageModal.show(
        context,
        MessageType.error,
        'Update Failed',
        'An unexpected error occurred: ${e.toString()}',
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _signOut() async {
    debugPrint('Attempting to sign out from ProfileScreen...'); // Debug print
    setState(() {
      _isLoading = true;
    });
    try {
      await supabaseService.signOut();
      debugPrint('Signed out successfully from ProfileScreen. Navigating to LoginScreen...'); // Debug print
      // Explicitly navigate to the LoginScreen and remove all routes from the stack
      if (mounted) {
        Navigator.of(context).pushNamedAndRemoveUntil(
          '/auth', // Use the named route for AuthScreen (which handles login/signup)
          (Route<dynamic> route) => false, // This predicate removes all routes below the new one
        );
      }
    } catch (e) {
      debugPrint('Error signing out from ProfileScreen: $e');
      MessageModal.show(
        context,
        MessageType.error,
        'Logout Failed',
        'An error occurred during logout: $e',
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
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _phoneNumberController.dispose();
    _cityController.dispose();
    _countryController.dispose();
    _telegramUsernameController.dispose();
    _currentPasswordController.dispose();
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
          'My Profile',
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
          if (!_isEditing)
            IconButton(
              icon: const Icon(Icons.edit, color: kYellowEdit),
              onPressed: () {
                setState(() {
                  _isEditing = true;
                });
              },
            )
          else
            IconButton(
              icon: _isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(color: kWhite, strokeWidth: 2),
                    )
                  : const Icon(Icons.check, color: kWhite),
              onPressed: _isLoading ? null : _updateProfile,
            ),
          const SizedBox(width: kSmallSpacing), // Consistent spacing
        ],
      ),
      body: _isLoading && !_isEditing // Show loading only when initially fetching
          ? const Center(child: CircularProgressIndicator(color: kDarkRed))
          : SingleChildScrollView(
              padding: kDefaultPadding, // Use kDefaultPadding
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: GestureDetector(
                        onTap: _isEditing ? _pickImage : null, // Only pick image in edit mode
                        child: Stack(
                          alignment: Alignment.bottomRight,
                          children: [
                            CircleAvatar(
                              radius: 60,
                              backgroundColor: kLightGrey,
                              backgroundImage: _selectedProfileImageFile != null
                                  ? FileImage(_selectedProfileImageFile!) as ImageProvider
                                  : (_profileImageUrl != null && !_removePhoto
                                      ? NetworkImage(_profileImageUrl!)
                                      : null),
                              child: (_selectedProfileImageFile == null && (_profileImageUrl == null || _removePhoto))
                                  ? Icon(Icons.person, size: 60, color: kGrey)
                                  : null,
                            ),
                            if (_isEditing)
                              Positioned(
                                right: 0,
                                bottom: 0,
                                child: Container(
                                  padding: const EdgeInsets.all(kSmallSpacing / 2),
                                  decoration: BoxDecoration(
                                    color: kDarkRed,
                                    shape: BoxShape.circle,
                                    boxShadow: const [kButtonBoxShadow],
                                  ),
                                  child: const Icon(Icons.camera_alt, color: kWhite, size: 20),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                    if (_isEditing)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: kSmallSpacing),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Checkbox(
                              value: _removePhoto,
                              onChanged: (bool? value) {
                                setState(() {
                                  _removePhoto = value!;
                                  if (_removePhoto) {
                                    _selectedProfileImageFile = null; // Clear selected file if removing
                                  }
                                });
                              },
                              activeColor: kDarkRed,
                            ),
                            Text('Remove Photo', style: GoogleFonts.poppins(color: kBlack)),
                          ],
                        ),
                      ),
                    const SizedBox(height: kLargeSpacing), // Consistent spacing

                    // Personal Information Section
                    Card(
                      margin: EdgeInsets.zero, // Card handles its own margin
                      shape: RoundedRectangleBorder(borderRadius: kDefaultBorderRadius),
                      elevation: 3,
                      child: Padding(
                        padding: kDefaultPadding,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Personal Information',
                              style: GoogleFonts.poppins(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: kDarkRed,
                              ),
                            ),
                            const SizedBox(height: kMediumSpacing),
                            _buildTextField(
                              _fullNameController,
                              'Full Name',
                              editable: _isEditing,
                              validator: (value) {
                                if (_isEditing && (value == null || value.isEmpty)) {
                                  return 'Full Name is required';
                                }
                                return null;
                              },
                            ),
                            _buildTextField(_emailController, 'Email', editable: false), // Email not directly editable here for security
                            _buildTextField(
                              _phoneNumberController,
                              'Phone Number',
                              editable: _isEditing,
                              keyboardType: TextInputType.phone,
                              validator: (value) {
                                if (_isEditing && (value == null || value.isEmpty)) {
                                  return 'Phone Number is required';
                                }
                                if (_isEditing && value != null && !RegExp(r'^[0-9]+$').hasMatch(value)) {
                                  return 'Enter a valid phone number';
                                }
                                return null;
                              },
                            ),
                            _buildFormRow([
                              _buildTextField(_cityController, 'City', editable: _isEditing),
                              _buildTextField(_countryController, 'Country', editable: _isEditing),
                            ]),
                            _buildTextField(_telegramUsernameController, 'Telegram Username', editable: _isEditing),
                            _buildGenderRadioButtons(),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: kLargeSpacing), // Spacing between cards

                    // Change Password Section (only visible when editing)
                    if (_isEditing)
                      Card(
                        margin: EdgeInsets.zero,
                        shape: RoundedRectangleBorder(borderRadius: kDefaultBorderRadius),
                        elevation: 3,
                        child: Padding(
                          padding: kDefaultPadding,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Change Password',
                                style: GoogleFonts.poppins(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: kDarkRed,
                                ),
                              ),
                              const SizedBox(height: kMediumSpacing),
                              _buildTextField(_currentPasswordController, 'Current Password', obscureText: true, editable: _isEditing),
                              _buildTextField(_newPasswordController, 'New Password', obscureText: true, editable: _isEditing, validator: (value) {
                                if (_newPasswordController.text.isNotEmpty && (value == null || value.length < 6)) {
                                  return 'Password must be at least 6 characters';
                                }
                                return null;
                              }),
                              _buildTextField(_confirmNewPasswordController, 'Confirm New Password', obscureText: true, editable: _isEditing, validator: (value) {
                                if (_newPasswordController.text.isNotEmpty && value != _newPasswordController.text) {
                                  return 'Passwords do not match';
                                }
                                return null;
                              }),
                            ],
                          ),
                        ),
                      ),
                    const SizedBox(height: kLargeSpacing), // Add spacing if needed at the bottom of the scroll view
                  ],
                ),
              ),
            ),
      floatingActionButton: FloatingActionButton.extended( // FloatingActionButton for Logout
        onPressed: _signOut,
        backgroundColor: kRedError,
        foregroundColor: kWhite,
        icon: const Icon(Icons.logout),
        label: Text(
          'Logout',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        shape: RoundedRectangleBorder(borderRadius: kSmallBorderRadius),
        elevation: 5,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat, // Position at bottom right
    );
  }

  InputDecoration _inputDecoration(String hintText) {
    return InputDecoration(
      hintText: hintText,
      filled: true,
      fillColor: kWhite,
      border: OutlineInputBorder(
        borderRadius: kSmallBorderRadius,
        borderSide: const BorderSide(color: Color(0xFFCCCCCC)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: kSmallBorderRadius,
        borderSide: const BorderSide(color: Color(0xFFCCCCCC)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: kSmallBorderRadius,
        borderSide: const BorderSide(color: kDarkRed, width: 2),
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
    );
  }

  Widget _buildTextField(TextEditingController controller, String hintText, {bool obscureText = false, TextInputType keyboardType = TextInputType.text, bool editable = true, String? Function(String?)? validator}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: kSmallSpacing),
      child: TextFormField(
        controller: controller,
        obscureText: obscureText,
        keyboardType: keyboardType,
        readOnly: !editable,
        style: GoogleFonts.poppins(color: editable ? kBlack : kGrey),
        decoration: _inputDecoration(hintText).copyWith(
          fillColor: editable ? kWhite : kLightGrey, // Visual feedback for editable state
        ),
        validator: validator,
      ),
    );
  }

  Widget _buildGenderRadioButtons() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: kSmallSpacing),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Gender',
            style: GoogleFonts.poppins(fontWeight: FontWeight.w600, color: const Color(0xFF333333)),
          ),
          const SizedBox(height: kSmallSpacing),
          Row(
            children: [
              Radio<String>(
                value: 'Male',
                groupValue: _gender,
                onChanged: _isEditing ? (String? value) {
                  setState(() {
                    _gender = value!;
                  });
                } : null, // Disabled if not editing
                activeColor: kDarkRed,
              ),
              Text('Male', style: GoogleFonts.poppins(color: _isEditing ? kBlack : kGrey)), // Text color changes
              const SizedBox(width: kMediumSpacing),
              Radio<String>(
                value: 'Female',
                groupValue: _gender,
                onChanged: _isEditing ? (String? value) {
                  setState(() {
                    _gender = value!;
                  });
                } : null, // Disabled if not editing
                activeColor: kDarkRed,
              ),
              Text('Female', style: GoogleFonts.poppins(color: _isEditing ? kBlack : kGrey)), // Text color changes
              const SizedBox(width: kMediumSpacing),
              Radio<String>(
                value: 'Other',
                groupValue: _gender,
                onChanged: _isEditing ? (String? value) {
                  setState(() {
                    _gender = value!;
                  });
                } : null, // Disabled if not editing
                activeColor: kDarkRed,
              ),
              Text('Other', style: GoogleFonts.poppins(color: _isEditing ? kBlack : kGrey)), // Text color changes
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
}
