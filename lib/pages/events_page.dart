import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
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
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _supabaseService = SupabaseService();
    _loadEvents();
  }

  Future<void> _loadEvents() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    
    try {
      final events = await _supabaseService.getEvents();
      setState(() {
        _events = events.where((e) => e.date.isAfter(DateTime.now())).toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load events: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Upcoming Events'),
        actions: [
          if (widget.isAdmin)
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AddEventPage()),
              ),
            ),
        ],
      ),
      body: _buildContent(),
    );
  }

  Widget _buildContent() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    
    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(_errorMessage!, style: const TextStyle(color: Colors.red)),
            TextButton(
              onPressed: _loadEvents,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }
    
    if (_events.isEmpty) {
      return const Center(
        child: Text('No upcoming events found'),
      );
    }

    return ListView.builder(
      itemCount: _events.length,
      itemBuilder: (context, index) {
        final event = _events[index];
        return Card(
          margin: const EdgeInsets.all(8),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  event.title,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                Text(
                  'Date: ${DateFormat.yMMMEd().format(event.date)}',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                if (event.contactInfo.isNotEmpty)
                  Text(
                    'Contact: ${event.contactInfo}',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                if (event.links.isNotEmpty)
                  Wrap(
                    spacing: 8,
                    children: event.links.map((link) {
                      return ActionChip(
                        label: Text(link),
                        onPressed: () => _launchURL(link),
                      );
                    }).toList(),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _launchURL(String url) {
    // Add URL launching implementation
    // Example: launchUrl(Uri.parse(url));
  }
}