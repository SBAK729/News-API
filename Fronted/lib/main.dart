import 'package:flutter/material.dart';
import 'package:news/models/news_model.dart';
import 'package:news/screens/home_screen.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'providers/news_provider.dart';
import 'providers/auth_provider.dart';
import 'providers/theme_provider.dart';
import 'screens/search_screen.dart';
import 'screens/bookmarks_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/news_detail_screen.dart';
import 'theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize shared preferences
  final SharedPreferences prefs = await SharedPreferences.getInstance();

  runApp(MyApp(prefs: prefs));
}

class MyApp extends StatelessWidget {
  final SharedPreferences prefs;

  const MyApp({Key? key, required this.prefs}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<ThemeProvider>(
          create: (context) => ThemeProvider(),
        ),
        ChangeNotifierProvider<AuthProvider>(
          create: (context) {
            final authProvider = AuthProvider();
            authProvider.initialize(prefs);
            return authProvider;
          },
        ),
        ChangeNotifierProvider<NewsProvider>(
          create: (context) => NewsProvider(),
        ),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp(
            title: 'News Hub Ultra',
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeProvider.themeMode,
            initialRoute: '/',
            routes: {
              '/': (context) => const ModernHomeScreen(),
              '/search': (context) => const SearchScreen(),
              '/bookmarks': (context) => const BookmarksScreen(),
              '/settings': (context) => const SettingsScreen(), 
              '/news_detail': (context) {
                final article =
                    ModalRoute.of(context)!.settings.arguments as NewsArticle;
                return NewsDetailScreen(article: article);
              },
            },
            debugShowCheckedModeBanner: false,
          );
        },
      ),
    );
  }
}
