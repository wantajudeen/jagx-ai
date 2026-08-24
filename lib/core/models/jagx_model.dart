enum JagxModelCategory {
  chat,
  code,
  vision,
  image,
  agent,
}

class JagxModel {
  const JagxModel({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    this.isDefault = false,
  });

  final String id;
  final String name;
  final String description;
  final JagxModelCategory category;
  final bool isDefault;
}

/// Fully unique JagX model names. Never generic.
class JagxModels {
  static const List<JagxModel> all = [
    JagxModel(
      id: 'jagx-pulse',
      name: 'Pulse',
      description: 'Fast everyday intelligence',
      category: JagxModelCategory.chat,
      isDefault: true,
    ),
    JagxModel(
      id: 'jagx-nova',
      name: 'Nova',
      description: 'Deep reasoning & complex thinking',
      category: JagxModelCategory.chat,
    ),
    JagxModel(
      id: 'jagx-forge',
      name: 'Forge',
      description: 'Code, systems & technical mastery',
      category: JagxModelCategory.code,
    ),
    JagxModel(
      id: 'jagx-aether',
      name: 'Aether',
      description: 'Sees images, documents & the world',
      category: JagxModelCategory.vision,
    ),
    JagxModel(
      id: 'jagx-ember',
      name: 'Ember',
      description: 'Creates stunning images',
      category: JagxModelCategory.image,
    ),
    JagxModel(
      id: 'jagx-oracle',
      name: 'Oracle',
      description: 'Does everything — search, reason, code, create',
      category: JagxModelCategory.agent,
    ),
  ];

  static JagxModel get defaultModel =>
      all.firstWhere((m) => m.isDefault, orElse: () => all.first);

  static JagxModel? byId(String id) {
    try {
      return all.firstWhere((m) => m.id == id);
    } catch (_) {
      return null;
    }
  }
}
