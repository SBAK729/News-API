import 'package:flutter/foundation.dart';
import '../models/news_model.dart';
import '../services/news_service.dart';
import '../utils/logger.dart';

class NewsProvider with ChangeNotifier {
  final NewsService _newsService = NewsService();
  
  // State variables
  List<NewsArticle> _articles = [];
  List<NewsArticle> _bookmarkedArticles = [];
  bool _isLoading = false;
  String _errorMessage = '';
  String _currentCategory = 'general';
  String _searchQuery = '';

  // Getters
  List<NewsArticle> get articles => _articles;
  List<NewsArticle> get bookmarkedArticles => _bookmarkedArticles;
  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;
  String get currentCategory => _currentCategory;
  String get searchQuery => _searchQuery;

  // Check if article is bookmarked
  bool isBookmarked(NewsArticle article) {
    return _bookmarkedArticles.any((bookmark) => bookmark.id == article.id);
  }

  // Toggle bookmark
  void toggleBookmark(NewsArticle article) {
    try {
      if (isBookmarked(article)) {
        _bookmarkedArticles.removeWhere((item) => item.id == article.id);
        AppLogger.userAction('Removed bookmark: ${article.title}');
      } else {
        _bookmarkedArticles.add(article);
        AppLogger.userAction('Added bookmark: ${article.title}');
      }
      notifyListeners();
    } catch (e) {
      AppLogger.apiError('Bookmark Toggle', e.toString());
      _errorMessage = 'Failed to update bookmark';
      notifyListeners();
    }
  }

  // Fetch top headlines (uses all available APIs)
  Future<void> fetchTopHeadlines({String? country, String? category}) async {
    try {
      _isLoading = true;
      _errorMessage = '';
      _currentCategory = category ?? 'general';
      notifyListeners();

      AppLogger.networkCall('Fetching headlines for category: $_currentCategory');
      
      final articles = await _newsService.getTopHeadlines(
        country: country ?? 'us',
        category: category,
      );

      _articles = articles;
      AppLogger.dataSuccess('Fetched ${articles.length} headlines from all APIs');
    } catch (e) {
      _errorMessage = 'Failed to load headlines: ${e.toString()}';
      AppLogger.apiError('Headlines Fetch', e.toString());
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Search news across all APIs
  Future<void> searchNews(String query) async {
    try {
      _isLoading = true;
      _errorMessage = '';
      _searchQuery = query;
      notifyListeners();

      AppLogger.networkCall('Searching news for: $query');
      
      if (query.isEmpty) {
        await fetchTopHeadlines();
        return;
      }

      final articles = await _newsService.searchNews(query);
      _articles = articles;
      AppLogger.dataSuccess('Found ${articles.length} results for "$query"');
    } catch (e) {
      _errorMessage = 'Search failed: ${e.toString()}';
      AppLogger.apiError('News Search', e.toString());
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Fetch international news (uses NewsData.io)
  Future<void> fetchInternationalNews({String? country}) async {
    try {
      _isLoading = true;
      _errorMessage = '';
      notifyListeners();

      AppLogger.networkCall('Fetching international news for country: $country');
      
      final articles = await _newsService.getInternationalNews(country: country);
      _articles = articles;
      AppLogger.dataSuccess('Fetched ${articles.length} international articles');
    } catch (e) {
      _errorMessage = 'Failed to load international news: ${e.toString()}';
      AppLogger.apiError('International News Fetch', e.toString());
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Get API statistics
  Map<String, dynamic> getApiStats() {
    return _newsService.getApiStats();
  }

  // Get available news sources
  List<String> getAvailableSources() {
    return _newsService.getAvailableSources();
  }

  // Refresh data
  Future<void> refreshData() async {
    if (_searchQuery.isNotEmpty) {
      await searchNews(_searchQuery);
    } else {
      await fetchTopHeadlines(category: _currentCategory);
    }
  }

  // Clear error
  void clearError() {
    _errorMessage = '';
    notifyListeners();
  }

  // Clear search
  void clearSearch() {
    _searchQuery = '';
    notifyListeners();
  }

  // Load sample data for demo (fallback when APIs fail)
  void loadSampleData() {
    _isLoading = true;
    notifyListeners();

    // Sample articles for demo purposes
    _articles = [
      NewsArticle(
        title: 'Breaking: Flutter 3.0 Released with New Features',
        description: 'Google announces major update to Flutter framework with performance improvements and new widgets.',
        url: 'https://flutter.dev',
        urlToImage: 'https://images.unsplash.com/photo-1551650975-87deedd944c3?w=500',
        publishedAt: DateTime.now().subtract(const Duration(hours: 2)),
        source: 'Tech News',
        author: 'Tech Reporter',
      ),
      NewsArticle(
        title: 'Global Climate Summit Reaches New Agreement',
        description: 'World leaders agree on ambitious climate targets at the latest international summit.',
        url: 'https://example.com/climate',
        urlToImage: 'https://images.unsplash.com/photo-1569163139394-de4e4f43e4e3?w=500',
        publishedAt: DateTime.now().subtract(const Duration(hours: 5)),
        source: 'World News',
        author: 'Environmental Correspondent',
      ),
      NewsArticle(
        title: 'Stock Markets Reach All-Time High',
        description: 'Major indices surge as investor confidence grows in economic recovery.',
        url: 'https://example.com/stocks',
        urlToImage: 'https://images.unsplash.com/photo-1590283603385-17ffb3a7f29f?w=500',
        publishedAt: DateTime.now().subtract(const Duration(hours: 8)),
        source: 'Business Daily',
        author: 'Financial Analyst',
      ),
    ];

    _isLoading = false;
    _errorMessage = '';
    notifyListeners();
  }
}
