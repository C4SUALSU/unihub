import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/supabase_service.dart';

class AddEventPage extends StatefulWidget {
  const AddEventPage({super.key});

  @override
  _AddEventPageState createState() => _AddEventPageState();
}

class _AddEventPageState extends State<AddEventPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _dateController = TextEditingController();
  final _contactController = TextEditingController();
  final _whatsappController = TextEditingController();
  final _linksController = TextEditingController();
  String? _imageUrl;

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      final fileName = DateTime.now().millisecondsSinceEpoch.toString();
      final storage = Supabase.instance.client.storage;
      final String filePath = await storage
          .from('event-images')
          .uploadBinary(fileName, await pickedFile.readAsBytes());
      setState(() {
        _imageUrl = storage.from('event-images').getPublicUrl(filePath);
      });
    }
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate() && _imageUrl != null) {
      final user = Supabase.instance.client.auth.currentUser;
      final supabaseService = SupabaseService();
      
      await supabaseService.addEvent(
        title: _titleController.text,
        date: DateTime.parse(_dateController.text),
        contactInfo: _contactController.text,
        whatsappNumber: _whatsappController.text,
        links: _linksController.text.split(','),
        imageUrl: _imageUrl!,
        userId: user!.id, // Set user_id for RLS policy
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Event')),
      body: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Event Title'),
                validator: (value) => value!.isEmpty ? 'Title is required' : null,
              ),
              TextFormField(
                controller: _dateController,
                decoration: const InputDecoration(labelText: 'Date (YYYY-MM-DD)'),
                onTap: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime.now(),
                    lastDate: DateTime(2100),
                  );
                  if (date != null) {
                    _dateController.text = date.toIso8601String().split('T')[0];
                  }
                },
                validator: (value) => value!.isEmpty ? 'Date is required' : null,
              ),
              TextFormField(
                controller: _contactController,
                decoration: const InputDecoration(labelText: 'Contact Info'),
                validator: (value) => value!.isEmpty ? 'Contact info required' : null,
              ),
              TextFormField(
                controller: _whatsappController,
                decoration: const InputDecoration(labelText: 'WhatsApp Number'),
              ),
              TextFormField(
                controller: _linksController,
                decoration: const InputDecoration(labelText: 'Links (comma-separated)'),
              ),
              ElevatedButton(
                onPressed: _pickImage,
                child: const Text('Upload Image'),
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