import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/theme_provider.dart';
import '../providers/news_provider.dart';
import '../theme/app_theme.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final TextEditingController _newsApiController = TextEditingController();
  final TextEditingController _guardianController = TextEditingController();
  final TextEditingController _newsDataController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadCurrentKeys();
    });
  }

  void _loadCurrentKeys() {
    final authProvider = context.read<AuthProvider>();
    _newsApiController.text = authProvider.getApiKey('newsapi') ?? '';
    _guardianController.text = authProvider.getApiKey('guardian') ?? '';
    _newsDataController.text = authProvider.getApiKey('newsdata') ?? '';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: theme.appBarTheme.backgroundColor,
        foregroundColor: theme.appBarTheme.foregroundColor,
        elevation: 0,
        centerTitle: true,
      ),
      body: Consumer3<AuthProvider, ThemeProvider, NewsProvider>(
        builder: (context, authProvider, themeProvider, newsProvider, child) {
          return Padding(
            padding: const EdgeInsets.all(20),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // App Info Card
                  _buildAppInfoCard(context),

                  const SizedBox(height: 24),

                  // API Status Card
                  _buildApiStatusCard(newsProvider),

                  const SizedBox(height: 24),

                  // Theme Settings Card
                  _buildThemeCard(themeProvider),

                  const SizedBox(height: 24),

                  // Primary Colors Card
                  _buildPrimaryColorsCard(themeProvider),

                  const SizedBox(height: 24),

                  // API Configuration Card
                  _buildApiConfigCard(authProvider),

                  const SizedBox(height: 24),

                  // Authentication Card
                  _buildAuthCard(authProvider),

                  const SizedBox(height: 32),

                  // App Version
                  _buildAppVersion(),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildAppInfoCard(BuildContext context) {
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                gradient: AppTheme.primaryGradient,
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(
                Icons.newspaper_rounded,
                color: Colors.white,
                size: 32,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'News Hub Ultra',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Your personalized news aggregator',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context)
                              .textTheme
                              .bodyMedium
                              ?.color
                              ?.withOpacity(0.7),
                        ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildApiStatusCard(NewsProvider newsProvider) {
    final apiStats = newsProvider.getApiStats();

    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.api_rounded,
                  color: AppTheme.primaryColor,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Text(
                  'API Status',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // API Sources
            _buildStatusItem(
              'Available Sources',
              '${apiStats['totalSources']} connected',
              Icons.check_circle_rounded,
              Colors.green,
            ),

            const SizedBox(height: 12),

            // Daily Requests
            _buildStatusItem(
              'Daily Requests',
              '${apiStats['dailyRequestsAvailable']} available',
              Icons.light,
              AppTheme.warningColor,
            ),

            const SizedBox(height: 12),

            // Individual API Status
            ..._buildApiStatusList(apiStats['status']),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusItem(
      String title, String subtitle, IconData icon, Color color) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
              Text(
                subtitle,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context)
                          .textTheme
                          .bodyMedium
                          ?.color
                          ?.withOpacity(0.6),
                    ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  List<Widget> _buildApiStatusList(Map<String, dynamic> status) {
    return status.entries.map((entry) {
      final apiName = entry.key;
      final apiData = entry.value as Map<String, dynamic>;

      return Padding(
        padding: const EdgeInsets.only(top: 8),
        child: Row(
          children: [
            Icon(
              apiData['configured'] ? Icons.check_circle : Icons.error_outline,
              color: apiData['configured'] ? Colors.green : Colors.orange,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                '$apiName: ${apiData['configured'] ? 'Connected' : 'Not configured'}',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color:
                          apiData['configured'] ? Colors.green : Colors.orange,
                    ),
              ),
            ),
          ],
        ),
      );
    }).toList();
  }

  Widget _buildThemeCard(ThemeProvider themeProvider) {
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.palette_rounded,
                  color: AppTheme.secondaryColor,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Text(
                  'Theme',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Theme Options
            _buildThemeOption(
              'Light Mode',
              Icons.light_mode_rounded,
              ThemeMode.light,
              themeProvider,
            ),

            const SizedBox(height: 12),

            _buildThemeOption(
              'Dark Mode',
              Icons.dark_mode_rounded,
              ThemeMode.dark,
              themeProvider,
            ),

            const SizedBox(height: 12),

            _buildThemeOption(
              'System Default',
              Icons.phone_iphone_rounded,
              ThemeMode.system,
              themeProvider,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildThemeOption(String title, IconData icon, ThemeMode mode,
      ThemeProvider themeProvider) {
    final isSelected = themeProvider.themeMode == mode;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          themeProvider.setThemeMode(mode);
        },
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isSelected
                ? AppTheme.primaryColor.withOpacity(0.1)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? AppTheme.primaryColor : Colors.transparent,
              width: 2,
            ),
          ),
          child: Row(
            children: [
              Icon(
                icon,
                color: isSelected
                    ? AppTheme.primaryColor
                    : Theme.of(context)
                        .textTheme
                        .bodyMedium
                        ?.color
                        ?.withOpacity(0.6),
                size: 24,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontWeight:
                            isSelected ? FontWeight.w600 : FontWeight.w400,
                        color: isSelected ? AppTheme.primaryColor : null,
                      ),
                ),
              ),
              if (isSelected)
                Icon(
                  Icons.check_circle_rounded,
                  color: AppTheme.primaryColor,
                  size: 20,
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPrimaryColorsCard(ThemeProvider themeProvider) {
    final List<Color> primaryColors = [
      Colors.blue, // Default blue
      Colors.purple,
      Colors.green,
      Colors.orange,
      Colors.red,
      Colors.teal,
      Colors.indigo,
      Colors.pink,
    ];

    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.color_lens_rounded,
                  color: AppTheme.secondaryColor,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Text(
                  'Primary Color',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            Text(
              'Choose your primary color theme',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context)
                        .textTheme
                        .bodyMedium
                        ?.color
                        ?.withOpacity(0.7),
                  ),
            ),

            const SizedBox(height: 16),

            // Color Grid
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.2,
              ),
              itemCount: primaryColors.length,
              itemBuilder: (context, index) {
                final color = primaryColors[index];
                final isSelected =
                    themeProvider.primaryColorValue == color.value;

                return Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: () {
                      themeProvider.setPrimaryColor(color);
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: color,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isSelected ? Colors.white : Colors.transparent,
                          width: 3,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: color.withOpacity(0.4),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: isSelected
                          ? const Center(
                              child: Icon(
                                Icons.check_rounded,
                                color: Colors.white,
                                size: 24,
                              ),
                            )
                          : null,
                    ),
                  ),
                );
              },
            ),

            const SizedBox(height: 16),

            // Reset to Default
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () {
                  themeProvider.resetPrimaryColor();
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppTheme.primaryColor,
                  side: BorderSide(color: AppTheme.primaryColor),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Reset to Default',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildApiConfigCard(AuthProvider authProvider) {
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.vpn_key_rounded,
                  color: AppTheme.accentColor,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Text(
                  'API Configuration',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // NewsAPI Key
            _buildApiKeyField(
              'NewsAPI Key',
              'Enter your NewsAPI key',
              _newsApiController,
              Icons.article_rounded,
            ),

            const SizedBox(height: 12),

            // Guardian API Key
            _buildApiKeyField(
              'Guardian API Key',
              'Enter your Guardian API key',
              _guardianController,
              Icons.library_books_rounded,
            ),

            const SizedBox(height: 12),

            // NewsData.io Key
            _buildApiKeyField(
              'NewsData.io Key',
              'Enter your NewsData.io key',
              _newsDataController,
              Icons.public_rounded,
            ),

            const SizedBox(height: 20),

            // Save Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  final keys = {
                    'newsapi': _newsApiController.text.trim(),
                    'guardian': _guardianController.text.trim(),
                    'newsdata': _newsDataController.text.trim(),
                  };

                  final success = await authProvider.storeApiKeys(keys);

                  if (success) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text('API keys saved successfully!'),
                        backgroundColor: AppTheme.successColor,
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                            'Failed to save keys: ${authProvider.errorMessage}'),
                        backgroundColor: AppTheme.errorColor,
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 4,
                ),
                child: const Text(
                  'Save API Keys',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildApiKeyField(String label, String hint,
      TextEditingController controller, IconData icon) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon, color: AppTheme.primaryColor),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        filled: true,
        fillColor: Theme.of(context).cardTheme.color,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
      obscureText: true,
    );
  }

  Widget _buildAuthCard(AuthProvider authProvider) {
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.security_rounded,
                  color: AppTheme.warningColor,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Text(
                  'Authentication',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (!authProvider.isLoggedIn)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    authProvider.loginWithOAuth('demo');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.secondaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 4,
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.fingerprint_rounded),
                      SizedBox(width: 8),
                      Text(
                        'Login with OAuth',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildStatusItem(
                    'Status',
                    'Logged In',
                    Icons.verified_user_rounded,
                    Colors.green,
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: () {
                        authProvider.logout();
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppTheme.errorColor,
                        side: BorderSide(color: AppTheme.errorColor),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Logout',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppVersion() {
    return Center(
      child: Column(
        children: [
          Text(
            'News Hub Ultra',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.color
                      ?.withOpacity(0.6),
                ),
          ),
          Text(
            'Version 1.0.0 • Build 1',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context)
                      .textTheme
                      .bodySmall
                      ?.color
                      ?.withOpacity(0.4),
                ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _newsApiController.dispose();
    _guardianController.dispose();
    _newsDataController.dispose();
    super.dispose();
  }
}
