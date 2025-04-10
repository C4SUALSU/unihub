import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:io';
import '../services/supabase_service.dart';

class AddEventPage extends StatefulWidget {
  const AddEventPage({super.key});

  @override
  State<AddEventPage> createState() => _AddEventPageState();
}

class _AddEventPageState extends State<AddEventPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _dateController = TextEditingController();
  final _contactController = TextEditingController();
  final _whatsappController = TextEditingController();
  final _linksController = TextEditingController();
  File? _imageFile;
  String? _tempImagePath;
  String? _publicImagePath;
  bool _isLoading = false;

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
      final tempPath = 'temp/events/${user.id}/$fileName';
      
      await Supabase.instance.client.storage
          .from('event-images')
          .uploadBinary(tempPath, await _imageFile!.readAsBytes(), fileOptions: const FileOptions(
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

      // Create event record
      final response = await Supabase.instance.client.from('events').insert({
        'title': _titleController.text,
        'date': DateTime.parse(_dateController.text).toIso8601String(),
        'contact_info': _contactController.text,
        'whatsapp_number': _whatsappController.text,
        'links': _linksController.text.split(',').map((e) => e.trim()).toList(),
        'image_url': _publicImagePath,
        'user_id': user.id,
      }).select('id').single();

      // Move image if exists
      if (_tempImagePath != null) {
        final newImagePath = 'events/${user.id}/${DateTime.now().millisecondsSinceEpoch}.png';
        await Supabase.instance.client.storage
            .from('event-images')
            .move(_tempImagePath!, newImagePath);
            
        // Update with final path
        await Supabase.instance.client.from('events').update({
          'image_url': newImagePath
        }).eq('id', response['id']);
      }

      if (context.mounted) {
        Navigator.pop(context);
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
      appBar: AppBar(title: const Text('Add Event')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Event Title'),
                validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
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
                    _dateController.text = date.toString().split(' ')[0];
                  }
                },
                validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
              ),
              TextFormField(
                controller: _contactController,
                decoration: const InputDecoration(labelText: 'Contact Info'),
                validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
              ),
              TextFormField(
                controller: _whatsappController,
                decoration: const InputDecoration(labelText: 'WhatsApp Number'),
              ),
              TextFormField(
                controller: _linksController,
                decoration: const InputDecoration(labelText: 'Links (comma-separated)'),
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