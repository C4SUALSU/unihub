import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

class ChatPage extends StatefulWidget {
  final int? vendorId;
  final String? vendorName;
  final String? conversationId;
  final String? recipientId;

  const ChatPage({
    this.vendorId,
    this.vendorName,
    this.conversationId,
    this.recipientId,
    super.key,
  });

  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final _messageController = TextEditingController();
  List<dynamic> _messages = [];
  late final Stream<List<dynamic>> _messageStream;
  String? _currentUserId;
  final Uuid _uuid = const Uuid();

  @override
  void initState() {
    super.initState();
    _currentUserId = Supabase.instance.client.auth.currentUser!.id;
    _setupMessageStream();
  }

  void _setupMessageStream() {
    if (widget.conversationId != null) {
      _messageStream = Supabase.instance.client
          .from('messages:conversation_id=eq.${widget.conversationId}')
          .stream(primaryKey: ['id'])
          .execute()
          .map((data) => data as List<dynamic>);
    } else {
      _messageStream = Supabase.instance.client
          .from('messages')
          .stream(primaryKey: ['id'])
          .execute()
          .map((data) => data as List<dynamic>);
    }
  }

  Future<void> _sendMessage() async {
    if (_messageController.text.isEmpty) return;

    final newMessage = {
      'sender_id': _currentUserId,
      'recipient_id': widget.recipientId ?? widget.vendorId,
      'content': _messageController.text,
      'conversation_id': widget.conversationId ?? _uuid.v4(),
    };

    await Supabase.instance.client.from('messages').insert(newMessage);
    _messageController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold( // Fixed: Added 'return' keyword
      appBar: AppBar(title: Text(widget.vendorName ?? 'New Chat')),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<List<dynamic>>(
              stream: _messageStream,
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  _messages = snapshot.data!;
                  return ListView.builder(
                    reverse: true,
                    itemCount: _messages.length,
                    itemBuilder: (context, index) {
                      final message = _messages[index];
                      final isMe = message['sender_id'] == _currentUserId;
                      return Align(
                        alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                        child: Container(
                          margin: const EdgeInsets.all(8),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: isMe ? Colors.blue[100] : Colors.grey[300],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(message['content']),
                        ),
                      );
                    },
                  );
                }
                return const Center(child: CircularProgressIndicator());
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: const InputDecoration(
                      hintText: 'Type a message...',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
