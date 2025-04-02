import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AddServicePage extends StatefulWidget {
  final Map<String, dynamic>? service;
  const AddServicePage({this.service, super.key});

  @override
  _AddServicePageState createState() => _AddServicePageState();
}

class _AddServicePageState extends State<AddServicePage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _priceController = TextEditingController();
  final _descriptionController = TextEditingController();
  String? _imageUrl;

  @override
  void initState() {
    super.initState();
    if (widget.service != null) {
      _nameController.text = widget.service!['name'];
      _priceController.text = widget.service!['price'].toString();
      _descriptionController.text = widget.service!['description'];
      _imageUrl = widget.service!['image_url'];
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      final fileName = DateTime.now().millisecondsSinceEpoch.toString();
      final storage = Supabase.instance.client.storage;
      final String filePath = await storage
          .from('service-images')
          .uploadBinary(fileName, await pickedFile.readAsBytes());
      setState(() {
        _imageUrl = storage.from('service-images').getPublicUrl(filePath);
      });
    }
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate() && _imageUrl != null) {
      final user = Supabase.instance.client.auth.currentUser;
      final vendor = await Supabase.instance.client
          .from('vendors')
          .select('id')
          .eq('user_id', user!.id)
          .single();

      final data = {
        'vendor_id': vendor['id'],
        'name': _nameController.text,
        'description': _descriptionController.text,
        'price': double.parse(_priceController.text),
        'image_url': _imageUrl,
      };

      if (widget.service != null) {
        await Supabase.instance.client
            .from('services')
            .update(data)
            .eq('id', widget.service!['id']);
      } else {
        await Supabase.instance.client.from('services').insert(data);
      }
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.service == null ? 'Add Service' : 'Edit Service')),
      body: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Service Name'),
                validator: (value) => value!.isEmpty ? 'Name required' : null,
              ),
              TextFormField(
                controller: _priceController,
                decoration: const InputDecoration(labelText: 'Price'),
                keyboardType: TextInputType.number,
                validator: (value) => value!.isEmpty ? 'Price required' : null,
              ),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: 'Description'),
              ),
              ElevatedButton(
                onPressed: _pickImage,
                child: const Text('Upload Service Image'),
              ),
              ElevatedButton(
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