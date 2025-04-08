import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'add_service_item_page.dart'; // Create this page for adding service items
import 'chat_page.dart';

class ServiceDetailPage extends StatefulWidget {
  final int vendorId;
  const ServiceDetailPage({required this.vendorId, super.key});

  @override
  _ServiceDetailPageState createState() => _ServiceDetailPageState();
}

class _ServiceDetailPageState extends State<ServiceDetailPage> {
  Map<String, dynamic>? _vendor;
  List<dynamic> _services = [];
  bool _isVendorService = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    setState(() => _isLoading = true);
    try {
      // Fetch vendor details
      final vendorResponse = await Supabase.instance.client
          .from('vendors')
          .select('id, name, image_path, user_id, category')
          .eq('id', widget.vendorId)
          .single();
      
      // Fetch services (items from shop_items)
      final servicesResponse = await Supabase.instance.client
          .from('shop_items')
          .select('id, name, price, description, image_url')
          .eq('vendor_id', widget.vendorId);

      // Check ownership
      final user = Supabase.instance.client.auth.currentUser;
      final isVendor = user?.id == vendorResponse['user_id'];

      setState(() {
        _vendor = vendorResponse;
        _services = servicesResponse as List<dynamic>;
        _isVendorService = isVendor;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading service: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_vendor?['name'] ?? 'Service Details'),
        actions: [
          if (_isVendorService)
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: () => Navigator.push<bool>(
                context,
                MaterialPageRoute(
                  builder: (context) => AddServiceItemPage(vendorId: widget.vendorId),
                ),
              ).then((shouldRefresh) {
                if (shouldRefresh == true) _fetchData();
              }),
            ),
          IconButton(
            icon: const Icon(Icons.message),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ChatPage(vendorId: widget.vendorId),
              ),
            ),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _vendor == null
              ? const Center(child: Text('Service provider not found'))
              : Column(
                  children: [
                    // Service Provider Header
                    Container(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          Image.network(
                            Supabase.instance.client.storage
                                .from('shop-images')
                                .getPublicUrl(_vendor!['image_path']),
                            width: 120,
                            height: 120,
                            errorBuilder: (_, __, ___) => const Icon(Icons.error),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _vendor!['name'],
                            style: const TextStyle(fontSize: 20),
                          ),
                          Text(
                            'Category: ${_vendor!['category'].toUpperCase()}',
                            style: const TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: GridView.builder(
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 0.7,
                        ),
                        itemCount: _services.length,
                        itemBuilder: (context, index) {
                          final service = _services[index];
                          return Card(
                            child: Column(
                              children: [
                                Expanded(
                                  child: Image.network(
                                    service['image_url'] ?? 
                                    'https://via.placeholder.com/150',
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) => 
                                        const Icon(Icons.error),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(service['name'], 
                                        style: const TextStyle(fontSize: 16)),
                                      Text('\$${service['price']}',
                                        style: const TextStyle(fontSize: 18)),
                                      Text(service['description'] ?? '',
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
    );
  }
}