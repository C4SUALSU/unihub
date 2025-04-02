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
  List<dynamic> _items = [];
  bool _isVendorShop = false;

  @override
  void initState() {
    super.initState();
    _fetchItems();
    _checkVendorOwnership();
  }

  Future<void> _fetchItems() async {
    final response = await Supabase.instance.client
        .from('shop_items')
        .select('*')
        .eq('vendor_id', widget.vendorId);
    setState(() => _items = response as List<dynamic>);
  }

  Future<void> _checkVendorOwnership() async {
    final user = Supabase.instance.client.auth.currentUser;
    final vendor = await Supabase.instance.client
        .from('vendors')
        .select('user_id')
        .eq('id', widget.vendorId)
        .single();
    setState(() {
      _isVendorShop = vendor['user_id'] == user?.id;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Shop Details'),
        actions: [
          if (_isVendorShop)
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AddItemPage(vendorId: widget.vendorId),
                ),
              ),
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
      body: ListView.builder(
        itemCount: _items.length,
        itemBuilder: (context, index) {
          final item = _items[index];
          return ListTile(
            leading: Image.network(item['image_url'] ?? ''),
            title: Text(item['name']),
            subtitle: Text('\$${item['price']}'),
            onTap: () => _showItemDetails(item),
          );
        },
      ),
    );
  }

  void _showItemDetails(Map<String, dynamic> item) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.network(item['image_url'] ?? ''),
            Text(item['name'], style: const TextStyle(fontSize: 20)),
            Text(item['description'] ?? ''),
            Text('\$${item['price']}', style: const TextStyle(fontSize: 18)),
          ],
        ),
      ),
    );
  }
}