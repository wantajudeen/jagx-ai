import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

import '../domain/message.dart';

class Conversation {
  const Conversation({
    required this.id,
    required this.title,
    this.modelId,
    this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String title;
  final String? modelId;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  factory Conversation.fromJson(Map<String, dynamic> json) {
    return Conversation(
      id: json['id'] as String,
      title: json['title'] as String? ?? 'New chat',
      modelId: json['model_id'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'] as String)
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'] as String)
          : null,
    );
  }
}

class ChatRepository {
  ChatRepository(this._client);

  final SupabaseClient _client;
  final _uuid = const Uuid();

  String? get _userId => _client.auth.currentUser?.id;

  Future<List<Conversation>> fetchConversations() async {
    final userId = _userId;
    if (userId == null) return [];

    final data = await _client
        .from('conversations')
        .select()
        .eq('user_id', userId)
        .order('updated_at', ascending: false);

    return (data as List)
        .map((e) => Conversation.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<Conversation> createConversation({
    String title = 'New chat',
    String? modelId,
  }) async {
    final userId = _userId;
    if (userId == null) throw Exception('Not authenticated');

    final data = await _client.from('conversations').insert({
      'user_id': userId,
      'title': title,
      'model_id': modelId,
    }).select().single();

    return Conversation.fromJson(data);
  }

  Future<void> updateConversationTitle(String id, String title) async {
    await _client.from('conversations').update({
      'title': title,
      'updated_at': DateTime.now().toIso8601String(),
    }).eq('id', id);
  }

  Future<void> deleteConversation(String id) async {
    await _client.from('conversations').delete().eq('id', id);
  }

  Future<List<ChatMessage>> fetchMessages(String conversationId) async {
    final data = await _client
        .from('messages')
        .select()
        .eq('conversation_id', conversationId)
        .order('created_at', ascending: true);

    return (data as List).map((e) {
      final map = e as Map<String, dynamic>;
      return ChatMessage(
        id: map['id'] as String,
        role: map['role'] == 'user' ? MessageRole.user : MessageRole.assistant,
        content: map['content'] as String,
        imageUrl: map['image_url'] as String?,
        createdAt: map['created_at'] != null
            ? DateTime.tryParse(map['created_at'] as String)
            : null,
      );
    }).toList();
  }

  Future<void> saveMessage({
    required String conversationId,
    required ChatMessage message,
  }) async {
    await _client.from('messages').insert({
      'id': message.id,
      'conversation_id': conversationId,
      'role': message.isUser ? 'user' : 'assistant',
      'content': message.content,
      'image_url': message.imageUrl,
    });

    // Touch conversation updated_at
    await _client.from('conversations').update({
      'updated_at': DateTime.now().toIso8601String(),
    }).eq('id', conversationId);
  }

  Future<void> saveMessages({
    required String conversationId,
    required List<ChatMessage> messages,
  }) async {
    if (messages.isEmpty) return;

    final rows = messages.map((m) => {
          'id': m.id,
          'conversation_id': conversationId,
          'role': m.isUser ? 'user' : 'assistant',
          'content': m.content,
          'image_url': m.imageUrl,
        }).toList();

    await _client.from('messages').upsert(rows);

    await _client.from('conversations').update({
      'updated_at': DateTime.now().toIso8601String(),
    }).eq('id', conversationId);
  }
}
