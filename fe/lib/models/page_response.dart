class PageResponse<T> {
  final List<T> content;
  final int page;
  final int size;
  final int totalElements;
  final int totalPages;

  PageResponse({
    required this.content,
    required this.page,
    required this.size,
    required this.totalElements,
    required this.totalPages,
  });

  factory PageResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic>) fromJsonT,
  ) {
    final List<dynamic> contentJson = json['content'] ?? [];
    final List<T> content = contentJson
        .map((item) => fromJsonT(item as Map<String, dynamic>))
        .toList();

    return PageResponse<T>(
      content: content,
      page: json['page'] ?? 0,
      size: json['size'] ?? 0,
      totalElements: json['totalElements'] ?? 0,
      totalPages: json['totalPages'] ?? 0,
    );
  }

  PageResponse<T> copyWith({
    List<T>? content,
    int? page,
    int? size,
    int? totalElements,
    int? totalPages,
  }) {
    return PageResponse<T>(
      content: content ?? this.content,
      page: page ?? this.page,
      size: size ?? this.size,
      totalElements: totalElements ?? this.totalElements,
      totalPages: totalPages ?? this.totalPages,
    );
  }
}
