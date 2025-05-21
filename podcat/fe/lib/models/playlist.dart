class Playlist {
  final String id;
  final String name;
  final String userId;
  final Set<String> podcastIds;

  Playlist({
    required this.id,
    required this.name,
    required this.userId,
    this.podcastIds = const {},
  });

  factory Playlist.fromJson(Map<String, dynamic> json) {
    return Playlist(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      userId: json['userId'] ?? '',
      podcastIds: json['podcastIds'] != null
          ? Set<String>.from(json['podcastIds'])
          : {},
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'userId': userId,
      'podcastIds': podcastIds.toList(),
    };
  }

  Playlist copyWith({
    String? id,
    String? name,
    String? userId,
    Set<String>? podcastIds,
  }) {
    return Playlist(
      id: id ?? this.id,
      name: name ?? this.name,
      userId: userId ?? this.userId,
      podcastIds: podcastIds ?? this.podcastIds,
    );
  }
}
