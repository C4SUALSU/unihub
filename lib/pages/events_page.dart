import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/event.dart';
import '../services/supabase_service.dart';
import 'add_event_page.dart';

class EventsPage extends StatefulWidget {
  final bool isAdmin;
  const EventsPage({this.isAdmin = false, super.key});

  @override
  _EventsPageState createState() => _EventsPageState();
}

class _EventsPageState extends State<EventsPage> {
  late final SupabaseService _supabaseService;
  List<Event> _events = [];

  @override
  void initState() {
    super.initState();
    _supabaseService = SupabaseService();
    _fetchEvents();
  }

  Future<void> _fetchEvents() async {
    final events = await _supabaseService.getEvents();
    setState(() => _events = events);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Upcoming Events'),
        actions: [
          if (widget.isAdmin)
            TextButton(
              child: const Text('Add Event'),
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AddEventPage()),
              ),
            ),
        ],
      ),
      body: ListView.builder(
        itemCount: _events.length,
        itemBuilder: (context, index) {
          final event = _events[index];
          return ListTile(
            title: Text(event.title),
            subtitle: Text(event.date.toString()),
            trailing: Text(event.location),
          );
        },
      ),
    );
  }
}