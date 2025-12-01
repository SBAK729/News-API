import 'package:flutter/material.dart';
import 'package:news/screens/news_detail_screen.dart';
import 'package:provider/provider.dart';
import '../providers/news_provider.dart';
import '../widgets/news_card.dart';

class BookmarksScreen extends StatelessWidget {
  const BookmarksScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bookmarks'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Consumer<NewsProvider>(
        builder: (context, newsProvider, child) {
          if (newsProvider.bookmarkedArticles.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.bookmark_border, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'No bookmarks yet',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Tap the bookmark icon to save articles',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            itemCount: newsProvider.bookmarkedArticles.length,
            itemBuilder: (context, index) {
              final article = newsProvider.bookmarkedArticles[index];
              return NewsCard(
                article: article,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => NewsDetailScreen(article: article),
                    ),
                  );
                },
                onBookmark: () {
                  newsProvider.toggleBookmark(article);
                },
                isBookmarked: true,
              );
            },
          );
        },
      ),
    );
  }
}
