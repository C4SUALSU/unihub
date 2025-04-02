// lib/main.dart
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'pages/login_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    url: 'https://dqlsaerrnlndveipqfip.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImRxbHNhZXJybmxuZHZlaXBxZmlwIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDMzNDUxMzksImV4cCI6MjA1ODkyMTEzOX0.E_Z4Kwjeb0J0B1eo59hAokK4Xcy-SQB9MYk2l2w7cK4',
  );

  await Supabase.instance.client.auth.signOut();
  
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: LoginPage(), // Your login page
      // Add routes for other pages if needed
    );
  }
}