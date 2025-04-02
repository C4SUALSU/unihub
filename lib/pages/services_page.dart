import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'add_service_page.dart';
import 'service_detail_page.dart';

class ServicesPage extends StatefulWidget {
  const ServicesPage({super.key});

  @override
  _ServicesPageState createState() => _ServicesPageState();
}

class _ServicesPageState extends State<ServicesPage> {
  List<dynamic> _services = [];
  bool _isLoading = true;
  bool _isVendor = false;

  @override
  void initState() {
    super.initState();
    _fetchServices();
    _checkVendorStatus();
  }

  Future<void> _fetchServices() async {
    setState(() => _isLoading = true);
    try {
      final response = await Supabase.instance.client
          .from('services')
          .select('id, name, price, image_url, vendor_id')
          .order('created_at', ascending: false);
      setState(() {
        _services = response as List<dynamic>;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _checkVendorStatus() async {
    final user = Supabase.instance.client.auth.currentUser;
    final response = await Supabase.instance.client
        .from('profiles')
        .select('role')
        .eq('id', user!.id)
        .single();
    setState(() => _isVendor = (response['role'] as String).toLowerCase() == 'vendor');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Services'),
        actions: [
          if (_isVendor)
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: () async {
                final vendor = await Supabase.instance.client
                    .from('vendors')
                    .select('id')
                    .eq('user_id', Supabase.instance.client.auth.currentUser!.id)
                    .single();
                if (vendor != null) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const AddServicePage()),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Please create a vendor profile first'),
                    ),
                  );
                }
              },
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
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
                        builder: (context) => ServiceDetailPage(serviceId: service['id']),
                      ),
                    ),
                    child: Column(
                      children: [
                        Expanded(
                          child: Image.network(
                            service['image_url'] ?? 'https://via.placeholder.com/150',
                            fit: BoxFit.cover,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(service['name'], style: const TextStyle(fontWeight: FontWeight.bold)),
                              Text('\$${service['price']}'),
                            ],
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