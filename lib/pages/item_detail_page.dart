import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// Import models and services
import '../models/vendor.dart';
import '../services/supabase_service.dart'; // Ensure this path is correct
import 'chat_page.dart'; // Ensure this path is correct

class ItemDetailPage extends StatefulWidget {
  final int itemId;

  const ItemDetailPage({required this.itemId, Key? key}) : super(key: key);

  @override
  _ItemDetailPageState createState() => _ItemDetailPageState();
}

class _ItemDetailPageState extends State<ItemDetailPage> {
  late Future<Map<String, dynamic>> _itemFuture;
  late Future<Vendor> _vendorFuture;

  @override
  void initState() {
    super.initState();
    // Fetch the item details using the itemId
    _itemFuture = SupabaseService().fetchShopItem(widget.itemId); // Add ()
    // Fetch the vendor details using the vendorId from the item
    _vendorFuture = SupabaseService().fetchVendorByItemId(widget.itemId); // Add ()
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Item Details'),
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _itemFuture,
        builder: (context, itemSnapshot) {
          if (itemSnapshot.hasData) {
            final item = itemSnapshot.data!;
            return SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Item Image
                  if (item['image_url'] != null)
                    Image.network(
                      item['image_url'],
                      height: 200,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => const Icon(Icons.error),
                    ),
                  const SizedBox(height: 16.0),

                  // Item Name
                  Text(
                    item['name'],
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8.0),

                  // Item Description
                  Text(
                    item['description'] ?? 'No description available',
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 16.0),

                  // Item Price
                  Text(
                    'Price: \$${item['price']}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16.0),

                  // Vendor Information
                  FutureBuilder<Vendor>(
                    future: _vendorFuture,
                    builder: (context, vendorSnapshot) {
                      if (vendorSnapshot.hasData) {
                        final vendor = vendorSnapshot.data!;
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Vendor:',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8.0),
                            Row(
                              children: [
                                CircleAvatar(
                                  radius: 24,
                                  backgroundImage: NetworkImage(
                                    Supabase.instance.client.storage
                                        .from('shop-images') // Adjust bucket name
                                        .getPublicUrl(vendor.imagePath ??
                                            'default_profile.png'), // Provide fallback
                                  ),
                                ),
                                const SizedBox(width: 8.0),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      vendor.name,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 4.0),
                                    Text(
                                      vendor.contact, // Use contact instead of email
                                      style: const TextStyle(fontSize: 14),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        );
                      } else if (vendorSnapshot.hasError) {
                        return Text('Error: ${vendorSnapshot.error}');
                      }
                      return const CircularProgressIndicator();
                    },
                  ),
                  const SizedBox(height: 32.0),

                  // Chat Button
                  ElevatedButton(
                    onPressed: () async {
                      // Navigate to the chat page with the vendor
                      final vendor = await _vendorFuture;
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ChatPage(
                            vendorId: vendor.id,
                            vendorName: vendor.name,
                            recipientId: vendor.id.toString(),
                          ),
                        ),
                      );
                    },
                    child: const Text('Chat with Vendor'),
                  ),
                ],
              ),
            );
          } else if (itemSnapshot.hasError) {
            return Center(child: Text('Error: ${itemSnapshot.error}'));
          }
          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }
}