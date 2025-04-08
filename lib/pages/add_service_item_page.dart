import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AddServiceItemPage extends StatefulWidget {
  final int vendorId;
  const AddServiceItemPage({required this.vendorId, super.key});

  @override
  _AddServiceItemPageState createState() => _AddServiceItemPageState();
}

class _AddServiceItemPageState extends State<AddServiceItemPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _priceController = TextEditingController();
  final _descriptionController = TextEditingController();
  String? _imageUrl;
  bool _isSubmitting = false;

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      try {
        final user = Supabase.instance.client.auth.currentUser;
        if (user == null) throw Exception('User not authenticated');

        // Generate secure upload path
        final uploadPath = 'vendor_${user.id}/${DateTime.now().millisecondsSinceEpoch}.png';
        
        final storage = Supabase.instance.client.storage;
        await storage.from('shop-images').uploadBinary(
          uploadPath,
          await pickedFile.readAsBytes(),
          fileOptions: const FileOptions(contentType: 'image/png'),
        );
        setState(() {
          _imageUrl = storage.from('shop-images').getPublicUrl(uploadPath);
        });
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Image upload failed: $e')),
        );
      }
    }
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);
    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) {
        throw Exception('User not authenticated');
      }

      // Verify vendor ownership and category
      final vendor = await Supabase.instance.client
          .from('vendors')
          .select('id, category')
          .eq('id', widget.vendorId)
          .eq('user_id', user.id)
          .single();

      if (vendor['category'] != 'service') {
        throw Exception('This vendor is not a service provider');
      }

      // Insert service item
      await Supabase.instance.client.from('shop_items').insert({
        'vendor_id': widget.vendorId,
        'name': _nameController.text,
        'description': _descriptionController.text,
        'price': double.parse(_priceController.text),
        'image_url': _imageUrl, // Optional
      });

      if (context.mounted) {
        Navigator.pop(context, true);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Submission failed: ${e.toString()}')),
      );
    } finally {
      setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Service Offering')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Service Name'),
                validator: (value) => value?.isEmpty ?? true ? 'Required' : null,
              ),
              TextFormField(
                controller: _priceController,
                decoration: const InputDecoration(labelText: 'Price'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Required';
                  if (double.tryParse(value) == null) return 'Invalid number';
                  return null;
                },
              ),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: 'Description'),
              ),
              ElevatedButton(
                onPressed: _pickImage,
                child: const Text('Upload Service Image (Optional)'),
              ),
              if (_imageUrl != null)
                Image.network(
                  _imageUrl!,
                  width: 100,
                  height: 100,
                  errorBuilder: (_, __, ___) => const Icon(Icons.error),
                ),
              const SizedBox(height: 20),
              _isSubmitting
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