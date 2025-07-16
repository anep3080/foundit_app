import 'package:flutter/material.dart';

// Colors
// Using a very light grey as the primary background for optimal Neumorphism effect
const Color kBackground = Color(0xFFF0F0F0); 
const Color kPrimaryBlack = Colors.black; // Primary text color, dark elements
const Color kPrimaryWhite = Colors.white; // White text/elements, light backgrounds
const Color kPrimaryYellow = Color(0xFFFFD700); // Vibrant yellow for accents, warnings
const Color kPrimaryGreen = Color(0xFF4CAF50); // Standard green for success, positive actions

// Semantic Colors (keeping these for clear meaning, but adjusting if needed)
const Color kRedError = Color(0xFFDC3545); // Error messages, destructive actions
const Color kBlueInfo = Color(0xFF007BFF); // Info messages, general links
const Color kGrey = Color(0xFF6C757D); // Secondary text, borders
const Color kLightGrey = Color(0xFFE9ECEF); // Placeholder backgrounds, disabled states

// Neumorphism Box Shadows
// For 'embossed' effect (button appearing to pop out)
const BoxShadow kNeumorphicShadowDark = BoxShadow(
  color: Color(0xFFA3B1C6), // Darker shadow, often a slightly desaturated version of background
  offset: Offset(5, 5),
  blurRadius: 10,
);

const BoxShadow kNeumorphicShadowLight = BoxShadow(
  color: Color(0xFFFFFFFF), // Lighter shadow, often pure white
  offset: Offset(-5, -5),
  blurRadius: 10,
);

// For 'debossed' effect (button appearing to press in)
// Removed 'inset: true' to resolve compilation error on older Flutter versions
// Note: This means these will behave as regular outer shadows, not true inner shadows.
const BoxShadow kNeumorphicInnerShadowDark = BoxShadow(
  color: Color(0xFFA3B1C6),
  offset: Offset(2, 2),
  blurRadius: 5,
  // inset: true, // Removed
);

const BoxShadow kNeumorphicInnerShadowLight = BoxShadow(
  color: Color(0xFFFFFFFF),
  offset: Offset(-2, -2),
  blurRadius: 5,
  // inset: true, // Removed
);

// Text Styles (using Poppins from google_fonts, assuming it's set in main.dart theme)
// These provide a consistent typographic scale
const TextStyle kDisplayLarge = TextStyle(
  fontSize: 36,
  fontWeight: FontWeight.bold,
  color: kPrimaryBlack, // Changed to primary black
);

const TextStyle kHeadlineMedium = TextStyle(
  fontSize: 28,
  fontWeight: FontWeight.bold,
  color: kPrimaryBlack, // Changed to primary black
);

const TextStyle kTitleLarge = TextStyle(
  fontSize: 22,
  fontWeight: FontWeight.w600,
  color: kPrimaryBlack, // Changed to primary black
);

const TextStyle kBodyLarge = TextStyle(
  fontSize: 16,
  color: kPrimaryBlack, // Changed to primary black
);

const TextStyle kBodyMedium = TextStyle(
  fontSize: 14,
  color: kGrey, // Secondary text remains grey
);

const TextStyle kLabelSmall = TextStyle(
  fontSize: 12,
  color: kGrey, // Label text remains grey
);

// Box Shadows (keeping these for general use, distinct from Neumorphism)
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
const EdgeInsets kMediumPadding = EdgeInsets.all(15.0);
const EdgeInsets kSmallPadding = EdgeInsets.all(10.0);

const double kExtraSmallSpacing = 4.0;
const double kSmallSpacing = 8.0;
const double kMediumSpacing = 16.0;
const double kLargeSpacing = 24.0;
const double kExtraLargeSpacing = 32.0;
