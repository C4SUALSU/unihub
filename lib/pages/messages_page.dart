import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'chat_page.dart';

class MessagesPage extends StatefulWidget {
  const MessagesPage({super.key});

  @override
  _MessagesPageState createState() => _MessagesPageState();
}

class _MessagesPageState extends State<MessagesPage> {
  List<dynamic> _conversations = [];

  @override
  void initState() {
    super.initState();
    _fetchConversations();
  }

  Future<void> _fetchConversations() async {
    final user = Supabase.instance.client.auth.currentUser;
    final response = await Supabase.instance.client
        .from('messages')
        .select('*, sender:sender_id(*), recipient:recipient_id(*)')
        .or('sender_id.eq.${user!.id},recipient_id.eq.${user.id}');
    setState(() => _conversations = response as List<dynamic>);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Messages')),
      body: ListView.builder(
        itemCount: _conversations.length,
        itemBuilder: (context, index) {
          final message = _conversations[index];
          final otherUser = message['sender_id'] == 
              Supabase.instance.client.auth.currentUser!.id
              ? message['recipient']
              : message['sender'];
              
          return ListTile(
            leading: CircleAvatar(child: Text(otherUser['email'][0])),
            title: Text(otherUser['email']),
            subtitle: Text(message['content']),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ChatPage(
                  conversationId: message['id'],
                  recipientId: otherUser['id'],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}


