class User {
  final String id;
  final String username;
  final String? name;
  final String? bio;
  final String? avatarUrl;
  final int podcastCount;
  final int playlistCount;

  User({
    required this.id,
    required this.username,
    this.name,
    this.bio,
    this.avatarUrl,
    this.podcastCount = 0,
    this.playlistCount = 0,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? '',
      username: json['username'] ?? '',
      name: json['name'],
      bio: json['bio'],
      avatarUrl: json['avatarUrl'],
      podcastCount: json['podcastCount'] ?? 0,
      playlistCount: json['playlistCount'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'name': name,
      'bio': bio,
      'avatarUrl': avatarUrl,
      'podcastCount': podcastCount,
      'playlistCount': playlistCount,
    };
  }

  User copyWith({
    String? id,
    String? username,
    String? name,
    String? bio,
    String? avatarUrl,
    int? podcastCount,
    int? playlistCount,
  }) {
    return User(
      id: id ?? this.id,
      username: username ?? this.username,
      name: name ?? this.name,
      bio: bio ?? this.bio,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      podcastCount: podcastCount ?? this.podcastCount,
      playlistCount: playlistCount ?? this.playlistCount,
    );
  }
}
