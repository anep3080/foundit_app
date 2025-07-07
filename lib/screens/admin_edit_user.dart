import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import '../ui_constants.dart'; // Import your constants file

class AdminEditUserScreen extends StatefulWidget {
  final String userId; // Assuming user ID is passed for editing

  const AdminEditUserScreen({super.key, required this.userId});

  @override
  State<AdminEditUserScreen> createState() => _AdminEditUserScreenState();
}

class _AdminEditUserScreenState extends State<AdminEditUserScreen> {
  // Placeholder data for user details
  String _fullName = 'Jane Doe';
  String _email = 'jane.doe@example.com';
  String _phoneNumber = '987-654-3210';
  String _city = 'London';
  String _country = 'UK';
  String _telegramUsername = '@janedoe';
  String _gender = 'Female';
  String _userType = 'user'; // 'user' or 'admin'

  // Controllers for editing
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _countryController = TextEditingController();
  final TextEditingController _telegramUsernameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Simulate fetching user data based on widget.userId
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
    super.dispose();
  }

  void _saveChanges() {
    setState(() {
      _fullName = _fullNameController.text;
      _phoneNumber = _phoneNumberController.text;
      _city = _cityController.text;
      _country = _countryController.text;
      _telegramUsername = _telegramUsernameController.text;
      // _gender and _userType are updated via radio buttons
    });
    print('Admin saving changes for user ${widget.userId}');
    // Implement actual update logic here
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kPrimaryYellowGreen,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Container(
            padding: const EdgeInsets.all(30.0),
            decoration: BoxDecoration(
              color: kLightYellow,
              borderRadius: BorderRadius.circular(16),
              boxShadow: const [kDefaultBoxShadow],
            ),
            constraints: const BoxConstraints(maxWidth: 700),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
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
                    InkWell(
                      onTap: () => print('Admin Home icon pressed'),
                      borderRadius: BorderRadius.circular(50),
                      child: Container(
                        width: 38,
                        height: 38,
                        decoration: BoxDecoration(
                          color: kWhite,
                          borderRadius: BorderRadius.circular(50),
                          border: Border.all(color: kBlack, width: 2),
                        ),
                        child: const Icon(FontAwesomeIcons.home, color: kBlack, size: 18),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Align(
                  alignment: Alignment.center,
                  child: Text(
                    'Edit User: $_fullName',
                    style: GoogleFonts.poppins(
                      fontSize: 24,
                      color: const Color(0xFF333333),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(height: 25),
                _buildEditTextField('Full Name', _fullNameController, required: true),
                _buildEditTextField('Email Address', TextEditingController(text: _email), readOnly: true), // Email is readonly
                _buildEditTextField('Phone Number', _phoneNumberController, keyboardType: TextInputType.phone),
                _buildEditTextField('City', _cityController),
                _buildEditTextField('Country', _countryController),
                _buildEditTextField('Telegram Username', _telegramUsernameController, hintText: '@username'),
                _buildGenderRadioButtons(),
                _buildUserTypeRadioButtons(),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _saveChanges,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kDarkRed,
                    foregroundColor: kWhite,
                    padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    textStyle: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w600),
                    minimumSize: const Size(double.infinity, 50),
                  ),
                  child: const Text('Save Changes'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEditTextField(String label, TextEditingController controller, {bool obscureText = false, String? hintText, TextInputType keyboardType = TextInputType.text, bool required = false, bool readOnly = false}) {
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
            readOnly: readOnly,
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
                borderSide: BorderSide(color: readOnly ? const Color(0xFFDDDDDD) : const Color(0xFFCCCCCC)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: readOnly ? const Color(0xFFDDDDDD) : kDarkRed),
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
              const SizedBox(width: 20),
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
      padding: const EdgeInsets.symmetric(vertical: 7.5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'User Type',
            style: GoogleFonts.poppins(fontWeight: FontWeight.w600, color: const Color(0xFF333333)),
          ),
          const SizedBox(height: 5),
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
              const SizedBox(width: 20),
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
}