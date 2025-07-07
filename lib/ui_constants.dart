import 'package:flutter/material.dart';

// Colors
const Color kPrimaryYellowGreen = Color(0xFFF5FF9C);
const Color kLightYellow = Color(0xFFFFFDD0);
const Color kDarkRed = Color(0xFF8B1E1E);
const Color kGreenButton = Color(0xFF00FF00); // From login.php
const Color kBlack = Colors.black;
const Color kWhite = Colors.white;
const Color kGrey = Color(0xFF6C757D); // From unified_styles.css
const Color kLightGrey = Color(0xFFE9ECEF); // From unified_styles.css
const Color kRedError = Color(0xFFDC3545); // From message_modal.php
const Color kGreenSuccess = Color(0xFF28A745); // From message_modal.php
const Color kYellowEdit = Color(0xFFFFC107); // From lost_item_view.php

// Text Styles (using Poppins from google_fonts)
// You'll need to import google_fonts in your main.dart or theme file
// and set it as the default text theme for these to work automatically.
// For direct use, you can do: GoogleFonts.poppins(fontSize: 16, color: kBlack)

// Box Shadows
const BoxShadow kDefaultBoxShadow = BoxShadow(
  color: Color.fromRGBO(0, 0, 0, 0.1),
  blurRadius: 10,
  offset: Offset(0, 4),
);

const BoxShadow kButtonBoxShadow = BoxShadow(
  color: Color.fromRGBO(0, 0, 0, 0.1),
  blurRadius: 6,
  offset: Offset(0, 4),
);

// Border Radius
const BorderRadius kDefaultBorderRadius = BorderRadius.all(Radius.circular(16));
const BorderRadius kSmallBorderRadius = BorderRadius.all(Radius.circular(8));
const BorderRadius kCircularBorderRadius = BorderRadius.all(
  Radius.circular(9999),
); // For badges/pills

// Spacing
const EdgeInsets kDefaultPadding = EdgeInsets.all(20);
const EdgeInsets kSmallPadding = EdgeInsets.all(15);
const EdgeInsets kLargePadding = EdgeInsets.all(30);
