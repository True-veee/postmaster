import 'package:flutter/material.dart';
import '../presentation/post_creation_screen/post_creation_screen.dart';
import '../presentation/post_history_screen/post_history_screen.dart';
import '../presentation/settings_screen/settings_screen.dart';

class AppRoutes {
  static const String initial = '/';
  static const String postCreationScreen = '/post-creation-screen';
  static const String postHistoryScreen = '/post-history-screen';
  static const String settingsScreen = '/settings-screen';

  static Map<String, WidgetBuilder> routes = {
    initial: (context) => const PostCreationScreen(),
    postCreationScreen: (context) => const PostCreationScreen(),
    postHistoryScreen: (context) => const PostHistoryScreen(),
    settingsScreen: (context) => const SettingsScreen(),
  };
}
