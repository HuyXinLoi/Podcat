class Podcast {
  final String id;
  final String title;
  final String description;
  final String audioUrl;
  final String imageUrl;
  final String createdAt;
  final String userId;
  final String? categoryId;
  final String? categoryName;
  final List<String> tags;
  final int viewCount;
  final int likeCount;
  final int duration;
  final bool isLiked;

  Podcast({
    required this.id,
    required this.title,
    required this.description,
    required this.audioUrl,
    required this.imageUrl,
    required this.createdAt,
    required this.userId,
    this.categoryId,
    this.categoryName,
    this.tags = const [],
    this.viewCount = 0,
    this.likeCount = 0,
    this.duration = 0,
    this.isLiked = false,
  });

  factory Podcast.fromJson(Map<String, dynamic> json) {
    return Podcast(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      audioUrl: json['audioUrl'] ?? '',
      imageUrl: json['imageUrl'] ?? '',
      createdAt: json['createdAt'] ?? '',
      userId: json['userId'] ?? '',
      categoryId: json['categoryId'],
      categoryName: json['categoryName'],
      tags: json['tags'] != null ? List<String>.from(json['tags']) : [],
      viewCount: json['viewCount'] ?? 0,
      likeCount: json['likeCount'] ?? 0,
      duration: json['duration'] ?? 0,
      isLiked: json['isLiked'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'audioUrl': audioUrl,
      'imageUrl': imageUrl,
      'createdAt': createdAt,
      'userId': userId,
      'categoryId': categoryId,
      'categoryName': categoryName,
      'tags': tags,
      'viewCount': viewCount,
      'likeCount': likeCount,
      'duration': duration,
      'isLiked': isLiked,
    };
  }

  String get durationFormatted {
    final minutes = (duration / 60).floor();
    final seconds = duration % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }

  Podcast copyWith({
    String? id,
    String? title,
    String? description,
    String? audioUrl,
    String? imageUrl,
    String? createdAt,
    String? userId,
    String? categoryId,
    String? categoryName,
    List<String>? tags,
    int? viewCount,
    int? likeCount,
    int? duration,
    bool? isLiked,
  }) {
    return Podcast(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      audioUrl: audioUrl ?? this.audioUrl,
      imageUrl: imageUrl ?? this.imageUrl,
      createdAt: createdAt ?? this.createdAt,
      userId: userId ?? this.userId,
      categoryId: categoryId ?? this.categoryId,
      categoryName: categoryName ?? this.categoryName,
      tags: tags ?? this.tags,
      viewCount: viewCount ?? this.viewCount,
      likeCount: likeCount ?? this.likeCount,
      duration: duration ?? this.duration,
      isLiked: isLiked ?? this.isLiked,
    );
  }
}
