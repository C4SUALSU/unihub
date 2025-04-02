import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'chat_page.dart';
import 'add_service_page.dart'; // Add this line

class ServiceDetailPage extends StatefulWidget {
  final int serviceId;
  const ServiceDetailPage({required this.serviceId, super.key});

  @override
  _ServiceDetailPageState createState() => _ServiceDetailPageState();
}

class _ServiceDetailPageState extends State<ServiceDetailPage> {
  Map<String, dynamic>? _service;
  bool _isVendor = false;

  @override
  void initState() {
    super.initState();
    _fetchServiceDetails();
    _checkVendorStatus();
  }

  Future<void> _fetchServiceDetails() async {
    final response = await Supabase.instance.client
        .from('services')
        .select('*, vendor:vendor_id(*)')
        .eq('id', widget.serviceId)
        .single();
    setState(() => _service = response as Map<String, dynamic>);
  }

  Future<void> _checkVendorStatus() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (_service != null) {
      setState(() {
        _isVendor = _service!['vendor']['user_id'] == user!.id;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Service Details'),
        actions: [
          IconButton(
            icon: const Icon(Icons.message),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ChatPage(
                  vendorId: _service!['vendor_id'],
                  vendorName: _service!['vendor']['name'],
                ),
              ),
            ),
          ),
        ],
      ),
      body: _service == null
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Image.network(
                    _service!['image_url'] ?? 'https://via.placeholder.com/300',
                    height: 200,
                    fit: BoxFit.cover,
                  ),
                  const SizedBox(height: 16),
                  Text(_service!['name'], style: const TextStyle(fontSize: 24)),
                  Text('\$${_service!['price']}', style: const TextStyle(fontSize: 20)),
                  const SizedBox(height: 16),
                  Text(_service!['description']),
                  if (_isVendor)
                    ElevatedButton(
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AddServicePage(service: _service),
                        ),
                      ),
                      child: const Text('Edit Service'),
                    ),
                ],
              ),
            ),
    );
  }
}