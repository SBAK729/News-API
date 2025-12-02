import 'package:flutter/material.dart';
import 'package:news/screens/news_detail_screen.dart';
import 'package:provider/provider.dart';
import '../providers/news_provider.dart';
import '../widgets/news_card.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({Key? key}) : super(key: key);

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  late NewsProvider _newsProvider;

  @override
  void initState() {
    super.initState();
    _newsProvider = context.read<NewsProvider>();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.blueAccent,
        title: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.15),
            borderRadius: BorderRadius.circular(8),
          ),
          child: TextField(
            controller: _searchController,
            cursorColor: Colors.white,
            decoration: const InputDecoration(
              hintText: 'Search news...',
              hintStyle: TextStyle(color: Colors.white70),
              border: InputBorder.none,
              icon: Icon(Icons.search, color: Colors.white),
            ),
            style: const TextStyle(color: Colors.white),
            onSubmitted: (query) {
              if (query.isNotEmpty) {
                _newsProvider.searchNews(query);
              }
            },
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.clear),
            onPressed: () {
              _searchController.clear();
              _newsProvider.clearSearch();
            },
          ),
        ],
      ),

      body: Consumer<NewsProvider>(
        builder: (context, newsProvider, child) {
          if (newsProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (newsProvider.errorMessage.isNotEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: 70,
                      color: Colors.red,
                    ),
                    const SizedBox(height: 20),
                    Text(
                      newsProvider.errorMessage,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 18,
                        color: Colors.black54,
                      ),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {
                        newsProvider.searchNews(_searchController.text);
                      },
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            );
          }

          if (newsProvider.articles.isEmpty) {
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.search, size: 80, color: Colors.grey.shade400),
                const SizedBox(height: 16),
                Text(
                  'Search for news articles',
                  style: TextStyle(fontSize: 18, color: Colors.grey.shade600),
                ),
              ],
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
            itemCount: newsProvider.articles.length,
            itemBuilder: (context, index) {
              final article = newsProvider.articles[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: NewsCard(
                  article: article,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            NewsDetailScreen(article: article),
                      ),
                    );
                  },
                  onBookmark: () {
                    newsProvider.toggleBookmark(article);
                  },
                  isBookmarked: newsProvider.isBookmarked(article),
                ),
              );
            },
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
