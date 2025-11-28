
class NewsArticle {
  final String? id;
  final String title;
  final String? description;
  final String? content;
  final String? author;
  final String url;
  final String? urlToImage;
  final DateTime publishedAt;
  final String source;
  final String? category;
  final bool isBookmarked;
  final int? readTime; // NEW: Estimated read time

  NewsArticle({
    this.id,
    required this.title,
    this.description,
    this.content,
    this.author,
    required this.url,
    this.urlToImage,
    required this.publishedAt,
    required this.source,
    this.category,
    this.isBookmarked = false,
    this.readTime,
  });

  factory NewsArticle.fromNewsApi(Map<String, dynamic> json) {
    final content = json['content'] ?? '';
    final estimatedReadTime = _calculateReadTime(content);
    
    return NewsArticle(
      id: json['url'] as String?,
      title: json['title'] ?? 'No Title',
      description: json['description'] ?? '',
      content: content,
      author: json['author'] ?? 'Unknown',
      url: json['url'] ?? '',
      urlToImage: json['urlToImage'],
      publishedAt: DateTime.parse(json['publishedAt'] ?? DateTime.now().toString()),
      source: (json['source'] is Map ? json['source']['name'] : json['source']) ?? 'Unknown Source',
      readTime: estimatedReadTime,
    );
  }

  factory NewsArticle.fromGuardianApi(Map<String, dynamic> json) {
    final fields = json['fields'] ?? {};
    final content = fields['body'] ?? '';
    final estimatedReadTime = _calculateReadTime(content);
    
    return NewsArticle(
      id: json['id'] as String?,
      title: json['webTitle'] ?? 'No Title',
      description: fields['trailText'] ?? '',
      content: content,
      url: json['webUrl'] ?? '',
      urlToImage: fields['thumbnail'],
      publishedAt: DateTime.parse(json['webPublicationDate'] ?? DateTime.now().toString()),
      source: 'The Guardian',
      category: json['sectionName'] ?? 'General',
      readTime: estimatedReadTime,
    );
  }

  // Calculate estimated read time (approx 200 words per minute)
  static int _calculateReadTime(String content) {
    final wordCount = content.split(RegExp(r'\s+')).length;
    return (wordCount / 200).ceil();
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'content': content,
      'author': author,
      'url': url,
      'urlToImage': urlToImage,
      'publishedAt': publishedAt.toIso8601String(),
      'source': source,
      'category': category,
      'isBookmarked': isBookmarked,
      'readTime': readTime,
    };
  }
}
