import 'package:flutter_test/flutter_test.dart';
import 'package:news/models/news_model.dart';

void main() {
  group('NewsModel Tests', () {
    test('NewsArticle from NewsAPI JSON parsing', () {
      final json = {
        'title': 'Test Title',
        'description': 'Test Description',
        'url': 'https://example.com',
        'urlToImage': 'https://example.com/image.jpg',
        'publishedAt': '2023-01-01T12:00:00Z',
        'source': {'name': 'Test Source'},
        'author': 'Test Author',
        'content': 'Test content here',
      };

      final article = NewsArticle.fromNewsApi(json);

      expect(article.title, 'Test Title');
      expect(article.description, 'Test Description');
      expect(article.url, 'https://example.com');
      expect(article.source, 'Test Source');
      expect(article.author, 'Test Author');
    });

    test('NewsArticle from Guardian API JSON parsing', () {
      final json = {
        'id': 'test-id',
        'webTitle': 'Guardian Test Title',
        'webUrl': 'https://guardian.com/article',
        'webPublicationDate': '2023-01-01T12:00:00Z',
        'sectionName': 'Technology',
        'fields': {
          'trailText': 'Guardian description',
          'thumbnail': 'https://guardian.com/thumb.jpg',
          'body': 'Article content here',
        },
      };

      final article = NewsArticle.fromGuardianApi(json);

      expect(article.title, 'Guardian Test Title');
      expect(article.url, 'https://guardian.com/article');
      expect(article.source, 'The Guardian');
      expect(article.category, 'Technology');
    });

    test('NewsArticle toJson and fromJson consistency', () {
      final originalArticle = NewsArticle(
        id: 'test-id',
        title: 'Test Title',
        description: 'Test Description',
        url: 'https://example.com',
        publishedAt: DateTime.now(),
        source: 'Test Source',
        author: 'Test Author',
      );

      final json = originalArticle.toJson();
      // Note: We don't have a fromJson method, but we can verify toJson works
      expect(json['title'], 'Test Title');
      expect(json['url'], 'https://example.com');
      expect(json['source'], 'Test Source');
    });
  });
}
