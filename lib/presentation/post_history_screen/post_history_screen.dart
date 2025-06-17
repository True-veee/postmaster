import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/app_export.dart';
import '../../widgets/custom_icon_widget.dart';
import './widgets/empty_state_widget.dart';
import './widgets/post_history_card_widget.dart';

class PostHistoryScreen extends StatefulWidget {
  const PostHistoryScreen({super.key});

  @override
  State<PostHistoryScreen> createState() => _PostHistoryScreenState();
}

class _PostHistoryScreenState extends State<PostHistoryScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isLoading = false;
  final bool _isSearching = false;
  String _searchQuery = '';

  // Mock data for post history
  final List<Map<String, dynamic>> _allPosts = [
    {
      "id": "1",
      "content":
          "Just completed the quarterly report analysis. The data shows significant improvement in user engagement metrics across all platforms.",
      "timestamp": DateTime.now().subtract(Duration(hours: 2)),
      "status": "success",
      "apiResponse": "200 OK",
      "retryCount": 0,
    },
    {
      "id": "2",
      "content":
          "Meeting notes from today's product review session. Key decisions made regarding the upcoming feature releases.",
      "timestamp": DateTime.now().subtract(Duration(hours: 5)),
      "status": "failed",
      "apiResponse": "500 Internal Server Error",
      "retryCount": 2,
      "errorDetails": "Connection timeout after 30 seconds"
    },
    {
      "id": "3",
      "content":
          "Weekly team standup summary with action items and blockers identified for the current sprint.",
      "timestamp": DateTime.now().subtract(Duration(days: 1)),
      "status": "pending",
      "apiResponse": "Uploading...",
      "retryCount": 0,
    },
    {
      "id": "4",
      "content":
          "Customer feedback compilation from the latest product survey. Overall satisfaction scores have increased by 15%.",
      "timestamp": DateTime.now().subtract(Duration(days: 2)),
      "status": "success",
      "apiResponse": "201 Created",
      "retryCount": 0,
    },
    {
      "id": "5",
      "content":
          "Project milestone update for the mobile app development. Phase 1 completed ahead of schedule.",
      "timestamp": DateTime.now().subtract(Duration(days: 3)),
      "status": "failed",
      "apiResponse": "400 Bad Request",
      "retryCount": 1,
      "errorDetails": "Invalid request format"
    },
  ];

  List<Map<String, dynamic>> _filteredPosts = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this, initialIndex: 1);
    _filteredPosts = List.from(_allPosts);
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    setState(() {
      _searchQuery = _searchController.text.toLowerCase();
      if (_searchQuery.isEmpty) {
        _filteredPosts = List.from(_allPosts);
      } else {
        _filteredPosts = _allPosts.where((post) {
          final content = (post['content'] as String).toLowerCase();
          return content.contains(_searchQuery);
        }).toList();
      }
    });
  }

  Future<void> _onRefresh() async {
    setState(() {
      _isLoading = true;
    });

    // Simulate API call
    await Future.delayed(Duration(seconds: 2));

    // Haptic feedback
    HapticFeedback.lightImpact();

    setState(() {
      _isLoading = false;
    });
  }

  void _retryPost(String postId) {
    setState(() {
      final postIndex = _allPosts.indexWhere((post) => post['id'] == postId);
      if (postIndex != -1) {
        _allPosts[postIndex]['status'] = 'pending';
        _allPosts[postIndex]['apiResponse'] = 'Retrying...';
        _allPosts[postIndex]['retryCount'] =
            (_allPosts[postIndex]['retryCount'] as int) + 1;
      }
      _onSearchChanged(); // Refresh filtered list
    });

    // Simulate retry
    Future.delayed(Duration(seconds: 3), () {
      setState(() {
        final postIndex = _allPosts.indexWhere((post) => post['id'] == postId);
        if (postIndex != -1) {
          _allPosts[postIndex]['status'] = 'success';
          _allPosts[postIndex]['apiResponse'] = '200 OK';
        }
        _onSearchChanged();
      });
      HapticFeedback.mediumImpact();
    });
  }

  void _duplicatePost(String postId) {
    final post = _allPosts.firstWhere((p) => p['id'] == postId);
    Navigator.pushNamed(context, '/post-creation-screen');
  }

  void _sharePost(String postId) {
    final post = _allPosts.firstWhere((p) => p['id'] == postId);
    // Implement share functionality
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Share functionality would be implemented here')),
    );
  }

  void _deletePost(String postId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Post'),
        content: Text(
            'Are you sure you want to delete this post? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                _allPosts.removeWhere((post) => post['id'] == postId);
                _onSearchChanged();
              });
              Navigator.pop(context);
              HapticFeedback.lightImpact();
            },
            child: Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _showPostDetails(Map<String, dynamic> post) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => Container(
        padding: EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Post Details',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            SizedBox(height: 16),
            Text(
              'Content:',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            SizedBox(height: 8),
            Text(
              post['content'] as String,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            SizedBox(height: 16),
            Text(
              'Status: ${post['status']}',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            SizedBox(height: 8),
            Text(
              'API Response: ${post['apiResponse']}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            if (post['errorDetails'] != null) ...[
              SizedBox(height: 8),
              Text(
                'Error: ${post['errorDetails']}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.error,
                    ),
              ),
            ],
            SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Close'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // Tab Bar Header
            Container(
              color: Theme.of(context).colorScheme.surface,
              child: Column(
                children: [
                  TabBar(
                    controller: _tabController,
                    onTap: (index) {
                      if (index == 0) {
                        Navigator.pushNamed(context, '/post-creation-screen');
                      } else if (index == 2) {
                        Navigator.pushNamed(context, '/settings-screen');
                      }
                    },
                    tabs: [
                      Tab(
                        icon: CustomIconWidget(
                          iconName: 'add',
                          size: 20,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                        text: 'Create',
                      ),
                      Tab(
                        icon: CustomIconWidget(
                          iconName: 'history',
                          size: 20,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        text: 'History',
                      ),
                      Tab(
                        icon: CustomIconWidget(
                          iconName: 'settings',
                          size: 20,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                        text: 'Settings',
                      ),
                    ],
                  ),
                  // Search Bar
                  Container(
                    padding: EdgeInsets.all(16),
                    child: TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: 'Search posts by content or date...',
                        prefixIcon: CustomIconWidget(
                          iconName: 'search',
                          size: 20,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                        suffixIcon: _searchQuery.isNotEmpty
                            ? IconButton(
                                onPressed: () {
                                  _searchController.clear();
                                },
                                icon: CustomIconWidget(
                                  iconName: 'clear',
                                  size: 20,
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSurfaceVariant,
                                ),
                              )
                            : null,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Main Content
            Expanded(
              child: _filteredPosts.isEmpty
                  ? EmptyStateWidget(
                      onCreatePost: () {
                        Navigator.pushNamed(context, '/post-creation-screen');
                      },
                    )
                  : RefreshIndicator(
                      onRefresh: _onRefresh,
                      child: ListView.separated(
                        controller: _scrollController,
                        padding: EdgeInsets.all(16),
                        itemCount: _filteredPosts.length,
                        separatorBuilder: (context, index) =>
                            SizedBox(height: 16),
                        itemBuilder: (context, index) {
                          final post = _filteredPosts[index];
                          return PostHistoryCardWidget(
                            post: post,
                            onRetry: () => _retryPost(post['id'] as String),
                            onDuplicate: () =>
                                _duplicatePost(post['id'] as String),
                            onShare: () => _sharePost(post['id'] as String),
                            onDelete: () => _deletePost(post['id'] as String),
                            onTap: () => _showPostDetails(post),
                          );
                        },
                      ),
                    ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, '/post-creation-screen');
        },
        child: CustomIconWidget(
          iconName: 'add',
          size: 24,
          color: Colors.white,
        ),
      ),
    );
  }
}