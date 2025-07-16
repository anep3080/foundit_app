import 'package:flutter/material.dart';

// Colors
const Color kPrimaryYellowGreen = Color(0xFFF5FF9C); // Lightest background
const Color kLightYellow = Color(0xFFFFFDD0); // Card/Container background
const Color kDarkRed = Color(0xFF8B1E1E); // Primary accent, buttons, headings
const Color kGreenButton = Color(0xFF00FF00); // Original green, consider if still needed or use kGreenSuccess
const Color kBlack = Colors.black; // Primary text color
const Color kWhite = Colors.white; // White text/elements
const Color kGrey = Color(0xFF6C757D); // Secondary text, borders
const Color kLightGrey = Color(0xFFE9ECEF); // Placeholder backgrounds, disabled states
const Color kRedError = Color(0xFFDC3545); // Error messages, destructive actions
const Color kGreenSuccess = Color(0xFF28A745); // Success messages, positive actions
const Color kYellowEdit = Color(0xFFFFC107); // Edit actions, warnings
const Color kBlueInfo = Color(0xFF007BFF); // Info messages, general links

// Text Styles (using Poppins from google_fonts, assuming it's set in main.dart theme)
// These provide a consistent typographic scale
const TextStyle kDisplayLarge = TextStyle(
  fontSize: 36,
  fontWeight: FontWeight.bold,
  color: kDarkRed,
);

const TextStyle kHeadlineMedium = TextStyle(
  fontSize: 28,
  fontWeight: FontWeight.bold,
  color: kDarkRed,
);

const TextStyle kTitleLarge = TextStyle(
  fontSize: 22,
  fontWeight: FontWeight.w600,
  color: Color(0xFF333333), // Darker grey for titles
);

const TextStyle kBodyLarge = TextStyle(
  fontSize: 18,
  color: kBlack,
);

const TextStyle kBodyMedium = TextStyle(
  fontSize: 16,
  color: kBlack,
);

const TextStyle kBodySmall = TextStyle(
  fontSize: 14,
  color: kGrey,
);

const TextStyle kLabelLarge = TextStyle(
  fontSize: 16,
  fontWeight: FontWeight.w500,
  color: kWhite, // For primary buttons
);

const TextStyle kLabelMedium = TextStyle(
  fontSize: 14,
  fontWeight: FontWeight.w500,
  color: kDarkRed, // For secondary actions/links
);

// Box Shadows
const BoxShadow kDefaultBoxShadow = BoxShadow(
  color: Color.fromRGBO(0, 0, 0, 0.1),
  blurRadius: 10,
  offset: Offset(0, 4),
);

const BoxShadow kButtonBoxShadow = BoxShadow(
  color: Color.fromRGBO(0, 0, 0, 0.15), // Slightly more prominent
  blurRadius: 8,
  offset: Offset(0, 4),
);

// Border Radius
const BorderRadius kDefaultBorderRadius = BorderRadius.all(Radius.circular(12));
const BorderRadius kSmallBorderRadius = BorderRadius.all(Radius.circular(8));
const BorderRadius kCircularBorderRadius = BorderRadius.all(Radius.circular(100)); // For badges/avatars

// Padding & Spacing
const EdgeInsets kDefaultPadding = EdgeInsets.all(20.0);
const EdgeInsets kHorizontalPadding = EdgeInsets.symmetric(horizontal: 20.0);
const EdgeInsets kVerticalPadding = EdgeInsets.symmetric(vertical: 20.0);
const EdgeInsets kMediumPadding = EdgeInsets.all(15.0); // Added for consistency
const EdgeInsets kSmallPadding = EdgeInsets.all(10.0); // Added for consistency

const double kExtraSmallSpacing = 4.0;
const double kSmallSpacing = 8.0;
const double kMediumSpacing = 16.0;
const double kLargeSpacing = 24.0; // Adjusted for more distinct spacing
const double kExtraLargeSpacing = 32.0;

// Animation Durations
const Duration kFastAnimationDuration = Duration(milliseconds: 200);
const Duration kMediumAnimationDuration = Duration(milliseconds: 400);
const Duration kSlowAnimationDuration = Duration(milliseconds: 600);
