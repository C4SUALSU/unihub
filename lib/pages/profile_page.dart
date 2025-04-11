import 'dart:io'; // Add this line to import the File class
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _formKey = GlobalKey<FormState>();
  late String _firstName;
  late String _lastName;
  String? _profilePhotoUrl;
  String? _userRole;
  String? _userShop;
  String? _userEvent;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user != null) {
      try {
        final response = await Supabase.instance.client
            .from('profiles')
            .select('*')
            .eq('id', user.id)
            .single();
        setState(() {
          _firstName = response['first_name'] ?? '';
          _lastName = response['last_name'] ?? '';
          _profilePhotoUrl = response['profile_photo_url'];
          _userRole = response['role'];
          _userShop = response['shop']; // Assuming 'shop' is a column in the profiles table
          _userEvent = response['event']; // Assuming 'event' is a column in the profiles table
        });
      } catch (e) {
        print('Error loading user data: $e');
      }
    }
  }

  Future<void> _updateUserData() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user != null) {
      try {
        await Supabase.instance.client.from('profiles').update({
          'first_name': _firstName,
          'last_name': _lastName,
          'profile_photo_url': _profilePhotoUrl,
        }).eq('id', user.id);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Profile updated successfully')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update profile: $e')),
        );
      }
    }
  }

  Future<void> _pickProfilePhoto() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      // For simplicity, store the local file path as the profile photo URL
      setState(() {
        _profilePhotoUrl = pickedFile.path;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Profile Photo
              Center(
                child: GestureDetector(
                  onTap: _pickProfilePhoto,
                  child: CircleAvatar(
                    radius: 50,
                    backgroundImage: _profilePhotoUrl != null
                        ? FileImage(File(_profilePhotoUrl!)) // Fixed by importing dart:io
                        : AssetImage('assets/images/default_profile.png') as ImageProvider,
                  ),
                ),
              ),
              SizedBox(height: 20),

              // First Name
              TextFormField(
                initialValue: _firstName,
                decoration: InputDecoration(labelText: 'First Name'),
                onChanged: (value) => _firstName = value,
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please enter your first name';
                  }
                  return null;
                },
              ),

              // Last Name
              TextFormField(
                initialValue: _lastName,
                decoration: InputDecoration(labelText: 'Last Name'),
                onChanged: (value) => _lastName = value,
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please enter your last name';
                  }
                  return null;
                },
              ),

              // User Role
              Text('User Role: $_userRole'),

              // User Shop (if applicable)
              if (_userShop != null)
                Text('User Shop: $_userShop'),

              // User Event (if applicable)
              if (_userEvent != null)
                Text('User Event: $_userEvent'),

              SizedBox(height: 20),

              // Save Button
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    _updateUserData();
                  }
                },
                child: Text('Save Changes'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}