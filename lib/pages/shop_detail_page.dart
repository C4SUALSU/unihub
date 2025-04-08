import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'add_item_page.dart';
import 'chat_page.dart';

class ShopDetailPage extends StatefulWidget {
  final int vendorId;
  const ShopDetailPage({required this.vendorId, super.key});

  @override
  _ShopDetailPageState createState() => _ShopDetailPageState();
}

class _ShopDetailPageState extends State<ShopDetailPage> {
  Map<String, dynamic>? _vendor;
  List<dynamic> _items = [];
  bool _isVendorShop = false;
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
          .select('id, name, image_path, user_id')
          .eq('id', widget.vendorId)
          .single();
      
      // Fetch items
      final itemsResponse = await Supabase.instance.client
          .from('shop_items')
          .select('id, name, price, description, image_url')
          .eq('vendor_id', widget.vendorId);

      // Check ownership
      final user = Supabase.instance.client.auth.currentUser;
      final isVendor = user?.id == vendorResponse['user_id'];

      setState(() {
        _vendor = vendorResponse;
        _items = itemsResponse as List<dynamic>;
        _isVendorShop = isVendor;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading shop: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_vendor?['name'] ?? 'Shop Details'),
        actions: [
          if (_isVendorShop)
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: () => Navigator.push<bool>(
                context,
                MaterialPageRoute(
                  builder: (context) => AddItemPage(vendorId: widget.vendorId),
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
              ? const Center(child: Text('Shop not found'))
              : Column(
                  children: [
                    // Vendor Header
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
                        itemCount: _items.length,
                        itemBuilder: (context, index) {
                          final item = _items[index];
                          return Card(
                            child: Column(
                              children: [
                                Expanded(
                                  child: Image.network(
                                    item['image_url'] ?? 
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
                                      Text(item['name'], 
                                        style: const TextStyle(fontSize: 16)),
                                      Text('\$${item['price']}',
                                        style: const TextStyle(fontSize: 18)),
                                      Text(item['description'] ?? '',
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