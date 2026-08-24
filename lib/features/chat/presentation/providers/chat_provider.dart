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
    this.isThinking = false,
    this.thinkingSteps = const [],
    this.streamingContent,
    this.error,
  });

  final List<ChatMessage> messages;
  final JagxModel? selectedModel;
  final bool isLoading;
  final bool isThinking;
  final List<String> thinkingSteps;
  final String? streamingContent;
  final String? error;

  ChatState copyWith({
    List<ChatMessage>? messages,
    JagxModel? selectedModel,
    bool? isLoading,
    bool? isThinking,
    List<String>? thinkingSteps,
    String? streamingContent,
    String? error,
    bool clearStreaming = false,
  }) {
    return ChatState(
      messages: messages ?? this.messages,
      selectedModel: selectedModel ?? this.selectedModel,
      isLoading: isLoading ?? this.isLoading,
      isThinking: isThinking ?? this.isThinking,
      thinkingSteps: thinkingSteps ?? this.thinkingSteps,
      streamingContent:
          clearStreaming ? null : (streamingContent ?? this.streamingContent),
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

    final isOracle = state.selectedModel?.id == 'jagx-oracle';

    state = state.copyWith(
      messages: [...state.messages, userMessage],
      isLoading: true,
      isThinking: true,
      thinkingSteps: isOracle
          ? [
              'Understanding your request',
              'Searching the web',
              'Reasoning with current information',
            ]
          : [
              'Understanding your request',
              'Selecting the best approach',
            ],
      error: null,
      clearStreaming: true,
    );

    await Future.delayed(const Duration(milliseconds: 450));

    final history = state.messages
        .map((m) => {
              'role': m.isUser ? 'user' : 'assistant',
              'content': m.content,
            })
        .toList();

    try {
      final modelId = state.selectedModel?.id ?? JagxModels.defaultModel.id;

      if (_wantsImage(trimmed)) {
        state = state.copyWith(
          thinkingSteps: [
            ...state.thinkingSteps,
            'Preparing image generation',
            'Creating with Ember',
          ],
        );

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
          isThinking: false,
          thinkingSteps: [],
        );
        return;
      }

      state = state.copyWith(
        thinkingSteps: [
          ...state.thinkingSteps,
          'Generating response',
        ],
      );

      final buffer = StringBuffer();
      await for (final token in _ai.chatStream(
        modelId: modelId,
        messages: history,
        enableSearch: isOracle,
      )) {
        buffer.write(token);
        state = state.copyWith(
          isThinking: false,
          streamingContent: buffer.toString(),
        );
      }

      final finalContent = buffer.toString().trim();
      if (finalContent.isNotEmpty) {
        final assistantMessage = ChatMessage(
          id: _uuid.v4(),
          role: MessageRole.assistant,
          content: finalContent,
          createdAt: DateTime.now(),
        );

        state = state.copyWith(
          messages: [...state.messages, assistantMessage],
          isLoading: false,
          isThinking: false,
          thinkingSteps: [],
          clearStreaming: true,
        );
      } else {
        state = state.copyWith(
          isLoading: false,
          isThinking: false,
          thinkingSteps: [],
          clearStreaming: true,
          error: 'No response received. Try again.',
        );
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        isThinking: false,
        thinkingSteps: [],
        clearStreaming: true,
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
