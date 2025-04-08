import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/event.dart';
import '../models/vendor.dart';

class SupabaseService {
  final SupabaseClient _supabase = Supabase.instance.client;

  // Fetch all events from Supabase
  Future<List<Event>> getEvents() async {
    try {
      final response = await _supabase.from('events').select().order('date');
      final data = response as List<dynamic>;
      return data.map((json) => Event.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to fetch events: $e');
    }
  }

  // Add new event (admin-only)
  Future<void> addEvent({
    required String title,
    required DateTime date,
    required String contactInfo,
    String? whatsappNumber,
    List<String>? links,
    required String imageUrl,
    required String userId, 
  }) async {
    try {
      await _supabase.from('events').insert({
        'title': title,
        'date': date.toIso8601String(),
        'contact_info': contactInfo,
        'whatsapp_number': whatsappNumber,
        'links': links,
        'image_url': imageUrl,
        'user_id': userId,
      });
    } catch (e) {
      throw Exception('Failed to add event: $e');
    }
  }

  // Fetch all vendors
  Future<List<Vendor>> getVendors() async {
    try {
      final response = await _supabase.from('vendors').select();
      final data = response as List<dynamic>;
      return data.map((json) => Vendor.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to fetch vendors: $e');
    }
  }
}