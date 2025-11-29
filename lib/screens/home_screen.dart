import 'package:flutter/material.dart';
import 'package:news/screens/news_detail_screen.dart';
import 'package:provider/provider.dart';
import '../providers/news_provider.dart';
import '../providers/theme_provider.dart';
import '../widgets/modern_news_card.dart';
import '../widgets/featured_news_card.dart';
import '../widgets/loading_shimmer.dart';
import '../theme/app_theme.dart';

class ModernHomeScreen extends StatefulWidget {
  const ModernHomeScreen({Key? key}) : super(key: key);

  @override
  State<ModernHomeScreen> createState() => _ModernHomeScreenState();
}

class _ModernHomeScreenState extends State<ModernHomeScreen> {
  final List<String> categories = [
    'general', 'business', 'technology', 'entertainment', 
    'sports', 'science', 'health', 'politics', 'travel'
  ];
  String selectedCategory = 'general';
  final ScrollController _scrollController = ScrollController();
  final PageController _featuredController = PageController(viewportFraction: 0.85);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<NewsProvider>().fetchTopHeadlines(category: selectedCategory);
    });
  }

  @override
  void dispose() {
    _featuredController.dispose();
    super.dispose();
  }

  void _navigateToDetailScreen(BuildContext context, dynamic article) {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => NewsDetailScreen(article: article),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(1.0, 0.0);
          const end = Offset.zero;
          const curve = Curves.easeInOut;
          
          var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
          var offsetAnimation = animation.drive(tween);
          
          return SlideTransition(
            position: offsetAnimation,
            child: child,
          );
        },
        transitionDuration: const Duration(milliseconds: 300),
      ),
    );
  }

  void _navigateToSettings(BuildContext context) {
    Navigator.pushNamed(context, '/settings');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: CustomScrollView(
        controller: _scrollController,
        physics: const BouncingScrollPhysics(),
        slivers: [
          // Modern App Bar with Enhanced Design - FIXED: Column overflow
          SliverAppBar(
            expandedHeight: 130, // Reduced from 140
            floating: false,
            pinned: true,
            backgroundColor: theme.appBarTheme.backgroundColor,
            elevation: 0,
            flexibleSpace: FlexibleSpaceBar(
              centerTitle: false,
              titlePadding: const EdgeInsets.only(left: 24, bottom: 12), // Reduced bottom padding
              title: Container( // FIX: Wrap with Container to constrain height
                constraints: const BoxConstraints(maxHeight: 40),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center, // Center content vertically
                  children: [
                    Text(
                      _getGreeting(),
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.textTheme.bodyMedium?.color?.withOpacity(0.8),
                        fontSize: 11, // Reduced from 12
                        fontWeight: FontWeight.w500,
                        height: 1.0, // Fixed line height
                      ),
                    ),
                    const SizedBox(height: 1), // Reduced from 2
                    Text(
                      'News Hub',
                      style: theme.textTheme.displayMedium?.copyWith(
                        color: theme.textTheme.displayMedium?.color,
                        fontWeight: FontWeight.w900,
                        fontSize: 24, // Reduced from 28
                        height: 1.0, // Fixed line height
                      ),
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              IconButton(
                icon: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: theme.cardTheme.color,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Icon(
                    themeProvider.isDarkMode ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
                    color: theme.iconTheme.color,
                    size: 20,
                  ),
                ),
                onPressed: () {
                  themeProvider.toggleTheme();
                },
              ),
              IconButton(
                icon: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: theme.cardTheme.color,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Icon(Icons.search_rounded),
                ),
                onPressed: () {
                  Navigator.pushNamed(context, '/search');
                },
              ),
              IconButton(
                icon: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: theme.cardTheme.color,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Icon(Icons.settings_rounded),
                ),
                onPressed: () {
                  _navigateToSettings(context);
                },
              ),
            ],
          ),

          // Featured News Horizontal Scroll
          Consumer<NewsProvider>(
            builder: (context, newsProvider, child) {
              if (newsProvider.articles.isEmpty || newsProvider.isLoading) {
                return const SliverToBoxAdapter(child: SizedBox.shrink());
              }

              final featuredArticles = newsProvider.articles.take(5).toList();
              
              return SliverToBoxAdapter(
                child: _buildFeaturedSection(featuredArticles, newsProvider),
              );
            },
          ),

          // Category Chips with Enhanced Horizontal Scroll
          SliverToBoxAdapter(
            child: _buildCategoryChips(),
          ),

          // Trending Section Header
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 12),
              child: Row(
                children: [
                  Text(
                    'Latest News',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const Spacer(),
                  Consumer<NewsProvider>(
                    builder: (context, newsProvider, child) {
                      return Text(
                        '${newsProvider.articles.length} articles',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: AppTheme.getGreyColor(context),
                          fontSize: 12,
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),

          // News List - FIXED: Added bottom padding to prevent overflow
          Consumer<NewsProvider>(
            builder: (context, newsProvider, child) {
              if (newsProvider.isLoading) {
                return const SliverToBoxAdapter(
                  child: LoadingShimmer(),
                );
              }

              if (newsProvider.errorMessage.isNotEmpty) {
                return SliverToBoxAdapter(
                  child: _buildErrorState(newsProvider),
                );
              }

              if (newsProvider.articles.isEmpty) {
                return SliverToBoxAdapter(
                  child: _buildEmptyState(),
                );
              }

              // Skip first 5 featured articles
              final trendingArticles = newsProvider.articles.skip(5).toList();

              // FIX: Wrap with SliverPadding to add bottom space
              return SliverPadding(
                padding: const EdgeInsets.only(bottom: 80),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final article = trendingArticles[index];
                      return ModernNewsCard(
                        article: article,
                        onTap: () => _navigateToDetailScreen(context, article),
                        onBookmark: () {
                          newsProvider.toggleBookmark(article);
                        },
                        isBookmarked: newsProvider.isBookmarked(article),
                      );
                    },
                    childCount: trendingArticles.length,
                  ),
                ),
              );
            },
          ),
        ],
      ),

      // Enhanced Floating Action Button - FIXED: Added margin
      floatingActionButton: Container(
        margin: const EdgeInsets.only(bottom: 16),
        child: FloatingActionButton(
          onPressed: () {
            _scrollController.animateTo(
              0,
              duration: const Duration(milliseconds: 600),
              curve: Curves.easeInOutCubic,
            );
          },
          backgroundColor: AppTheme.primaryColor,
          foregroundColor: Colors.white,
          elevation: 12,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Icon(Icons.arrow_upward_rounded),
        ),
      ),
    );
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning 🌅';
    if (hour < 17) return 'Good Afternoon ☀️';
    return 'Good Evening 🌙';
  }

  Widget _buildFeaturedSection(List<dynamic> featuredArticles, NewsProvider newsProvider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 12),
          child: Row(
            children: [
              Text(
                'Featured Stories',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '${featuredArticles.length} stories',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppTheme.primaryColor,
                    fontWeight: FontWeight.w600,
                    fontSize: 11,
                  ),
                ),
              ),
            ],
          ),
        ),
        
        // Horizontal Scroll for Featured Articles
        SizedBox(
          height: 220,
          child: PageView.builder(
            controller: _featuredController,
            itemCount: featuredArticles.length,
            physics: const BouncingScrollPhysics(),
            padEnds: false,
            itemBuilder: (context, index) {
              final article = featuredArticles[index];
              return Padding(
                padding: EdgeInsets.only(
                  left: index == 0 ? 24 : 8,
                  right: index == featuredArticles.length - 1 ? 24 : 8,
                ),
                child: FeaturedNewsCard(
                  article: article,
                  onTap: () => _navigateToDetailScreen(context, article),
                  onBookmark: () {
                    newsProvider.toggleBookmark(article);
                  },
                  isBookmarked: newsProvider.isBookmarked(article),
                ),
              );
            },
          ),
        ),
        
        const SizedBox(height: 12),
      ],
    );
  }

  Widget _buildCategoryChips() {
    final theme = Theme.of(context);
    
    return Container(
      height: 56,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final category = categories[index];
          final isSelected = selectedCategory == category;
          
          return Padding(
            padding: const EdgeInsets.all(4.0),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 400),
              curve: Curves.easeInOut,
              decoration: BoxDecoration(
                gradient: isSelected ? AppTheme.primaryGradient : null,
                color: isSelected ? null : theme.cardTheme.color,
                borderRadius: BorderRadius.circular(20),
                boxShadow: isSelected ? [
                  BoxShadow(
                    color: AppTheme.primaryColor.withOpacity(0.4),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ] : [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
                border: isSelected ? null : Border.all(
                  color: theme.dividerColor.withOpacity(0.2),
                  width: 1,
                ),
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(20),
                  onTap: () {
                    setState(() {
                      selectedCategory = category;
                    });
                    context.read<NewsProvider>().fetchTopHeadlines(
                      category: selectedCategory,
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    child: Text(
                      category[0].toUpperCase() + category.substring(1),
                      style: TextStyle(
                        color: isSelected ? Colors.white : theme.textTheme.bodyLarge?.color,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildErrorState(NewsProvider newsProvider) {
    final theme = Theme.of(context);
    
    return Container(
      height: 280,
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppTheme.secondaryColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.error_outline_rounded,
              size: 44,
              color: AppTheme.secondaryColor,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Connection Issue',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w800,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            newsProvider.errorMessage,
            style: theme.textTheme.bodyMedium,
            textAlign: TextAlign.center,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: () {
              newsProvider.fetchTopHeadlines(category: selectedCategory);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('Try Again'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    final theme = Theme.of(context);
    
    return Container(
      height: 280,
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              gradient: AppTheme.primaryGradient,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.article_rounded,
              color: Colors.white,
              size: 44,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'No Articles Found',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w800,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Try selecting a different category',
            style: theme.textTheme.bodyMedium,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 20),
          OutlinedButton.icon(
            onPressed: () {
              context.read<NewsProvider>().fetchTopHeadlines(category: selectedCategory);
            },
            style: OutlinedButton.styleFrom(
              foregroundColor: AppTheme.primaryColor,
              side: BorderSide(color: AppTheme.primaryColor),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('Refresh'),
          ),
        ],
      ),
    );
  }
}
