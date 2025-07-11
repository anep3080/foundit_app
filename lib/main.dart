import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:foundit_testing/screens/login.dart'; // Import your screens
import 'package:foundit_testing/screens/signup.dart';
import 'package:foundit_testing/screens/homepage_screen.dart';
import 'package:foundit_testing/screens/profile.dart';
import 'package:foundit_testing/screens/report_lost_form.dart';
import 'package:foundit_testing/screens/report_found_form.dart';
import 'package:foundit_testing/screens/lost_item_view.dart';
import 'package:foundit_testing/screens/found_item_view.dart';
import 'package:foundit_testing/screens/admin_homepage.dart';
import 'package:foundit_testing/screens/admin_edit_user.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FoundIt App UI',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.yellow, // A base color
        textTheme: GoogleFonts.poppinsTextTheme(Theme.of(context).textTheme),
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const LoginScreen(), // Start with the Login Screen
      // You can define routes here for navigation
      routes: {
        '/login': (context) => const LoginScreen(),
        '/signup': (context) => const SignupScreen(),
        '/homepage': (context) => const HomepageScreen(),
        '/profile': (context) => const ProfileScreen(),
        '/report_lost': (context) => const ReportLostFormScreen(),
        '/report_found': (context) => const ReportFoundFormScreen(),
        '/lost_item_view': (context) => const LostItemViewScreen(itemId: '123'), // Pass dummy ID
        '/found_item_view': (context) => const FoundItemViewScreen(itemId: '456'), // Pass dummy ID
        '/admin_homepage': (context) => const AdminHomepageScreen(),
        '/admin_edit_user': (context) => const AdminEditUserScreen(userId: '789'), // Pass dummy ID
      },
    );
  }
}