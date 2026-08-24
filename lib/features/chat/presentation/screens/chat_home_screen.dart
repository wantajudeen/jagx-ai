import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/models/jagx_model.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/pdf_export.dart';
import '../../domain/message.dart';
import '../providers/chat_provider.dart';
import '../providers/conversations_provider.dart';

class ChatHomeScreen extends ConsumerStatefulWidget {
  const ChatHomeScreen({super.key});

  @override
  ConsumerState<ChatHomeScreen> createState() => _ChatHomeScreenState();
}

class _ChatHomeScreenState extends ConsumerState<ChatHomeScreen> {
  final _controller = TextEditingController();
  final _scrollController = ScrollController();

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _send([String? overrideText]) {
    final text = overrideText ?? _controller.text;
    if (text.trim().isEmpty) return;
    ref.read(chatProvider.notifier).sendMessage(text);
    _controller.clear();
    _scrollToBottom();
    // Refresh conversation list after first message
    Future.delayed(const Duration(milliseconds: 800), () {
      ref.read(conversationsProvider.notifier).refresh();
    });
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 80), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent + 120,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _exportPdf() async {
    final chat = ref.read(chatProvider);
    if (chat.messages.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nothing to export yet')),
      );
      return;
    }

    final buffer = StringBuffer();
    for (final m in chat.messages) {
      buffer.writeln(m.isUser ? 'You:' : 'JagX AI:');
      buffer.writeln(m.content);
      buffer.writeln();
    }

