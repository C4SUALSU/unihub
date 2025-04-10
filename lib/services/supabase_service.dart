import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/event.dart';
import '../models/vendor.dart';

class SupabaseService {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<List<Event>> getEvents() async {
    try {
      final response = await _supabase.from('events').select().order('date');
      return response.map((json) => Event.fromJson(json)).toList();
    } on PostgrestException catch (error) { // [[9]]
      throw Exception(
        'Supabase Error: ${error.message} (Code: ${error.code})'
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
    } on PostgrestException catch (error) { // [[9]]
      throw Exception(
        'Failed to add event: ${error.message} (Code: ${error.code})'
      );
    }
  }

  Future<List<Vendor>> getVendors() async {
    try {
      final response = await _supabase.from('vendors').select();
      return response.map((json) => Vendor.fromJson(json)).toList();
    } on PostgrestException catch (error) { // [[9]]
      throw Exception(
        'Supabase Error: ${error.message} (Code: ${error.code})'
      );
    }
  }
}