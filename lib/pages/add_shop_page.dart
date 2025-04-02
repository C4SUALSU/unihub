import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:io';

class AddShopPage extends StatefulWidget {
  const AddShopPage({super.key});

  @override
  _AddShopPageState createState() => _AddShopPageState();
}

class _AddShopPageState extends State<AddShopPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  String? _imageUrl;
  File? _imageFile;
  String _selectedCategory = 'food'; // Default to food
  bool _isSubmitting = false;

  // Category options
  final List<String> _categories = ['food', 'service'];

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path); // For preview
      });
    }
  }

  Future<void> _uploadImage() async {
    if (_imageFile == null) return;
    final fileName = DateTime.now().millisecondsSinceEpoch.toString();
    final storage = Supabase.instance.client.storage;
    final String filePath = await storage
        .from('vendor-images')
        .uploadBinary(fileName, await _imageFile!.readAsBytes());
    setState(() {
      _imageUrl = storage.from('vendor-images').getPublicUrl(filePath);
    });
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate() && _imageUrl != null) {
      setState(() => _isSubmitting = true);
      try {
        final user = Supabase.instance.client.auth.currentUser;
        await Supabase.instance.client.from('vendors').insert({
          'name': _nameController.text,
          'image_url': _imageUrl,
          'user_id': user!.id,
          'category': _selectedCategory, // Save category
        });
        Navigator.pop(context);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      } finally {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Shop')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Shop Name'),
                validator: (value) => value!.isEmpty ? 'Name required' : null,
              ),
              // Category selection
              DropdownButtonFormField<String>(
                value: _selectedCategory,
                items: _categories.map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value.toUpperCase()),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedCategory = value!;
                  });
                },
                decoration: const InputDecoration(labelText: 'Category'),
              ),
              // Image picker and preview
              Row(
                children: [
                  ElevatedButton(
                    onPressed: _pickImage,
                    child: const Text('Select Image'),
                  ),
                  const SizedBox(width: 10),
                  if (_imageFile != null)
                    Image.file(
                      _imageFile!,
                      width: 100,
                      height: 100,
                      fit: BoxFit.cover,
                    ),
                ],
              ),
              const SizedBox(height: 20),
              _isSubmitting
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                      onPressed: () async {
                        await _uploadImage(); // Upload before submit
                        _submitForm();
                      },
                      child: const Text('Submit'),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}