import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// Screens
import 'screens/auth_screen.dart';
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

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Supabase
  // IMPORTANT: Replace with your actual Supabase URL and Anon Key
  // You can find these in your Supabase project settings -> API
  await Supabase.initialize(
    url: 'https://eplxlegdqzdgorgoaekf.supabase.co', // Replace with your actual Supabase URL
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImVwbHhsZWdkcXpkZ29yZ29hZWtmIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTE3NzA1MDUsImV4cCI6MjA2NzM0NjUwNX0.gP_6gy6A3jiBj-X0WZ0jncZLyA_TrMzXvoBdk3yhpFM', // Replace with your actual Supabase Anon Key
    debug: true, // Set to false in production
  );

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FoundIt App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.red, // Using a primary swatch for consistency
        visualDensity: VisualDensity.adaptivePlatformDensity,
        textTheme: GoogleFonts.poppinsTextTheme( // Apply Poppins to the entire app
          Theme.of(context).textTheme,
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: kDarkRed, // Consistent AppBar background
          foregroundColor: kWhite, // Consistent AppBar text/icon color
          titleTextStyle: GoogleFonts.poppins(
            color: kWhite,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        cardTheme: CardThemeData( // Corrected: Use CardThemeData
          elevation: 3,
          shape: RoundedRectangleBorder(borderRadius: kDefaultBorderRadius),
          color: kLightYellow,
          margin: EdgeInsets.zero, // Cards will handle their own margins
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: kDarkRed,
            foregroundColor: kWhite,
            textStyle: kLabelLarge,
            shape: RoundedRectangleBorder(borderRadius: kSmallBorderRadius),
            padding: const EdgeInsets.symmetric(horizontal: kLargeSpacing, vertical: kMediumSpacing),
            elevation: 5,
          ),
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: kDarkRed,
            textStyle: kLabelMedium,
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
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
          hintStyle: GoogleFonts.poppins(color: kGrey),
          contentPadding: const EdgeInsets.symmetric(horizontal: kMediumSpacing, vertical: kMediumSpacing),
        ),
      ),
      home: StreamBuilder<AuthState>(
        stream: supabaseService.authStateChanges,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              backgroundColor: kPrimaryYellowGreen,
              body: Center(
                child: CircularProgressIndicator(color: kDarkRed),
              ),
            );
          } else if (snapshot.hasData && snapshot.data!.event == AuthChangeEvent.signedIn) {
            return const HomepageScreen();
          } else {
            return const AuthScreen();
          }
        },
      ),
      routes: {
        '/auth': (context) => const AuthScreen(),
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
