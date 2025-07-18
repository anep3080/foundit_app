import 'package:flutter/material.dart';

// ===========================================
// Colors
// ===========================================
const Color kPrimaryYellow = Color(0xFFFDC700); // A vibrant yellow for primary actions
const Color kPrimaryBlack = Color(0xFF1A1A1A); // Dark charcoal for primary text/backgrounds
const Color kPrimaryWhite = Color(0xFFFFFFFF); // Pure white
const Color kBackground = Color(0xFFE0E0E0); // Light grey for neumorphic background

// New/Corrected Color Definitions
const Color kBlack = Colors.black; // Direct black color
const Color kWhite = Colors.white; // Direct white color
const Color kCardColor = Color(0xFFEBEBEB); // Slightly lighter than background for cards
const Color kPrimaryTextColor = Color(0xFF1A1A1A); // Default text color
const Color kSecondaryTextColor = Color(0xFF6B6B6B); // Medium grey for secondary text
const Color kAccentColor = Color(0xFF007BFF); // A strong blue for accents/links

const Color kPrimaryGreen = Color(0xFF4CAF50); // Standard green for success, positive actions
const Color kGreenSuccess = Color(0xFF28A745); // Green for success messages
const Color kRedError = Color(0xFFDC3545); // Red for error messages
const Color kBlueInfo = Color(0xFF17A2B8); // Blue for informational messages
const Color kGrey = Color(0xFF808080); // General grey
const Color kLightGrey = Color(0xFFF2F2F2); // Very light grey
const Color kDarkGrey = Color(0xFF343A40); // Darker grey for some elements
const Color kDarkYellow = Color(0xFFCC9900); // Darker yellow for status indicators
const Color kLightBlack = Color(0xFF424242); // Slightly lighter black for rejected status

// ===========================================
// Spacing & Padding
// ===========================================
const double kExtraSmallSpacing = 4.0;
const double kSmallSpacing = 8.0;
const double kMediumSpacing = 16.0;
const double kLargeSpacing = 24.0;
const double kExtraLargeSpacing = 32.0;

const EdgeInsets kSmallPadding = EdgeInsets.all(kSmallSpacing);
const EdgeInsets kMediumPadding = EdgeInsets.all(kMediumSpacing);
const EdgeInsets kDefaultPadding = EdgeInsets.all(kLargeSpacing);
const EdgeInsets kHorizontalPadding = EdgeInsets.symmetric(horizontal: 20.0);
const EdgeInsets kVerticalPadding = EdgeInsets.symmetric(vertical: 20.0);


// ===========================================
// Border Radii
// ===========================================
const BorderRadius kSmallBorderRadius = BorderRadius.all(Radius.circular(8.0));
const BorderRadius kDefaultBorderRadius = BorderRadius.all(Radius.circular(12.0));
const BorderRadius kLargeBorderRadius = BorderRadius.all(Radius.circular(16.0));
const BorderRadius kCircularBorderRadius = BorderRadius.all(Radius.circular(100.0)); // For circular elements

// ===========================================
// Box Shadows (for Neumorphism)
// ===========================================
const BoxShadow kNeumorphicShadowDark = BoxShadow(
  color: Color(0xFFA3B1C6), // Darker shadow color
  offset: Offset(6, 6),
  blurRadius: 10,
  spreadRadius: 1,
);

const BoxShadow kNeumorphicShadowLight = BoxShadow(
  color: Color(0xFFFFFFFF), // Lighter shadow color
  offset: Offset(-6, -6),
  blurRadius: 10,
  spreadRadius: 1,
);

const BoxShadow kNeumorphicInnerShadowDark = BoxShadow(
  color: Color(0xFFA3B1C6),
  offset: Offset(2, 2),
  blurRadius: 5,
);

const BoxShadow kNeumorphicInnerShadowLight = BoxShadow(
  color: Color(0xFFFFFFFF),
  offset: Offset(-2, -2),
  blurRadius: 5,
);

// ===========================================
// Animation Durations
// ===========================================
const Duration kSmallAnimationDuration = Duration(milliseconds: 200);
const Duration kMediumAnimationDuration = Duration(milliseconds: 400);
const Duration kLargeAnimationDuration = Duration(milliseconds: 600);

// ===========================================
// Text Styles (Example - can be expanded)
// ===========================================
const TextStyle kDisplayLarge = TextStyle(
  fontSize: 36,
  fontWeight: FontWeight.bold,
  color: kPrimaryBlack,
);

const TextStyle kHeadlineMedium = TextStyle(
  fontSize: 28,
  fontWeight: FontWeight.bold,
  color: kPrimaryBlack,
);

const TextStyle kTitleLarge = TextStyle(
  fontSize: 22,
  fontWeight: FontWeight.w600,
  color: kPrimaryBlack,
);

const TextStyle kBodyLarge = TextStyle(
  fontSize: 16,
  color: kPrimaryBlack,
);

const TextStyle kBodyMedium = TextStyle(
  fontSize: 14,
  color: kGrey,
);

const TextStyle kLabelSmall = TextStyle(
  fontSize: 12,
  color: kGrey,
);
