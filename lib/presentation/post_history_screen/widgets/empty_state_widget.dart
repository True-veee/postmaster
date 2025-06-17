import 'package:flutter/material.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

class EmptyStateWidget extends StatelessWidget {
  final VoidCallback onCreatePost;

  const EmptyStateWidget({
    super.key,
    required this.onCreatePost,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Illustration
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: Theme.of(context)
                    .colorScheme
                    .primary
                    .withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: CustomIconWidget(
                iconName: 'post_add',
                size: 60,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            SizedBox(height: 24),
            // Title
            Text(
              'No Posts Yet',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 12),
            // Description
            Text(
              'Your post history will appear here once you start creating and submitting posts to the API.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 32),
            // CTA Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: onCreatePost,
                icon: CustomIconWidget(
                  iconName: 'add',
                  size: 20,
                  color: Colors.white,
                ),
                label: Text('Create Your First Post'),
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),
            SizedBox(height: 16),
            // Secondary action
            TextButton(
              onPressed: () {
                // Show help or tutorial
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: Text('Getting Started'),
                    content: Text(
                      'PostMaster helps you submit posts to AWS API Gateway endpoints. '
                      'Create your first post by tapping the "Create" tab or the floating action button.',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text('Got it'),
                      ),
                    ],
                  ),
                );
              },
              child: Text('Learn More'),
            ),
          ],
        ),
      ),
    );
  }
}
