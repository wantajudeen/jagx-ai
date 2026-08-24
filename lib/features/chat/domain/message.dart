enum MessageRole { user, assistant, system }

class ChatMessage {
  const ChatMessage({
    required this.id,
    required this.role,
    required this.content,
    this.imageUrl,
    this.createdAt,
  });

  final String id;
  final MessageRole role;
  final String content;
  final String? imageUrl;
  final DateTime? createdAt;

  bool get isUser => role == MessageRole.user;
  bool get isAssistant => role == MessageRole.assistant;
}
