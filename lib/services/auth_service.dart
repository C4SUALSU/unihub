import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  final SupabaseClient _supabase = Supabase.instance.client;

  // Sign in with email/password
  Future<void> signIn(String email, String password) async {
    try {
      await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      throw 'Login failed: ${e.toString()}';
    }
  }

  // Sign up with email/password
  Future<void> signUp(String email, String password) async {
    try {
      await _supabase.auth.signUp(
        email: email,
        password: password,
        // Optional: Add user metadata
        data: {'username': email.split('@')[0]},
      );
    } catch (e) {
      throw 'Signup failed: ${e.toString()}';
    }
  }

  // Check if user is logged in
  bool isLoggedIn() {
    return _supabase.auth.currentUser != null;
  }

  // Logout
  Future<void> signOut() async {
    await _supabase.auth.signOut();
  }
}