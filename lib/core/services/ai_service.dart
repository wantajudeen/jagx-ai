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

Capabilities you should lean into:
- Deep reasoning and step-by-step thinking when needed
- Writing and explaining code in any language
- Analyzing images and documents (when provided)
- Generating detailed, high-quality images when asked
- Answering questions about the world with current knowledge
- Helping with product, design, business, and technical decisions
- Being concise when the user wants speed, thorough when they want depth

Style:
- Natural, confident, and human
- No corporate filler
- Prefer clear structure (headings, lists, code blocks) when it helps
- Match the user's language and energy
''';

  /// Maps public JagX model IDs to actual upstream models.
  /// This mapping is never exposed to the UI.
  String _resolveUpstream(String jagxModelId) {
    switch (jagxModelId) {
      case 'jagx-core':
        return 'openai/gpt-4o-mini';
      case 'jagx-pro':
        return 'anthropic/claude-3.5-sonnet';
      case 'jagx-code':
        return 'deepseek/deepseek-coder';
      case 'jagx-vision':
        return 'openai/gpt-4o';
      case 'jagx-image':
        return 'black-forest-labs/flux-1.1-pro';
      default:
        return 'openai/gpt-4o-mini';
    }
  }

  Future<String> chat({
    required String modelId,
    required List<Map<String, String>> messages,
  }) async {
    final upstream = _resolveUpstream(modelId);

    final fullMessages = [
      {'role': 'system', 'content': _systemPrompt},
      ...messages,
    ];

    // Prefer OpenRouter when key is present
    if (Env.openRouterApiKey.isNotEmpty) {
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
      } on DioException catch (e) {
        final status = e.response?.statusCode;
        final body = e.response?.data;
        return 'JagX AI hit a temporary issue ($status). Please try again.';
      } catch (_) {
        return 'JagX AI is temporarily unavailable. Please try again in a moment.';
      }
    }

    // Fallback if no key
    return 'JagX AI needs API keys configured in .env to respond.';
  }

  Future<String?> generateImage({
    required String prompt,
    String modelId = 'jagx-image',
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
      // Some providers return different shapes
      if (data['url'] != null) return data['url'].toString();
      return null;
    } catch (_) {
      return null;
    }
  }
}
