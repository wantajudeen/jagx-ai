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

/// Only these names are ever shown to the user.
/// Internal routing to OpenRouter / Nvidia / etc. happens in the service layer.
class JagxModels {
  static const List<JagxModel> all = [
    JagxModel(
      id: 'jagx-core',
      name: 'JagX Core',
      description: 'Fast general intelligence',
      category: JagxModelCategory.chat,
      isDefault: true,
    ),
    JagxModel(
      id: 'jagx-pro',
      name: 'JagX Pro',
      description: 'Deep reasoning & complex tasks',
      category: JagxModelCategory.chat,
    ),
    JagxModel(
      id: 'jagx-code',
      name: 'JagX Code',
      description: 'Specialized for code & technical work',
      category: JagxModelCategory.code,
    ),
    JagxModel(
      id: 'jagx-vision',
      name: 'JagX Vision',
      description: 'Understands images and documents',
      category: JagxModelCategory.vision,
    ),
    JagxModel(
      id: 'jagx-image',
      name: 'JagX Image',
      description: 'Generate high quality images',
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
