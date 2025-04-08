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
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchVendors();
  }

  Future<void> _fetchVendors() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Fetch only the relative path
      final response = await Supabase.instance.client
          .from('vendors')
          .select('id, name, image_path, user_id, category, created_at') // Renamed column
          .eq('category', 'food')
          .order('created_at', ascending: false);

      setState(() {
        _vendors = response as List<dynamic>;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Error: ${e.toString()}';
      });
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
              ).then((_) => _fetchVendors()),
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
                        onPressed: _fetchVendors,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : _vendors.isEmpty
                  ? const Center(child: Text('No food vendors found'))
                  : GridView.builder(
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
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
                                builder: (context) =>
                                    ShopDetailPage(vendorId: vendor['id']),
                              ),
                            ),
                            child: Column(
                              children: [
                                Expanded(
                                  child: Image.network(
                                    // Generate full URL from relative path
                                    '${Supabase.instance.client.storage.from('shop-images').getPublicUrl(vendor['image_path'])}',
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) =>
                                        const Icon(Icons.error),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(
                                    vendor['name'],
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