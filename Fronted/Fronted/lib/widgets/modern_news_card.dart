import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';
import '../models/news_model.dart';
import '../theme/app_theme.dart';

class ModernNewsCard extends StatelessWidget {
  final NewsArticle article;
  final VoidCallback onTap;
  final VoidCallback onBookmark;
  final bool isBookmarked;
  final bool isFeatured;

  const ModernNewsCard({
    Key? key,
    required this.article,
    required this.onTap,
    required this.onBookmark,
    required this.isBookmarked,
    this.isFeatured = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Material(
        borderRadius: BorderRadius.circular(20),
        color: theme.cardTheme.color,
        elevation: 8,
        shadowColor: AppTheme.primaryColor.withOpacity(0.1),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              minHeight: 120,
            ),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                gradient: isFeatured ? AppTheme.cardGradient : null,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // News Image with Overlay
                  if (article.urlToImage != null)
                    _buildImageSection(context),
                  
                  // Content
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Source and Date Row
                        _buildMetaRow(context),
                        
                        const SizedBox(height: 12),
                        
                        // Title - FIXED OVERFLOW
                        Text(
                          article.title,
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontSize: isFeatured ? 18 : 16,
                            height: 1.4,
                          ),
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        ),
                        
                        const SizedBox(height: 8),
                        
                        // Description - FIXED OVERFLOW
                        if (article.description != null && article.description!.isNotEmpty)
                          Text(
                            article.description!,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.textTheme.bodyMedium?.color?.withOpacity(0.8),
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        
                        const SizedBox(height: 16),
                        
                        // Actions Row
                        _buildActionsRow(context),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildImageSection(BuildContext context) {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          child: Container(
            height: isFeatured ? 200 : 160,
            width: double.infinity,
            child: CachedNetworkImage(
              imageUrl: article.urlToImage!,
              fit: BoxFit.cover,
              placeholder: (context, url) => Container(
                decoration: const BoxDecoration(
                  gradient: AppTheme.primaryGradient,
                ),
                child: const Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation(Colors.white),
                  ),
                ),
              ),
              errorWidget: (context, url, error) => Container(
                decoration: const BoxDecoration(
                  gradient: AppTheme.primaryGradient,
                ),
                child: const Icon(
                  Icons.article,
                  color: Colors.white,
                  size: 40,
                ),
              ),
            ),
          ),
        ),
        
        // Gradient Overlay
        Container(
          height: isFeatured ? 200 : 160,
          decoration: BoxDecoration(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            gradient: LinearGradient(
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
              colors: [
                Colors.black.withOpacity(0.6),
                Colors.transparent,
              ],
            ),
          ),
        ),
        
        // Bookmark Button
        Positioned(
          top: 12,
          right: 12,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.5),
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: Icon(
                isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                color: isBookmarked ? AppTheme.secondaryColor : Colors.white,
                size: 20,
              ),
              onPressed: onBookmark,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMetaRow(BuildContext context) {
    return Row(
      children: [
        // Source Chip - FIXED OVERFLOW
        Flexible(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              gradient: AppTheme.primaryGradient,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              article.source.length > 15 
                  ? '${article.source.substring(0, 15)}...' 
                  : article.source,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
        
        const Spacer(),
        
        // Date
        Text(
          DateFormat('MMM dd, yyyy').format(article.publishedAt),
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildActionsRow(BuildContext context) {
    final theme = Theme.of(context);
    final bool isDark = theme.brightness == Brightness.dark;
    final Color greyColor = isDark ? AppTheme.darkGrey : AppTheme.lightGrey;
    
    return Row(
      children: [
        // Author - FIXED OVERFLOW
        Expanded(
          child: Text(
            'By ${article.author ?? 'Unknown'}',
            style: theme.textTheme.bodyMedium?.copyWith(
              fontSize: 12,
              color: greyColor,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        
        // Read Time and Share
        if (article.readTime != null)
          Row(
            children: [
              Icon(Icons.schedule, size: 14, color: greyColor),
              const SizedBox(width: 4),
              Text(
                '${article.readTime} min',
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontSize: 12,
                  color: greyColor,
                ),
              ),
              const SizedBox(width: 12),
            ],
          ),
        
        // Share Button
        IconButton(
          icon: Icon(Icons.share, size: 18, color: greyColor),
          onPressed: () {
            _shareArticle(context);
          },
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
        ),
      ],
    );
  }

  void _shareArticle(BuildContext context) {
    // Implement share functionality
    print('Sharing article: ${article.title}');
  }
}
