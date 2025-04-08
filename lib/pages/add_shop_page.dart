import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:io';
import 'shop_detail_page.dart';

class AddShopPage extends StatefulWidget {
  final String initialCategory;
  const AddShopPage({
    this.initialCategory = 'food',
    super.key,
  });

  @override
  State<AddShopPage> createState() => _AddShopPageState();
}

class _AddShopPageState extends State<AddShopPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _contactController = TextEditingController();
  File? _imageFile;
  String _selectedCategory = 'food';
  bool _isLoading = false;
  String? _tempImagePath;
  String? _publicImagePath;

  final List<String> _categories = ['food', 'service'];

  @override
  void initState() {
    super.initState();
    _selectedCategory = widget.initialCategory;
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() => _imageFile = File(pickedFile.path));
    }
  }

  Future<void> _uploadImage() async {
    if (_imageFile == null) return;
    try {
      final user = Supabase.instance.client.auth.currentUser!;
      final fileName = '${DateTime.now().millisecondsSinceEpoch}.png';
      final tempPath = 'temp/${user.id}/$fileName';
      
      await Supabase.instance.client.storage
          .from('shop-images')
          .uploadBinary(tempPath, await _imageFile!.readAsBytes(), fileOptions: const FileOptions(
            cacheControl: '3600',
            contentType: 'image/png',
          ));
      
      setState(() {
        _tempImagePath = tempPath;
        _publicImagePath = tempPath;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Image upload failed: $e')),
      );
    }
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    try {
      final user = Supabase.instance.client.auth.currentUser!;
      await _uploadImageIfNotUploaded();

      // Create vendor record
      final response = await Supabase.instance.client.from('vendors').insert({
        'name': _nameController.text,
        'contact': _contactController.text,
        'image_path': _publicImagePath,
        'user_id': user.id,
        'category': _selectedCategory,
      }).select('id').single();

      // Move image if exists
      if (_tempImagePath != null) {
        final newImagePath = 'vendor_${user.id}/${DateTime.now().millisecondsSinceEpoch}.png';
        await Supabase.instance.client.storage
            .from('shop-images')
            .move(_tempImagePath!, newImagePath);
            
        // Update with final path
        await Supabase.instance.client.from('vendors').update({
          'image_path': newImagePath
        }).eq('id', response['id']);
      }

      if (context.mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => ShopDetailPage(vendorId: response['id']),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Submission failed: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _uploadImageIfNotUploaded() async {
    if (_tempImagePath == null && _imageFile != null) {
      await _uploadImage();
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
                validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
              ),
              TextFormField(
                controller: _contactController,
                decoration: const InputDecoration(labelText: 'Contact'),
                validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
                keyboardType: TextInputType.phone,
              ),
              DropdownButtonFormField<String>(
                value: _selectedCategory,
                items: _categories.map((c) => DropdownMenuItem(
                  value: c,
                  child: Text(c.toUpperCase()),
                )).toList(),
                onChanged: (v) => setState(() => _selectedCategory = v!),
                validator: (v) => v == null ? 'Select category' : null,
                decoration: const InputDecoration(labelText: 'Category'),
              ),
              Row(
                children: [
                  ElevatedButton(
                    onPressed: _pickImage,
                    child: const Text('Select Image (Optional)'),
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
              _isLoading
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                      onPressed: _submitForm,
                      child: const Text('Submit'),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}