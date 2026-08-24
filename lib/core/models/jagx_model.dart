enum JagxModelCategory {
  chat,
  vision,
  image,
  code,
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

/// Distinctive JagX model names shown only to the user.
/// Internal routing stays completely hidden.
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
      description: 'Deep reasoning & complex work',
      category: JagxModelCategory.chat,
    ),
    JagxModel(
      id: 'jagx-forge',
      name: 'Forge',
      description: 'Code, systems & technical mastery',
      category: JagxModelCategory.code,
    ),
    JagxModel(
      id: 'jagx-lens',
      name: 'Lens',
      description: 'Sees and understands images',
      category: JagxModelCategory.vision,
    ),
    JagxModel(
      id: 'jagx-canvas',
      name: 'Canvas',
      description: 'Creates high quality images',
      category: JagxModelCategory.image,
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
