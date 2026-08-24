import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/chat_repository.dart';
import 'chat_provider.dart';

final conversationsProvider =
    StateNotifierProvider<ConversationsNotifier, AsyncValue<List<Conversation>>>((ref) {
  final repo = ref.watch(chatRepositoryProvider);
  return ConversationsNotifier(repo);
});

class ConversationsNotifier extends StateNotifier<AsyncValue<List<Conversation>>> {
  ConversationsNotifier(this._repo) : super(const AsyncValue.loading()) {
    load();
  }

  final ChatRepository _repo;

  Future<void> load() async {
    state = const AsyncValue.loading();
    try {
      final list = await _repo.fetchConversations();
      state = AsyncValue.data(list);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> refresh() => load();

  Future<void> delete(String id) async {
    try {
      await _repo.deleteConversation(id);
      await load();
    } catch (_) {}
  }
}
