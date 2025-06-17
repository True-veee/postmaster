import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

class PostHistoryCardWidget extends StatelessWidget {
  final Map<String, dynamic> post;
  final VoidCallback onRetry;
  final VoidCallback onDuplicate;
  final VoidCallback onShare;
  final VoidCallback onDelete;
  final VoidCallback onTap;

  const PostHistoryCardWidget({
    super.key,
    required this.post,
    required this.onRetry,
    required this.onDuplicate,
    required this.onShare,
    required this.onDelete,
    required this.onTap,
  });

  Color _getStatusColor(BuildContext context) {
    final status = post['status'] as String;
    switch (status) {
      case 'success':
        return Theme.of(context).colorScheme.tertiary;
      case 'pending':
        return Colors.orange;
      case 'failed':
        return Theme.of(context).colorScheme.error;
      default:
        return Theme.of(context).colorScheme.onSurfaceVariant;
    }
  }

  String _getStatusIcon() {
    final status = post['status'] as String;
    switch (status) {
      case 'success':
        return 'check_circle';
      case 'pending':
        return 'schedule';
      case 'failed':
        return 'error';
      default:
        return 'help';
    }
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else {
      return '${difference.inDays}d ago';
    }
  }

  void _showContextMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: EdgeInsets.symmetric(vertical: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: CustomIconWidget(
                iconName: 'edit',
                size: 24,
                color: Theme.of(context).colorScheme.onSurface,
              ),
              title: Text('Edit Draft'),
              onTap: () {
                Navigator.pop(context);
                // Navigate to edit
              },
            ),
            ListTile(
              leading: CustomIconWidget(
                iconName: 'visibility',
                size: 24,
                color: Theme.of(context).colorScheme.onSurface,
              ),
              title: Text('View Details'),
              onTap: () {
                Navigator.pop(context);
                onTap();
              },
            ),
            ListTile(
              leading: CustomIconWidget(
                iconName: 'content_copy',
                size: 24,
                color: Theme.of(context).colorScheme.onSurface,
              ),
              title: Text('Copy Content'),
              onTap: () {
                Navigator.pop(context);
                Clipboard.setData(
                    ClipboardData(text: post['content'] as String));
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Content copied to clipboard')),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final status = post['status'] as String;
    final content = post['content'] as String;
    final timestamp = post['timestamp'] as DateTime;
    final apiResponse = post['apiResponse'] as String;

    return Dismissible(
      key: Key(post['id'] as String),
      background: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.tertiary.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(12),
        ),
        alignment: Alignment.centerLeft,
        padding: EdgeInsets.only(left: 20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CustomIconWidget(
              iconName: status == 'failed' ? 'refresh' : 'content_copy',
              size: 24,
              color: Theme.of(context).colorScheme.tertiary,
            ),
            SizedBox(height: 4),
            Text(
              status == 'failed' ? 'Retry' : 'Duplicate',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: Theme.of(context).colorScheme.tertiary,
                  ),
            ),
          ],
        ),
      ),
      secondaryBackground: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.error.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(12),
        ),
        alignment: Alignment.centerRight,
        padding: EdgeInsets.only(right: 20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CustomIconWidget(
              iconName: 'delete',
              size: 24,
              color: Theme.of(context).colorScheme.error,
            ),
            SizedBox(height: 4),
            Text(
              'Delete',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: Theme.of(context).colorScheme.error,
                  ),
            ),
          ],
        ),
      ),
      confirmDismiss: (direction) async {
        if (direction == DismissDirection.startToEnd) {
          if (status == 'failed') {
            onRetry();
          } else {
            onDuplicate();
          }
          return false;
        } else {
          onDelete();
          return false;
        }
      },
      child: GestureDetector(
        onTap: onTap,
        onLongPress: () => _showContextMenu(context),
        child: Card(
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header with status and timestamp
                Row(
                  children: [
                    CustomIconWidget(
                      iconName: _getStatusIcon(),
                      size: 20,
                      color: _getStatusColor(context),
                    ),
                    SizedBox(width: 8),
                    Text(
                      status.toUpperCase(),
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: _getStatusColor(context),
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    Spacer(),
                    Text(
                      _formatTimestamp(timestamp),
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
                SizedBox(height: 12),
                // Content preview
                Text(
                  content,
                  style: Theme.of(context).textTheme.bodyMedium,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 12),
                // API Response
                Row(
                  children: [
                    CustomIconWidget(
                      iconName: 'api',
                      size: 16,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                    SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        apiResponse,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              fontFamily: 'monospace',
                            ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                // Retry button for failed posts
                if (status == 'failed') ...[
                  SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: onRetry,
                      icon: CustomIconWidget(
                        iconName: 'refresh',
                        size: 16,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      label: Text('Retry Submission'),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(
                          color: Theme.of(context).colorScheme.error,
                        ),
                        foregroundColor: Theme.of(context).colorScheme.error,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
