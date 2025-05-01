class Category {
  final String id;
  final String name;
  final String? description;
  final String? imageUrl;
  final int podcastCount;

  Category({
    required this.id,
    required this.name,
    this.description,
    this.imageUrl,
    this.podcastCount = 0,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'],
      imageUrl: json['imageUrl'],
      podcastCount: json['podcastCount'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'imageUrl': imageUrl,
      'podcastCount': podcastCount,
    };
  }

  Category copyWith({
    String? id,
    String? name,
    String? description,
    String? imageUrl,
    int? podcastCount,
  }) {
    return Category(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      podcastCount: podcastCount ?? this.podcastCount,
    );
  }
}
