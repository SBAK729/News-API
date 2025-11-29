class ApiConfig {
  static const String newsApiKey = '2eea7430e7b14658bb539a0a72e02a77';
  static const String newsApiBaseUrl = 'https://newsapi.org/v2';

  static const String guardianApiKey = 'a16b56cc-80aa-4b4a-87c7-cbc34edec5f9';
  static const String guardianBaseUrl = 'https://content.guardianapis.com';

  static const String newsDataApiKey = 'pub_220b925229d14e6dbc3808eb86e3667b';
  static const String newsDataBaseUrl = 'https://newsdata.io/api/1';

  // Endpoints
  static const String topHeadlines = '$newsApiBaseUrl/top-headlines';
  static const String everything = '$newsApiBaseUrl/everything';
  static const String guardianNews = '$guardianBaseUrl/search';
  static const String newsDataLatest = '$newsDataBaseUrl/latest';

  // Timeouts
  static const int connectTimeout = 30000;
  static const int receiveTimeout = 30000;

  // API Status Check
  static bool get isNewsApiConfigured =>
      newsApiKey.isNotEmpty &&
      newsApiKey != 'YOUR_NEWSAPI_KEY_HERE' &&
      newsApiKey.length > 10;

  static bool get isGuardianConfigured =>
      guardianApiKey.isNotEmpty &&
      guardianApiKey != 'YOUR_GUARDIAN_KEY_HERE' &&
      guardianApiKey.length > 10;

  static bool get isNewsDataConfigured =>
      newsDataApiKey.isNotEmpty &&
      newsDataApiKey != 'YOUR_NEWSDATA_KEY_HERE' &&
      newsDataApiKey.length > 10;

  static bool get hasValidConfiguration =>
      isNewsApiConfigured || isGuardianConfigured || isNewsDataConfigured;

  // Get API status for debugging
  static Map<String, dynamic> get apiStatus {
    return {
      'newsApi': {
        'configured': isNewsApiConfigured,
        'keyLength': newsApiKey.length,
        'keyPreview': '${newsApiKey.substring(0, 8)}...',
        'requestsLeft': '100/day (free tier)',
      },
      'guardianApi': {
        'configured': isGuardianConfigured,
        'keyLength': guardianApiKey.length,
        'keyPreview': '${guardianApiKey.substring(0, 8)}...',
        'requestsLeft': '5000/day (free tier)',
      },
      'newsDataApi': {
        'configured': isNewsDataConfigured,
        'keyLength': newsDataApiKey.length,
        'keyPreview': '${newsDataApiKey.substring(0, 8)}...',
        'requestsLeft': '200/day (free tier)',
      },
    };
  }

  // Get total daily requests available
  static int get totalDailyRequests {
    int total = 0;
    if (isNewsApiConfigured) total += 100;
    if (isGuardianConfigured) total += 5000;
    if (isNewsDataConfigured) total += 200;
    return total;
  }
}
