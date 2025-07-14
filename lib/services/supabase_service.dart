import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/foundation.dart'; // For kDebugMode

class SupabaseService {
  late final SupabaseClient client;

  // Initialize Supabase client with your project URL and Anon Key
  // IMPORTANT: Replace 'YOUR_SUPABASE_URL' and 'YOUR_SUPABASE_ANON_KEY'
  // In a real app, these should be loaded from environment variables for security.
  SupabaseService() {
    client = Supabase.instance.client;
  }

  // --- Authentication Methods ---

  /// Signs up a new user with email and password.
  /// Optionally, inserts additional user data into a 'profiles' table.
  Future<AuthResponse> signUp({
    required String email,
    required String password,
    String? fullName,
    String? phoneNumber,
    String? city,
    String? country,
    String? telegramUsername,
    String? gender,
    String userType = 'user', // Default user type
  }) async {
    try {
      final AuthResponse response = await client.auth.signUp(
        email: email,
        password: password,
        data: {
          // You can pass additional data here, but it's often better
          // to insert into a separate 'profiles' table after successful signup.
        },
      );

      if (response.user != null) {
        // If signup is successful, insert profile data into the 'profiles' table
        await client.from('profiles').insert({
          'id': response.user!.id, // Link to auth.users table
          'full_name': fullName,
          'email': email,
          'phone_number': phoneNumber,
          'city': city,
          'country': country,
          'telegram_username': telegramUsername,
          'gender': gender,
          'user_type': userType,
        });
      }
      return response;
    } on AuthException catch (e) {
      debugPrint('Supabase Sign Up Error: ${e.message}');
      rethrow; // Re-throw to be caught by the UI layer
    } catch (e) {
      debugPrint('General Sign Up Error: $e');
      rethrow;
    }
  }

  /// Signs in an existing user with email and password.
  Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final AuthResponse response = await client.auth.signInWithPassword(
        email: email,
        password: password,
      );
      return response;
    } on AuthException catch (e) {
      debugPrint('Supabase Sign In Error: ${e.message}');
      rethrow;
    } catch (e) {
      debugPrint('General Sign In Error: $e');
      rethrow;
    }
  }

  /// Signs out the current user.
  Future<void> signOut() async {
    try {
      await client.auth.signOut();
    } on AuthException catch (e) {
      debugPrint('Supabase Sign Out Error: ${e.message}');
      rethrow;
    } catch (e) {
      debugPrint('General Sign Out Error: $e');
      rethrow;
    }
  }

  /// Gets the current user session.
  Session? get currentSession => client.auth.currentSession;

  /// Gets the current authenticated user.
  User? get currentUser => client.auth.currentUser;

  /// Stream of authentication state changes.
  Stream<AuthState> get authStateChanges => client.auth.onAuthStateChange;
}

// Global instance for easy access
final supabaseService = SupabaseService();
