import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../config/env.dart';
import '../models/jagx_model.dart';

final aiServiceProvider = Provider<AiService>((ref) {
  return AiService();
});

class AiService {
  final Dio _dio = Dio(
    BaseOptions(
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 90),
    ),
  );

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
            'messages': messages,
          },
        );

        final content = response.data['choices'][0]['message']['content'];
        return content?.toString() ?? 'No response';
      } catch (e) {
        // fall through to other providers if needed
      }
    }

    // Fallback message if no working key
    return 'JagX AI is warming up. Please check your API keys in .env';
  }

  Future<String?> generateImage({
    required String prompt,
    String modelId = 'jagx-image',
  }) async {
    if (Env.openRouterApiKey.isEmpty) {
      return null;
    }

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
        },
      );

      // Different providers return different shapes — keep it defensive
      final data = response.data;
      if (data['data'] != null && data['data'].isNotEmpty) {
        return data['data'][0]['url']?.toString();
      }
      return null;
    } catch (_) {
      return null;
    }
  }
}
