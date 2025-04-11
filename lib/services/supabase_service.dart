import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/event.dart';
import '../models/vendor.dart';

class SupabaseService {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<List<Event>> getEvents() async {
    try {
      final response = await _supabase.from('events').select().order('date');
      return response.map((json) => Event.fromJson(json)).toList();
    } on PostgrestException catch (error) {
      throw Exception(
        'Supabase Error: ${error.message} (Code: ${error.code})',
      );
    }
  }

  Future<void> addEvent({
    required String title,
    required DateTime date,
    required String contactInfo,
    String? whatsappNumber,
    List<String>? links,
    String? imageUrl,
    required String userId,
  }) async {
    try {
      await _supabase.from('events').insert({
        'title': title,
        'date': date.toIso8601String(),
        'contact_info': contactInfo,
        'whatsapp_number': whatsappNumber,
        'links': links ?? [],
        'image_url': imageUrl,
        'user_id': userId,
      });
    } on PostgrestException catch (error) {
      throw Exception(
        'Failed to add event: ${error.message} (Code: ${error.code})',
      );
    }
  }

  Future<List<Vendor>> getVendors() async {
    try {
      final response = await _supabase.from('vendors').select();
      return response.map((json) => Vendor.fromJson(json)).toList();
    } on PostgrestException catch (error) {
      throw Exception(
        'Supabase Error: ${error.message} (Code: ${error.code})',
      );
    }
  }

  // New Methods for Item Detail Page
  Future<Map<String, dynamic>> fetchShopItem(int itemId) async {
    try {
      final response = await _supabase
          .from('shop_items')
          .select()
          .eq('id', itemId)
          .single();
      return response;
    } on PostgrestException catch (error) {
      throw Exception('Error fetching shop item: ${error.message}');
    }
  }

  Future<Vendor> fetchVendorByItemId(int itemId) async {
    try {
      final shopItem = await fetchShopItem(itemId);
      final vendorId = shopItem['vendor_id'];
      final vendorResponse = await _supabase
          .from('vendors')
          .select()
          .eq('id', vendorId)
          .single();
      return Vendor.fromJson(vendorResponse);
    } on PostgrestException catch (error) {
      throw Exception('Error fetching vendor: ${error.message}');
    }
  }
}