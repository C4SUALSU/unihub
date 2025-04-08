import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'add_shop_page.dart'; // Reusing add shop page
import 'service_detail_page.dart';

class ServicesPage extends StatefulWidget {
  final bool isVendor;
  const ServicesPage({this.isVendor = false, super.key});

  @override
  _ServicesPageState createState() => _ServicesPageState();
}

class _ServicesPageState extends State<ServicesPage> {
  List<dynamic> _services = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchServices();
  }

  Future<void> _fetchServices() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final response = await Supabase.instance.client
          .from('vendors')
          .select('id, name, image_path, user_id, category, created_at')
          .eq('category', 'service')
          .order('created_at', ascending: false);

      setState(() {
        _services = response as List<dynamic>;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Error loading services: ${e.toString()}';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Service Providers'),
        actions: [
          if (widget.isVendor)
            IconButton(
              icon: const Icon(Icons.add_business),
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => AddShopPage(initialCategory: 'service'), // Reuse with service category
                ),
              ).then((_) => _fetchServices()),
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(_errorMessage!),
                      TextButton(
                        onPressed: _fetchServices,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : _services.isEmpty
                  ? const Center(child: Text('No service providers found'))
                  : GridView.builder(
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 0.8,
                      ),
                      itemCount: _services.length,
                      itemBuilder: (context, index) {
                        final service = _services[index];
                        return Card(
                          child: InkWell(
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    ServiceDetailPage(vendorId: service['id']),
                              ),
                            ),
                            child: Column(
                              children: [
                                Expanded(
                                  child: Image.network(
                                    Supabase.instance.client.storage
                                        .from('shop-images')
                                        .getPublicUrl(service['image_path']),
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) =>
                                        const Icon(Icons.error),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(
                                    service['name'],
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
    );
  }
}