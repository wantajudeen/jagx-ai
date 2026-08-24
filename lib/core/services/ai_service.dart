import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../config/env.dart';

final aiServiceProvider = Provider<AiService>((ref) {
  return AiService();
});

class AiService {
  final Dio _dio = Dio(
    BaseOptions(
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 120),
    ),
  );

  static const String _systemPrompt = '''
You are JagX AI, created by JagX & JRILICENSE.
You are a highly capable, helpful, and intelligent assistant.

Core identity:
- You are JagX AI. Never mention OpenAI, Anthropic, Google, Meta, Claude, GPT, Llama, or any other company or model names.
- Always identify yourself only as JagX AI by JagX & JRILICENSE when asked who you are.
- Be maximally helpful, truthful, and clear.

Capabilities:
- Deep reasoning and step-by-step thinking when needed
- Writing and explaining code in any language
- Analyzing images and documents
- Generating detailed, high-quality images when asked
- Helping with product, design, business, and technical decisions

Style:
- Natural, confident, and human
- Prefer clear structure when it helps
- Match the user's language and energy
''';

  String _resolveUpstream(String jagxModelId) {
    switch (jagxModelId) {
      case 'jagx-pulse':
        return 'openai/gpt-4o-mini';
      case 'jagx-nova':
        return 'anthropic/claude-3.5-sonnet';
      case 'jagx-forge':
        return 'deepseek/deepseek-coder';
      case 'jagx-lens':
        return 'openai/gpt-4o';
      case 'jagx-canvas':
        return 'black-forest-labs/flux-1.1-pro';
      default:
        return 'openai/gpt-4o-mini';
    }
  }

  /// Non-streaming chat (fallback)
  Future<String> chat({
    required String modelId,
    required List<Map<String, String>> messages,
  }) async {
    final upstream = _resolveUpstream(modelId);
    final fullMessages = [
      {'role': 'system', 'content': _systemPrompt},
      ...messages,
    ];

    if (Env.openRouterApiKey.isEmpty) {
      return 'JagX AI needs API keys configured in .env to respond.';
    }

    try {
      final response = await _dio.post(
        'https://openrouter.ai/api/v1/chat/completions',
        options: Options(
          headers: {
            'Authorization': 'Bearer ${Env.openRouterApiKey}',
            'HTTP-Referer': 'https://jagx.ai',
            'X-Title': 'JagX AI',
            'Content-Type': 'application/json',
          },
        ),
        data: {
          'model': upstream,
          'messages': fullMessages,
          'temperature': 0.7,
          'max_tokens': 4096,
        },
      );

      final content = response.data['choices'][0]['message']['content'];
      return content?.toString() ?? 'No response generated.';
    } catch (_) {
      return 'JagX AI is temporarily unavailable. Please try again.';
    }
  }

  /// Streaming chat – yields tokens as they arrive
  Stream<String> chatStream({
    required String modelId,
    required List<Map<String, String>> messages,
  }) async* {
    final upstream = _resolveUpstream(modelId);
    final fullMessages = [
      {'role': 'system', 'content': _systemPrompt},
      ...messages,
    ];

    if (Env.openRouterApiKey.isEmpty) {
      yield 'JagX AI needs API keys configured in .env to respond.';
      return;
    }

    try {
      final response = await _dio.post(
        'https://openrouter.ai/api/v1/chat/completions',
        options: Options(
          headers: {
            'Authorization': 'Bearer ${Env.openRouterApiKey}',
            'HTTP-Referer': 'https://jagx.ai',
            'X-Title': 'JagX AI',
            'Content-Type': 'application/json',
          },
          responseType: ResponseType.stream,
        ),
        data: {
          'model': upstream,
          'messages': fullMessages,
          'temperature': 0.7,
          'max_tokens': 4096,
          'stream': true,
        },
      );

      final stream = response.data.stream as Stream<List<int>>;
      final buffer = StringBuffer();

      await for (final chunk in stream) {
        final text = String.fromCharCodes(chunk);
        // Very simple SSE parsing for OpenRouter/OpenAI style
        for (final line in text.split('\n')) {
          if (line.startsWith('data: ')) {
            final data = line.substring(6).trim();
            if (data == '[DONE]') return;
            try {
              // Minimal extraction of delta content
              if (data.contains('"content":')) {
                final start = data.indexOf('"content":"') + 11;
                final end = data.indexOf('"', start);
                if (start > 10 && end > start) {
                  final token = data.substring(start, end)
                      .replaceAll('\\n', '\n')
                      .replaceAll('\\"', '"');
                  buffer.write(token);
                  yield token;
                }
              }
            } catch (_) {}
          }
        }
      }
    } catch (_) {
      yield 'JagX AI is temporarily unavailable. Please try again.';
    }
  }

  Future<String?> generateImage({
    required String prompt,
    String modelId = 'jagx-canvas',
  }) async {
    if (Env.openRouterApiKey.isEmpty) return null;

    try {
      final response = await _dio.post(
        'https://openrouter.ai/api/v1/images/generations',
        options: Options(
          headers: {
            'Authorization': 'Bearer ${Env.openRouterApiKey}',
            'Content-Type': 'application/json',
          },
        ),
        data: {
          'model': _resolveUpstream(modelId),
          'prompt': prompt,
          'n': 1,
          'size': '1024x1024',
        },
      );

      final data = response.data;
      if (data['data'] != null && (data['data'] as List).isNotEmpty) {
        return data['data'][0]['url']?.toString();
      }
      if (data['url'] != null) return data['url'].toString();
      return null;
    } catch (_) {
      return null;
    }
  }
}
