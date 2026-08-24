import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../config/env.dart';
import '../utils/watermark.dart';

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

You can do all of the following:
- Search the internet and reason over current information
- Write and debug code in any language
- Analyze images and documents
- Generate high quality images
- Draft professional CVs / resumes (structured, modern, ATS-friendly)
- Create product designs, UI copy, brand guidelines, pitch decks (text form)
- Produce documents that users can personalize (proposals, contracts outlines, reports, letters, package descriptions)
- Output content ready to be turned into PDF or other files (clean Markdown / structured text)
- Help with product, design, business, and technical decisions

When asked to create a CV, document, design draft, or package:
- Produce complete, high-quality, ready-to-use content
- Use clear structure (headings, bullet points, sections)
- Make it easy for the user to personalize

Style: natural, confident, structured when helpful.
''';

  String _resolveUpstream(String jagxModelId) {
    switch (jagxModelId) {
      case 'jagx-pulse':
        return 'openai/gpt-4o-mini';
      case 'jagx-nova':
        return 'anthropic/claude-3.5-sonnet';
      case 'jagx-forge':
        return 'deepseek/deepseek-coder';
      case 'jagx-aether':
        return 'openai/gpt-4o';
      case 'jagx-ember':
        return 'black-forest-labs/flux-1.1-pro';
      case 'jagx-oracle':
        return 'anthropic/claude-3.5-sonnet';
      default:
        return 'openai/gpt-4o-mini';
    }
  }

  Future<String> webSearch(String query) async {
    try {
      final response = await _dio.get(
        'https://api.duckduckgo.com/',
        queryParameters: {
          'q': query,
          'format': 'json',
          'no_html': 1,
          'skip_disambig': 1,
        },
      );

      final data = response.data;
      final buffer = StringBuffer();

      if (data['AbstractText'] != null &&
          data['AbstractText'].toString().isNotEmpty) {
        buffer.writeln(data['AbstractText']);
      }
      if (data['Answer'] != null && data['Answer'].toString().isNotEmpty) {
        buffer.writeln(data['Answer']);
      }

      final related = data['RelatedTopics'] as List? ?? [];
      for (final item in related.take(4)) {
        if (item is Map && item['Text'] != null) {
          buffer.writeln('• ${item['Text']}');
        }
      }

      final result = buffer.toString().trim();
      return result.isEmpty ? 'No clear results found for "$query".' : result;
    } catch (_) {
      return 'Search is temporarily unavailable.';
    }
  }

  Future<String> chat({
    required String modelId,
    required List<Map<String, String>> messages,
    bool enableSearch = false,
  }) async {
    final upstream = _resolveUpstream(modelId);
    var workingMessages = List<Map<String, String>>.from(messages);

    if (enableSearch || modelId == 'jagx-oracle') {
      final lastUser = workingMessages.lastWhere(
        (m) => m['role'] == 'user',
        orElse: () => {},
      );
      final query = lastUser['content'] ?? '';
      if (query.length > 8) {
        final searchResult = await webSearch(query);
        workingMessages = [
          ...workingMessages,
          {
            'role': 'system',
            'content':
                'Current web information for context:\n$searchResult\n\nUse this if relevant. Do not mention the search source.',
          },
        ];
      }
    }

    final fullMessages = [
      {'role': 'system', 'content': _systemPrompt},
      ...workingMessages,
    ];

    if (Env.openRouterApiKey.isEmpty) {
      return JagxWatermark.embed(
        'JagX AI needs API keys configured in .env to respond.',
      );
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

      final content =
          response.data['choices'][0]['message']['content']?.toString() ??
              'No response generated.';

      // Always apply invisible watermark
      return JagxWatermark.embed(content);
    } catch (_) {
      return JagxWatermark.embed(
        'JagX AI is temporarily unavailable. Please try again.',
      );
    }
  }

  Stream<String> chatStream({
    required String modelId,
    required List<Map<String, String>> messages,
    bool enableSearch = false,
  }) async* {
    final reply = await chat(
      modelId: modelId,
      messages: messages,
      enableSearch: enableSearch || modelId == 'jagx-oracle',
    );

    // Stream the already-watermarked text
    const chunkSize = 14;
    for (var i = 0; i < reply.length; i += chunkSize) {
      final end = (i + chunkSize < reply.length) ? i + chunkSize : reply.length;
      yield reply.substring(i, end);
      await Future.delayed(const Duration(milliseconds: 16));
    }
  }

  Future<String?> generateImage({
    required String prompt,
    String modelId = 'jagx-ember',
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
