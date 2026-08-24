import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/models/jagx_model.dart';
import '../../../../core/services/ai_service.dart';
import '../../domain/message.dart';

class ChatState {
  const ChatState({
    this.messages = const [],
    this.selectedModel,
    this.isLoading = false,
    this.error,
  });

  final List<ChatMessage> messages;
  final JagxModel? selectedModel;
  final bool isLoading;
  final String? error;

  ChatState copyWith({
    List<ChatMessage>? messages,
    JagxModel? selectedModel,
    bool? isLoading,
    String? error,
  }) {
    return ChatState(
      messages: messages ?? this.messages,
      selectedModel: selectedModel ?? this.selectedModel,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class ChatNotifier extends StateNotifier<ChatState> {
  ChatNotifier(this._ai) : super(ChatState(selectedModel: JagxModels.defaultModel));

  final AiService _ai;
  final _uuid = const Uuid();

  void selectModel(JagxModel model) {
    state = state.copyWith(selectedModel: model);
  }

  bool _wantsImage(String text) {
    final lower = text.toLowerCase();
    return lower.startsWith('generate image') ||
        lower.startsWith('draw ') ||
        lower.startsWith('create an image') ||
        lower.startsWith('make an image') ||
        lower.contains('generate an image of') ||
        state.selectedModel?.category == JagxModelCategory.image;
  }

  Future<void> sendMessage(String text) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty || state.isLoading) return;

    final userMessage = ChatMessage(
      id: _uuid.v4(),
      role: MessageRole.user,
      content: trimmed,
      createdAt: DateTime.now(),
    );

    state = state.copyWith(
      messages: [...state.messages, userMessage],
      isLoading: true,
      error: null,
    );

    final history = state.messages
        .map((m) => {
              'role': m.isUser ? 'user' : 'assistant',
              'content': m.content,
            })
        .toList();

    try {
      final modelId = state.selectedModel?.id ?? JagxModels.defaultModel.id;

      if (_wantsImage(trimmed)) {
        final prompt = trimmed
            .replaceFirst(
              RegExp(
                r'^(generate image[:\s]*|draw[:\s]*|create an image[:\s]*|make an image[:\s]*)',
                caseSensitive: false,
              ),
              '',
            )
            .trim();

        final imageUrl = await _ai.generateImage(
          prompt: prompt.isEmpty ? trimmed : prompt,
        );

        final assistantMessage = ChatMessage(
          id: _uuid.v4(),
          role: MessageRole.assistant,
          content: imageUrl != null
              ? 'Here’s the image I created for you.'
              : 'I couldn’t generate the image right now. Please try again.',
          imageUrl: imageUrl,
          createdAt: DateTime.now(),
        );

        state = state.copyWith(
          messages: [...state.messages, assistantMessage],
          isLoading: false,
        );
        return;
      }

      final reply = await _ai.chat(
        modelId: modelId,
        messages: history,
      );

      final assistantMessage = ChatMessage(
        id: _uuid.v4(),
        role: MessageRole.assistant,
        content: reply,
        createdAt: DateTime.now(),
      );

      state = state.copyWith(
        messages: [...state.messages, assistantMessage],
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Something went wrong. Please try again.',
      );
    }
  }

  void clear() {
    state = ChatState(selectedModel: state.selectedModel);
  }
}

final chatProvider = StateNotifierProvider<ChatNotifier, ChatState>((ref) {
  final ai = ref.watch(aiServiceProvider);
  return ChatNotifier(ai);
});
