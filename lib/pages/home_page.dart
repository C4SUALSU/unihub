import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'events_page.dart';
import 'food_vendors_page.dart';
import 'services_page.dart';
import 'messages_page.dart';
import 'profile_page.dart'; // Import the new ProfilePage
import '../services/auth_service.dart';
import '../pages/login_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  bool _isAdmin = false;
  bool _isVendor = false;

  @override
  void initState() {
    super.initState();
    _checkUserRole();
  }

  Future<void> _checkUserRole() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user != null) {
      try {
        final response = await Supabase.instance.client
            .from('profiles')
            .select('role')
            .eq('id', user.id)
            .single();
        final role = response['role'] as String?;
        setState(() {
          _isAdmin = role?.toLowerCase() == 'admin';
          _isVendor = role?.toLowerCase() == 'vendor';
        });
      } catch (e) {
        setState(() {
          _isAdmin = false;
          _isVendor = false;
        });
      }
    }
  }

  List<Widget> get _pages => [
        EventsPage(isAdmin: _isAdmin),
        FoodVendorsPage(isVendor: _isVendor),
        const ServicesPage(),
        const MessagesPage(),
        ProfilePage(), // Add the ProfilePage here
      ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('UNIHUB (${_isAdmin ? 'Admin' : _isVendor ? 'Vendor' : 'User'})'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await AuthService().signOut();
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const LoginPage()),
              );
            },
          ),
        ],
      ),
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.event), label: 'Events'),
          BottomNavigationBarItem(icon: Icon(Icons.food_bank), label: 'Food'),
          BottomNavigationBarItem(icon: Icon(Icons.room_service), label: 'Services'),
          BottomNavigationBarItem(icon: Icon(Icons.message), label: 'Messages'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'), // Profile icon
        ],
      ),
    );
  }
}