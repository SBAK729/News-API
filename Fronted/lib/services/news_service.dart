import '../config/api_config.dart';
import '../models/news_model.dart';
import 'api_service.dart';
import '../utils/logger.dart';

class NewsService {
  final ApiService _apiService = ApiService();

  Future<List<NewsArticle>> getTopHeadlines({String? country, String? category}) async {
    final List<NewsArticle> allArticles = [];

    // Try NewsAPI first (fastest for headlines)
    if (ApiConfig.isNewsApiConfigured) {
      try {
        final Map<String, dynamic> params = {
          'country': country ?? 'us',
          if (category != null) 'category': category,
        };

        final data = await _apiService.getNewsApiData(ApiConfig.topHeadlines, params);
        
        if (data['status'] == 'ok') {
          final List<dynamic> articles = data['articles'];
          final newsApiArticles = articles.map((article) => NewsArticle.fromNewsApi(article)).toList();
          allArticles.addAll(newsApiArticles);
          AppLogger.dataSuccess('Fetched ${newsApiArticles.length} headlines from NewsAPI');
        }
      } catch (e) {
        AppLogger.apiError('NewsAPI getTopHeadlines', e.toString());
      }
    }

    // Try NewsData.io for international coverage
    if (ApiConfig.isNewsDataConfigured && allArticles.length < 10) {
      try {
        final Map<String, dynamic> params = {
          'country': country ?? 'us',
          if (category != null) 'category': category,
        };

        final data = await _apiService.getNewsDataIo(ApiConfig.newsDataLatest, params);
        
        if (data['status'] == 'success') {
          final List<dynamic> results = data['results'];
          final newsDataArticles = results.map((result) => NewsArticle.fromNewsApi(result)).toList();
          allArticles.addAll(newsDataArticles);
          AppLogger.dataSuccess('Fetched ${newsDataArticles.length} headlines from NewsData.io');
        }
      } catch (e) {
        AppLogger.apiError('NewsData.io getTopHeadlines', e.toString());
      }
    }

    // Fallback to Guardian API for quality journalism
    if (ApiConfig.isGuardianConfigured && allArticles.length < 5) {
      try {
        final Map<String, dynamic> params = {
          'section': _mapCategoryToGuardian(category),
        };

        final data = await _apiService.getGuardianData(ApiConfig.guardianNews, params);
        
        if (data['response']['status'] == 'ok') {
          final List<dynamic> results = data['response']['results'];
          final guardianArticles = results.map((result) => NewsArticle.fromGuardianApi(result)).toList();
          allArticles.addAll(guardianArticles);
          AppLogger.dataSuccess('Fetched ${guardianArticles.length} headlines from Guardian');
        }
      } catch (e) {
        AppLogger.apiError('Guardian getTopHeadlines', e.toString());
      }
    }

    if (allArticles.isEmpty) {
      throw Exception('No articles found from any API service');
    }

    // Remove duplicates and sort by date (newest first)
    final uniqueArticles = _removeDuplicates(allArticles);
    uniqueArticles.sort((a, b) => b.publishedAt.compareTo(a.publishedAt));
    
    AppLogger.dataSuccess('Total unique articles: ${uniqueArticles.length}');
    return uniqueArticles;
  }

  Future<List<NewsArticle>> searchNews(String query, {String? language, String? sortBy}) async {
    final List<NewsArticle> allResults = [];

    // Search from all available APIs concurrently
    final List<Future> searches = [];

    if (ApiConfig.isNewsApiConfigured) {
      searches.add(_searchNewsApi(query, language, sortBy).then((articles) {
        allResults.addAll(articles);
      }));
    }

    if (ApiConfig.isGuardianConfigured) {
      searches.add(_searchGuardian(query).then((articles) {
        allResults.addAll(articles);
      }));
    }

    if (ApiConfig.isNewsDataConfigured) {
      searches.add(_searchNewsDataIo(query).then((articles) {
        allResults.addAll(articles);
      }));
    }

    // Wait for all searches to complete
    await Future.wait(searches, eagerError: false);

    if (allResults.isEmpty) {
      throw Exception('No results found for "$query"');
    }

    // Remove duplicates and sort
    final uniqueResults = _removeDuplicates(allResults);
    uniqueResults.sort((a, b) => b.publishedAt.compareTo(a.publishedAt));
    
    AppLogger.dataSuccess('Found ${uniqueResults.length} unique results for "$query"');
    return uniqueResults;
  }

