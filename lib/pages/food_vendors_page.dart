import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'add_shop_page.dart';
import 'shop_detail_page.dart';

class FoodVendorsPage extends StatefulWidget {
  final bool isVendor;
  const FoodVendorsPage({this.isVendor = false, super.key});

  @override
  _FoodVendorsPageState createState() => _FoodVendorsPageState();
}

class _FoodVendorsPageState extends State<FoodVendorsPage> {
  List<dynamic> _vendors = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchVendors();
  }

  Future<void> _fetchVendors() async {
    setState(() => _isLoading = true);
    try {
      final response = await Supabase.instance.client
          .from('vendors')
          .select('id, name, image_url, user_id')
          .order('created_at', ascending: false);
      setState(() {
        _vendors = response as List<dynamic>;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Food Vendors'),
        actions: [
          if (widget.isVendor)
            IconButton(
              icon: const Icon(Icons.add_business),
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AddShopPage()),
              ),
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
              itemCount: _vendors.length,
              itemBuilder: (context, index) {
                final vendor = _vendors[index];
                return Card(
                  child: InkWell(
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ShopDetailPage(vendorId: vendor['id']),
                      ),
                    ),
                    child: Column(
                      children: [
                        Expanded(
                          child: Image.network(
                            vendor['image_url'] ?? 
                            'https://via.placeholder.com/150',
                            fit: BoxFit.cover,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(vendor['name']),
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