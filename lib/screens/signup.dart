import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import '../ui_constants.dart'; // Import your constants file

class SignupScreen extends StatelessWidget {
  const SignupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kPrimaryYellowGreen,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Container(
            padding: const EdgeInsets.all(20.0),
            decoration: BoxDecoration(
              color: kLightYellow,
              borderRadius: BorderRadius.circular(10),
              boxShadow: const [kDefaultBoxShadow],
            ),
            constraints: const BoxConstraints(maxWidth: 1000),
            child: Row(
              children: [
                // Left Panel
                Expanded(
                  flex: 1,
                  child: Container(
                    decoration: BoxDecoration(
                      color: kPrimaryYellowGreen,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildVerticalText('S'),
                        _buildVerticalText('I'),
                        _buildVerticalText('G'),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 20.0),
                          child: Image.asset(
                            'assets/images/foundit_logo.png', // Make sure you have this asset
                            width: 200,
                            filterQuality: FilterQuality.high,
                          ),
                        ),
                        _buildVerticalText('U'),
                        _buildVerticalText('P'),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 20),
                // Right Panel
                Expanded(
                  flex: 2,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Align(
                        alignment: Alignment.topLeft,
                        child: TextButton.icon(
                          onPressed: () {
                            // Navigator.pop(context); // Implement actual navigation
                            print('Back button pressed');
                          },
                          icon: const Icon(FontAwesomeIcons.arrowLeft, color: kBlack, size: 18),
                          label: Text(
                            'Back',
                            style: GoogleFonts.poppins(
                              color: kBlack,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          style: TextButton.styleFrom(
                            padding: EdgeInsets.zero,
                            alignment: Alignment.centerLeft,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      _buildSignupForm(),
                      const SizedBox(height: 20),
                      Align(
                        alignment: Alignment.center,
                        child: GestureDetector(
                          onTap: () {
                            print('Login link pressed');
                          },
                          child: RichText(
                            text: TextSpan(
                              text: "Already have an account? ",
                              style: GoogleFonts.poppins(fontSize: 14, color: const Color(0xFF555555)),
                              children: [
                                TextSpan(
                                  text: 'Log In',
                                  style: GoogleFonts.poppins(
                                    color: kDarkRed,
                                    fontWeight: FontWeight.w500,
                                    decoration: TextDecoration.underline,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildVerticalText(String text) {
    return Text(
      text,
      style: GoogleFonts.poppins(
        fontSize: 32,
        fontWeight: FontWeight.bold,
        letterSpacing: 8,
      ),
    );
  }

  Widget _buildSignupForm() {
    return Column(
      children: [
        _buildFormRow([
          _buildTextField('Full Name'),
          _buildTextField('Phone Number', keyboardType: TextInputType.phone),
        ]),
        _buildFormRow([
          _buildTextField('Email', keyboardType: TextInputType.emailAddress),
          _buildTextField('City'),
        ]),
        _buildFormRow([
          _buildTextField('Password', obscureText: true),
          _buildTextField('Confirm Password', obscureText: true),
        ]),
        _buildFormRow([
          _buildTextField('Country'),
          _buildTextField('Telegram Username (e.g., @yourusername)'),
        ]),
        _buildFormRow([
          _buildTextField('Gender (optional)'),
        ]),
        const SizedBox(height: 20),
        ElevatedButton.icon(
          onPressed: () {
            print('Sign Up button pressed');
          },
          icon: const Icon(FontAwesomeIcons.arrowRight, color: kBlack),
          label: Text(
            'SIGN UP',
            style: GoogleFonts.poppins(
              color: kBlack,
              fontSize: 16,
            ),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFEAF764),
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            minimumSize: const Size(double.infinity, 50),
          ),
        ),
      ],
    );
  }

  Widget _buildFormRow(List<Widget> children) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: children.map((child) => Expanded(child: Padding(
        padding: const EdgeInsets.only(right: 20.0), // Gap between fields
        child: child,
      ))).toList(),
    );
  }

  Widget _buildTextField(String hintText, {bool obscureText = false, TextInputType keyboardType = TextInputType.text}) {
    return TextField(
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
        contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
      ),
    );
  }
}