  Future<List<NewsArticle>> _searchNewsApi(String query, String? language, String? sortBy) async {
    try {
      final Map<String, dynamic> params = {
        'q': query,
        'language': language ?? 'en',
        'sortBy': sortBy ?? 'publishedAt',
      };

      final data = await _apiService.getNewsApiData(ApiConfig.everything, params);
      
      if (data['status'] == 'ok') {
        final List<dynamic> articles = data['articles'];
        return articles.map((article) => NewsArticle.fromNewsApi(article)).toList();
      }
    } catch (e) {
      AppLogger.apiError('NewsAPI search', e.toString());
    }
    return [];
  }

  Future<List<NewsArticle>> _searchGuardian(String query) async {
    try {
      final Map<String, dynamic> params = {
        'q': query,
      };

      final data = await _apiService.getGuardianData(ApiConfig.guardianNews, params);
      
      if (data['response']['status'] == 'ok') {
        final List<dynamic> results = data['response']['results'];
        return results.map((result) => NewsArticle.fromGuardianApi(result)).toList();
      }
    } catch (e) {
      AppLogger.apiError('Guardian search', e.toString());
    }
    return [];
  }

  Future<List<NewsArticle>> _searchNewsDataIo(String query) async {
    try {
      final Map<String, dynamic> params = {
        'q': query,
      };

      final data = await _apiService.getNewsDataIo(ApiConfig.newsDataLatest, params);
      
      if (data['status'] == 'success') {
        final List<dynamic> results = data['results'];
        return results.map((result) => NewsArticle.fromNewsApi(result)).toList();
      }
    } catch (e) {
      AppLogger.apiError('NewsData.io search', e.toString());
    }
    return [];
  }
  
  // Add this method to the NewsService class
Future<List<NewsArticle>> getGuardianNews({String? section}) async {
  if (!ApiConfig.isGuardianConfigured) {
    throw Exception('Guardian API is not configured.');
  }

  try {
    final Map<String, dynamic> params = {
      if (section != null) 'section': section,
      'show-fields': 'thumbnail,trailText,body', // Request more fields
    };

    final data = await _apiService.getGuardianData(ApiConfig.guardianNews, params);
    
    if (data['response']['status'] == 'ok') {
      final List<dynamic> results = data['response']['results'];
      AppLogger.dataSuccess('Fetched ${results.length} Guardian articles');
      return results.map((result) => NewsArticle.fromGuardianApi(result)).toList();
    } else {
      throw Exception('Guardian API returned error');
    }
  } catch (e) {
    AppLogger.apiError('getGuardianNews', e.toString());
    rethrow;
  }
}
  Future<List<NewsArticle>> getInternationalNews({String? country}) async {
    if (!ApiConfig.isNewsDataConfigured) {
      throw Exception('NewsData.io is not configured for international news.');
    }

    try {
      final Map<String, dynamic> params = {
        if (country != null) 'country': country,
      };

      final data = await _apiService.getNewsDataIo(ApiConfig.newsDataLatest, params);
      
      if (data['status'] == 'success') {
        final List<dynamic> results = data['results'];
        AppLogger.dataSuccess('Fetched ${results.length} international articles from NewsData.io');
        return results.map((result) => NewsArticle.fromNewsApi(result)).toList();
      } else {
        throw Exception('NewsData.io returned error: ${data['message']}');
      }
    } catch (e) {
      AppLogger.apiError('getInternationalNews', e.toString());
      rethrow;
    }
  }

  // Helper method to map categories between APIs
  String? _mapCategoryToGuardian(String? category) {
    const categoryMap = {
      'general': null,
      'business': 'business',
      'technology': 'technology',
      'entertainment': 'culture',
      'sports': 'sport',
      'science': 'science',
      'health': 'society',
    };
    return categoryMap[category];
  }

  // Remove duplicate articles based on URL
  List<NewsArticle> _removeDuplicates(List<NewsArticle> articles) {
    final seenUrls = <String>{};
    return articles.where((article) {
      if (seenUrls.contains(article.url)) {
        return false;
      }
      seenUrls.add(article.url);
      return true;
    }).toList();
  }

  // Get available news sources
  List<String> getAvailableSources() {
    final sources = <String>[];
    if (ApiConfig.isNewsApiConfigured) sources.add('NewsAPI');
    if (ApiConfig.isGuardianConfigured) sources.add('The Guardian');
    if (ApiConfig.isNewsDataConfigured) sources.add('NewsData.io');
    return sources;
  }

  // Get API usage statistics
  Map<String, dynamic> getApiStats() {
    return {
      'totalSources': getAvailableSources().length,
      'dailyRequestsAvailable': ApiConfig.totalDailyRequests,
      'sources': getAvailableSources(),
      'status': ApiConfig.apiStatus,
    };
  }
}