    await PdfExport.export(
      title: 'JagX AI Conversation',
      content: buffer.toString(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final chat = ref.watch(chatProvider);
    final selected = chat.selectedModel ?? JagxModels.defaultModel;

    if (chat.streamingContent != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
    }

    return Scaffold(
      drawer: const _ConversationsDrawer(),
      appBar: AppBar(
        title: Row(
          children: [
            Text(
              'JagX',
              style: TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.w700,
                fontSize: 20,
              ),
            ),
            const SizedBox(width: 6),
            Text(
              'AI',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w500,
                fontSize: 16,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Export as PDF',
            icon: const Icon(Icons.picture_as_pdf_outlined, size: 22),
            onPressed: _exportPdf,
          ),
          PopupMenuButton<JagxModel>(
            initialValue: selected,
            onSelected: (m) => ref.read(chatProvider.notifier).selectModel(m),
            itemBuilder: (context) {
              return JagxModels.all.map((m) {
                return PopupMenuItem(
                  value: m,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(m.name, style: const TextStyle(fontWeight: FontWeight.w600)),
                      Text(
                        m.description,
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textTertiary,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList();
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Row(
                children: [
                  Text(
                    selected.name,
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.primary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const Icon(Icons.keyboard_arrow_down, size: 18),
                ],
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.logout, size: 22),
            onPressed: () async {
              await Supabase.instance.client.auth.signOut();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: chat.messages.isEmpty && !chat.isLoading
                ? _EmptyState(onSuggestionTap: _send)
                : ListView(
                    controller: _scrollController,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    children: [
                      ...chat.messages.map((m) => _MessageBubble(message: m)),
                      if (chat.isThinking && chat.thinkingSteps.isNotEmpty)
                        _ThinkingBlock(steps: chat.thinkingSteps),
                      if (chat.streamingContent != null &&
                          chat.streamingContent!.isNotEmpty)
                        _StreamingBubble(content: chat.streamingContent!),
                    ],
                  ),
          ),
          if (chat.error != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: Text(
                chat.error!,
                style: const TextStyle(color: AppColors.error, fontSize: 13),
              ),
            ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.border),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _controller,
                        style: const TextStyle(color: AppColors.textPrimary),
                        minLines: 1,
                        maxLines: 5,
                        textInputAction: TextInputAction.send,
                        onSubmitted: (_) => _send(),
                        decoration: const InputDecoration(
                          hintText: 'Message JagX AI...',
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 14,
                          ),
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: chat.isLoading ? null : () => _send(),
                      icon: Icon(
                        Icons.arrow_upward_rounded,
                        color: chat.isLoading
                            ? AppColors.textTertiary
                            : AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ConversationsDrawer extends ConsumerWidget {
  const _ConversationsDrawer();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final conversations = ref.watch(conversationsProvider);

    return Drawer(
      backgroundColor: AppColors.surface,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Row(
                children: [
                  Text(
                    'Chats',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    tooltip: 'New chat',
                    icon: Icon(Icons.add, color: AppColors.primary),
                    onPressed: () {
                      ref.read(chatProvider.notifier).startNewChat();
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: conversations.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (_, __) => Center(
                  child: Text(
                    'Could not load chats',
                    style: TextStyle(color: AppColors.textTertiary),
                  ),
                ),
                data: (list) {
                  if (list.isEmpty) {
                    return Center(
                      child: Text(
                        'No conversations yet',
                        style: TextStyle(color: AppColors.textTertiary),
                      ),
                    );
                  }

                  return ListView.builder(
                    itemCount: list.length,
                    itemBuilder: (context, index) {
                      final conv = list[index];
                      return ListTile(
                        title: Text(
                          conv.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 14,
                          ),
                        ),
                        subtitle: conv.updatedAt != null
                            ? Text(
                                _formatDate(conv.updatedAt!),
                                style: TextStyle(
                                  color: AppColors.textTertiary,
                                  fontSize: 12,
                                ),
                              )
                            : null,
                        onTap: () {
                          ref.read(chatProvider.notifier).loadConversation(conv.id);
                          Navigator.of(context).pop();
                        },
                        trailing: IconButton(
                          icon: Icon(
                            Icons.delete_outline,
                            size: 18,
                            color: AppColors.textTertiary,
                          ),
                          onPressed: () {
                            ref.read(conversationsProvider.notifier).delete(conv.id);
                          },
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inDays == 0) return 'Today';
    if (diff.inDays == 1) return 'Yesterday';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return '${dt.day}/${dt.month}/${dt.year}';
  }
}

class _ThinkingBlock extends StatelessWidget {
  const _ThinkingBlock({required this.steps});

  final List<String> steps;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface.withOpacity(0.6),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              SizedBox(
                width: 14,
                height: 14,
                child: CircularProgressIndicator(
                  strokeWidth: 1.8,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'Thinking',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ...steps.map(
            (step) => Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Row(
                children: [
                  Icon(Icons.circle, size: 5, color: AppColors.textTertiary),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      step,
                      style: TextStyle(
                        color: AppColors.textTertiary,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StreamingBubble extends StatelessWidget {
  const _StreamingBubble({required this.content});

  final String content;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.8,
        ),
        decoration: BoxDecoration(
          color: AppColors.surfaceElevated,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
        ),
        child: Text(
          content,
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 15,
            height: 1.4,
          ),
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.onSuggestionTap});

  final void Function(String) onSuggestionTap;

  static const _suggestions = [
    'Draft a modern CV for a Flutter developer',
    'Design a product package for a Nigerian fintech app',
    'Generate image: premium dark UI dashboard',
    'Write a professional project proposal I can personalize',
    'Search the latest AI tools and summarize them',
  ];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const SizedBox(height: 40),
          Text(
            'Ask JagX AI anything.',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Pulse • Nova • Forge • Aether • Ember • Oracle',
            style: TextStyle(
              fontSize: 13,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 32),
          ..._suggestions.map((s) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: InkWell(
                onTap: () => onSuggestionTap(s),
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Text(
                    s,
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  const _MessageBubble({required this.message});

  final ChatMessage message;

  @override
  Widget build(BuildContext context) {
    final isUser = message.isUser;

    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.8,
        ),
        decoration: BoxDecoration(
          color: isUser ? AppColors.primary.withOpacity(0.12) : AppColors.surfaceElevated,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isUser ? AppColors.primary.withOpacity(0.25) : AppColors.border,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SelectableText(
              message.content,
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 15,
                height: 1.4,
              ),
            ),
            if (message.imageUrl != null) ...[
              const SizedBox(height: 10),
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  message.imageUrl!,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => const Text(
                    'Image failed to load',
                    style: TextStyle(color: AppColors.textTertiary),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
