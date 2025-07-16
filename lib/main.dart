import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// Screens
import 'screens/login.dart'; // Import LoginScreen
import 'screens/signup.dart'; // Import SignupScreen
import 'screens/auth_screen.dart'; // Keep this import if AuthScreen is still used for initial routing or other purposes
import 'screens/homepage_screen.dart';
import 'screens/profile.dart';
import 'screens/report_lost_form.dart';
import 'screens/report_found_form.dart';
import 'screens/lost_item_view.dart';
import 'screens/found_item_view.dart';
import 'screens/all_lost_items_screen.dart';
import 'screens/all_found_items_screen.dart';
import 'screens/admin_homepage.dart';
import 'screens/admin_edit_user.dart';
import 'screens/user_dashboard_screen.dart'; // NEW: Import UserDashboardScreen

// Services
import 'services/supabase_service.dart';

// UI Constants
import 'ui_constants.dart';

// Initialize SupabaseService globally
final supabaseService = SupabaseService();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Supabase
  // IMPORTANT: Replace with your actual Supabase URL and Anon Key
  // You can find these in your Supabase project settings -> API
  await Supabase.initialize(
    url: 'https://eplxlegdqzdgorgoaekf.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImVwbHhsZWdkcXpkZ29yZ29hZWtmIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTE3NzA1MDUsImV4cCI6MjA2NzM0NjUwNX0.gP_6gy6A3jiBj-X0WZ0jncZLyA_TrMzXvoBdk3yhpFM', // Replace with your actual Supabase Anon Key
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FoundIt App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        // Use the new kBackground as the scaffold background color
        scaffoldBackgroundColor: kBackground,
        // Define a consistent color scheme based on the new palette
        colorScheme: ColorScheme.light(
          primary: kPrimaryBlack, // Primary color for app bar, etc.
          onPrimary: kPrimaryWhite, // Text/icons on primary color
          secondary: kPrimaryYellow, // Accent color
          onSecondary: kPrimaryBlack, // Text/icons on secondary color
          surface: kBackground, // Card/surface color
          onSurface: kPrimaryBlack, // Text/icons on surface
          background: kBackground, // General background
          onBackground: kPrimaryBlack, // Text/icons on background
          error: kRedError, // Error color
          onError: kPrimaryWhite, // Text/icons on error color
        ),
        // Define text theme using GoogleFonts.poppins and new colors
        textTheme: TextTheme(
          displayLarge: GoogleFonts.poppins(
            fontSize: 36,
            fontWeight: FontWeight.bold,
            color: kPrimaryBlack,
          ),
          headlineMedium: GoogleFonts.poppins(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: kPrimaryBlack,
          ),
          titleLarge: GoogleFonts.poppins(
            fontSize: 22,
            fontWeight: FontWeight.w600,
            color: kPrimaryBlack,
          ),
          bodyLarge: GoogleFonts.poppins(
            fontSize: 16,
            color: kPrimaryBlack,
          ),
          bodyMedium: GoogleFonts.poppins(
            fontSize: 14,
            color: kGrey,
          ),
          labelSmall: GoogleFonts.poppins(
            fontSize: 12,
            color: kGrey,
          ),
          // Ensure other text styles are defined or use defaults
        ),
        // Define input decoration theme for consistent text field styling
        inputDecorationTheme: InputDecorationTheme(
          labelStyle: GoogleFonts.poppins(color: kGrey),
          hintStyle: GoogleFonts.poppins(color: kGrey),
          prefixIconColor: kGrey,
          suffixIconColor: kGrey,
          fillColor: kBackground,
          filled: true,
          enabledBorder: OutlineInputBorder(
            borderRadius: kSmallBorderRadius,
            borderSide: BorderSide.none, // No border for Neumorphism
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: kSmallBorderRadius,
            borderSide: BorderSide(color: kPrimaryYellow, width: 2),
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
        ),
        // Button themes (optional, as most buttons are custom Neumorphic)
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: kPrimaryYellow, // Default text button color
            textStyle: GoogleFonts.poppins(fontWeight: FontWeight.w500),
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: kPrimaryBlack, // Default elevated button color
            foregroundColor: kPrimaryWhite,
            shape: RoundedRectangleBorder(borderRadius: kSmallBorderRadius),
            textStyle: GoogleFonts.poppins(fontWeight: FontWeight.bold),
            padding: kMediumPadding,
          ),
        ),
      ),
      initialRoute: '/auth', // Set initial route to AuthScreen
      routes: {
        '/auth': (context) => const AuthScreen(),
        '/login': (context) => const LoginScreen(),
        '/signup': (context) => const SignupScreen(),
        '/homepage': (context) => const HomepageScreen(),
        '/profile': (context) => const ProfileScreen(),
        '/report_lost': (context) => const ReportLostFormScreen(),
        '/report_found': (context) => const ReportFoundFormScreen(),
        '/lost_item_view': (context) {
          final dynamic args = ModalRoute.of(context)?.settings.arguments;
          // Explicitly check if args is a non-empty String
          if (args is String && args.isNotEmpty) {
            return LostItemViewScreen(itemId: args);
          }
          // Fallback if arguments are missing or not of expected type
          return const Scaffold(
            body: Center(
              child: Text('Error: Lost Item ID is missing or invalid.'),
            ),
          );
        },
        '/found_item_view': (context) {
          final dynamic args = ModalRoute.of(context)?.settings.arguments;
          // Explicitly check if args is a non-empty String
          if (args is String && args.isNotEmpty) {
            return FoundItemViewScreen(itemId: args);
          }
          // Fallback if arguments are missing or not of expected type
          return const Scaffold(
            body: Center(
              child: Text('Error: Found Item ID is missing or invalid.'),
            ),
          );
        },
        '/all_lost_items': (context) => const AllLostItemsScreen(),
        '/all_found_items': (context) => const AllFoundItemsScreen(),
        '/admin_homepage': (context) => const AdminHomepageScreen(),
        '/admin_edit_user': (context) {
          final args = ModalRoute.of(context)?.settings.arguments as String?;
          return AdminEditUserScreen(userId: args!);
        },
        '/user_dashboard': (context) => const UserDashboardScreen(),
      },
    );
  }
}
