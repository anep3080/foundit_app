import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import '../ui_constants.dart'; // Import your constants file

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _isEditing = false;
  bool _removePhoto = false;

  // Placeholder data
  String _fullName = 'John Doe';
  String _email = 'john.doe@example.com';
  String _phoneNumber = '123-456-7890';
  String _city = 'New York';
  String _country = 'USA';
  String _telegramUsername = '@johndoe';
  String _gender = 'Male';
  String? _profileImageUrl = 'https://via.placeholder.com/120/8B1E1E/FFFFFF?text=JD'; // Placeholder image

  // Controllers for editing
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _countryController = TextEditingController();
  final TextEditingController _telegramUsernameController = TextEditingController();
  final TextEditingController _currentPasswordController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmNewPasswordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fullNameController.text = _fullName;
    _phoneNumberController.text = _phoneNumber;
    _cityController.text = _city;
    _countryController.text = _country;
    _telegramUsernameController.text = _telegramUsername;
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _phoneNumberController.dispose();
    _cityController.dispose();
    _countryController.dispose();
    _telegramUsernameController.dispose();
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmNewPasswordController.dispose();
    super.dispose();
  }

  void _toggleEditMode() {
    setState(() {
      _isEditing = !_isEditing;
      if (!_isEditing) {
        // Reset password fields when exiting edit mode
        _currentPasswordController.clear();
        _newPasswordController.clear();
        _confirmNewPasswordController.clear();
        _removePhoto = false; // Reset remove photo checkbox
      }
    });
  }

  void _saveChanges() {
    setState(() {
      _fullName = _fullNameController.text;
      _phoneNumber = _phoneNumberController.text;
      _city = _cityController.text;
      _country = _countryController.text;
      _telegramUsername = _telegramUsernameController.text;

      if (_removePhoto) {
        _profileImageUrl = null;
      }
      // Password change logic would go here (e.g., validate and call backend)
      print('Saving changes...');
      _toggleEditMode();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kPrimaryYellowGreen,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              _buildHeader(),
              const SizedBox(height: 30),
              _isEditing ? _buildEditProfileSection() : _buildViewProfileSection(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'FoundIt',
          style: GoogleFonts.poppins(
            fontSize: 32,
            fontWeight: FontWeight.w800,
            shadows: [
              Shadow(
                color: Colors.black.withOpacity(0.1),
                offset: const Offset(2, 2),
                blurRadius: 2,
              ),
            ],
          ),
        ),
        Row(
          children: [
            _buildNavIcon(FontAwesomeIcons.home, 'Home', () => print('Home')),
            _buildNavIcon(FontAwesomeIcons.tachometerAlt, 'Dashboard', () => print('Dashboard')),
          ],
        ),
      ],
    );
  }

  Widget _buildNavIcon(IconData icon, String tooltip, VoidCallback onPressed) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 5.0),
      child: Tooltip(
        message: tooltip,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(50),
          child: Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: kWhite,
              borderRadius: BorderRadius.circular(50),
              border: Border.all(color: kBlack, width: 2),
            ),
            child: Icon(icon, color: kBlack, size: 18),
          ),
        ),
      ),
    );
  }

  Widget _buildViewProfileSection() {
    return Container(
      padding: const EdgeInsets.all(30),
      decoration: BoxDecoration(
        color: kLightYellow,
        borderRadius: BorderRadius.circular(15),
        boxShadow: const [kDefaultBoxShadow],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Align(
            alignment: Alignment.topLeft,
            child: InkWell(
              onTap: () => print('Back to Home'),
              borderRadius: BorderRadius.circular(50),
              child: Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: kWhite,
                  borderRadius: BorderRadius.circular(50),
                  border: Border.all(color: kBlack, width: 2),
                ),
                child: const Icon(FontAwesomeIcons.arrowLeft, color: kBlack, size: 18),
              ),
            ),
          ),
          const SizedBox(height: 20),
          GestureDetector(
            onTap: () {
              print('Change profile photo');
              // Implement image picker logic here
            },
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: kDarkRed,
                borderRadius: BorderRadius.circular(60),
                border: Border.all(color: Colors.grey[400]!, width: 3),
                image: _profileImageUrl != null
                    ? DecorationImage(
                        image: NetworkImage(_profileImageUrl!),
                        fit: BoxFit.cover,
                      )
                    : null,
              ),
              alignment: Alignment.center,
              child: _profileImageUrl == null
                  ? Text(
                      _fullName.isNotEmpty ? _fullName[0].toUpperCase() : '',
                      style: GoogleFonts.poppins(color: kWhite, fontSize: 48),
                    )
                  : null,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            _fullName,
            style: GoogleFonts.poppins(fontSize: 28, color: const Color(0xFF333333)),
          ),
          Text(
            _email,
            style: GoogleFonts.poppins(fontSize: 16, color: const Color(0xFF777777)),
          ),
          const SizedBox(height: 30),
          _buildDetailRow('Phone Number:', _phoneNumber),
          _buildDetailRow('City:', _city),
          _buildDetailRow('Country:', _country),
          _buildDetailRow('Telegram:', _telegramUsername),
          _buildDetailRow('Gender:', _gender),
          const SizedBox(height: 30),
          ElevatedButton(
            onPressed: _toggleEditMode,
            style: ElevatedButton.styleFrom(
              backgroundColor: kDarkRed,
              foregroundColor: kWhite,
              padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              textStyle: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w600),
              minimumSize: const Size(double.infinity, 50),
            ),
            child: const Text('Edit Profile'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Container(
        decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: Color(0xFFEEEEEE), style: BorderStyle.solid)),
        ),
        padding: const EdgeInsets.only(bottom: 10.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: GoogleFonts.poppins(fontWeight: FontWeight.w600, color: const Color(0xFF333333)),
            ),
            Text(
              value,
              style: GoogleFonts.poppins(color: const Color(0xFF555555)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEditProfileSection() {
    return Container(
      padding: const EdgeInsets.all(30),
      decoration: BoxDecoration(
        color: kLightYellow,
        borderRadius: BorderRadius.circular(15),
        boxShadow: const [kDefaultBoxShadow],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            'Edit Profile',
            style: GoogleFonts.poppins(fontSize: 28, color: const Color(0xFF333333)),
          ),
          const SizedBox(height: 25),
          _buildEditTextField('Full Name', _fullNameController, required: true),
          _buildEditTextField('Phone Number', _phoneNumberController, keyboardType: TextInputType.phone),
          _buildEditTextField('City', _cityController),
          _buildEditTextField('Country', _countryController),
          _buildEditTextField('Telegram Username', _telegramUsernameController, hintText: '@username'),
          _buildGenderRadioButtons(),
          if (_profileImageUrl != null)
            Padding(
              padding: const EdgeInsets.only(top: 10.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Checkbox(
                    value: _removePhoto,
                    onChanged: (bool? value) {
                      setState(() {
                        _removePhoto = value ?? false;
                      });
                    },
                  ),
                  Text(
                    'Remove current profile photo',
                    style: GoogleFonts.poppins(fontSize: 14, color: const Color(0xFF555555)),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 30),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Change Password',
              style: GoogleFonts.poppins(
                fontSize: 20,
                color: const Color(0xFF333333),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const Divider(color: Color(0xFFEEEEEE), thickness: 1, height: 20),
          _buildEditTextField('Current Password', _currentPasswordController, obscureText: true),
          _buildEditTextField('New Password', _newPasswordController, obscureText: true),
          _buildEditTextField('Confirm New Password', _confirmNewPasswordController, obscureText: true),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: _saveChanges,
            style: ElevatedButton.styleFrom(
              backgroundColor: kGreenSuccess,
              foregroundColor: kWhite,
              padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              textStyle: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w600),
              minimumSize: const Size(double.infinity, 50),
            ),
            child: const Text('Save Changes'),
          ),
          const SizedBox(height: 10),
          ElevatedButton(
            onPressed: _toggleEditMode,
            style: ElevatedButton.styleFrom(
              backgroundColor: kRedError,
              foregroundColor: kWhite,
              padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              textStyle: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w600),
              minimumSize: const Size(double.infinity, 50),
            ),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  Widget _buildEditTextField(String label, TextEditingController controller, {bool obscureText = false, String? hintText, TextInputType keyboardType = TextInputType.text, bool required = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7.5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label + (required ? '*' : ''),
            style: GoogleFonts.poppins(fontWeight: FontWeight.w600, color: const Color(0xFF333333)),
          ),
          const SizedBox(height: 5),
          TextField(
            controller: controller,
            obscureText: obscureText,
            keyboardType: keyboardType,
            decoration: InputDecoration(
              hintText: hintText,
              filled: true,
              fillColor: kWhite,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Color(0xFFCCCCCC)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Color(0xFFCCCCCC)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: kDarkRed),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGenderRadioButtons() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7.5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Gender',
            style: GoogleFonts.poppins(fontWeight: FontWeight.w600, color: const Color(0xFF333333)),
          ),
          const SizedBox(height: 5),
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
              const SizedBox(width: 20),
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
            ],
          ),
        ],
      ),
    );
  }
}