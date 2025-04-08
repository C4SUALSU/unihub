import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'chat_page.dart';

class ItemDetailPage extends StatelessWidget {
  final int itemId;
  const ItemDetailPage({required this.itemId, super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Item Details')),
      body: FutureBuilder(
        future: Supabase.instance.client
            .from('shop_items')
            .select('*, vendor:vendor_id(user_id)')
            .eq('id', itemId)
            .maybeSingle(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError || !snapshot.hasData) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final item = snapshot.data as Map<String, dynamic>;
          final vendorUserId = item['vendor']?['user_id'] as String?;

          return Column(
            children: [
              Image.network(
                item['image_url'] != null
                    ? Supabase.instance.client.storage
                        .from('shop-images')
                        .getPublicUrl(item['image_url'])
                    : 'https://via.placeholder.com/150',
                height: 300,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => const Icon(Icons.error),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item['name'] ?? 'Unnamed Item',
                      style: const TextStyle(fontSize: 24),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '\$${item['price']?.toString() ?? 'N/A'}',
                      style: const TextStyle(fontSize: 20),
                    ),
                    const SizedBox(height: 16),
                    Text(item['description'] ?? 'No description'),
                  ],
                ),
              ),
              if (vendorUserId != null)
                ElevatedButton(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ChatPage(
                        vendorId: vendorUserId,
                        itemId: itemId,
                      ),
                    ),
                  ),
                  child: const Text('Chat about this item'),
                ),
            ],
          );
        },
      ),
    );
  }
}