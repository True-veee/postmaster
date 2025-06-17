import 'dart:async';
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/app_export.dart';
import './widgets/character_counter_widget.dart';
import './widgets/post_button_widget.dart';
import './widgets/tag_selector_widget.dart';

class PostCreationScreen extends StatefulWidget {
  const PostCreationScreen({super.key});

  @override
  State<PostCreationScreen> createState() => _PostCreationScreenState();
}

class _PostCreationScreenState extends State<PostCreationScreen> {
  final TextEditingController _textController = TextEditingController();
  final FocusNode _textFocusNode = FocusNode();
  final Dio _dio = Dio();

  bool _isLoading = false;
  bool _hasContent = false;
  List<String> _selectedTags = [];
  Timer? _autoSaveTimer;

  static const int _characterLimit = 280;
  static const String _draftKey = 'post_draft';
  static const String _tagsKey = 'post_tags';

  final List<Map<String, dynamic>> _availableTags = [
    {"id": 1, "name": "General", "color": "0xFF2563EB"},
    {"id": 2, "name": "Update", "color": "0xFF059669"},
    {"id": 3, "name": "News", "color": "0xFFD97706"},
    {"id": 4, "name": "Personal", "color": "0xFFDC2626"},
    {"id": 5, "name": "Work", "color": "0xFF7C3AED"},
  ];

  @override
  void initState() {
    super.initState();
    _loadDraft();
    _textController.addListener(_onTextChanged);

    // Auto-focus text field
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _textFocusNode.requestFocus();
    });

    // Setup auto-save timer
    _autoSaveTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      _saveDraft();
    });
  }

  @override
  void dispose() {
    _textController.dispose();
    _textFocusNode.dispose();
    _autoSaveTimer?.cancel();
    super.dispose();
  }

  void _onTextChanged() {
    setState(() {
      _hasContent = _textController.text.trim().isNotEmpty;
    });
  }

  Future<void> _loadDraft() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final draftText = prefs.getString(_draftKey);
      final tagsJson = prefs.getString(_tagsKey);

      if (draftText != null && draftText.isNotEmpty) {
        _textController.text = draftText;
        setState(() {
          _hasContent = true;
        });
      }

      if (tagsJson != null) {
        final List<dynamic> tagsList = jsonDecode(tagsJson);
        setState(() {
          _selectedTags = tagsList.cast<String>();
        });
      }
    } catch (e) {
      debugPrint('Error loading draft: \$e');
    }
  }

  Future<void> _saveDraft() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_draftKey, _textController.text);
      await prefs.setString(_tagsKey, jsonEncode(_selectedTags));
    } catch (e) {
      debugPrint('Error saving draft: \$e');
    }
  }

  Future<void> _clearDraft() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_draftKey);
      await prefs.remove(_tagsKey);
    } catch (e) {
      debugPrint('Error clearing draft: \$e');
    }
  }

  Future<bool> _checkConnectivity() async {
    final connectivityResult = await Connectivity().checkConnectivity();
    return connectivityResult != ConnectivityResult.none;
  }

  Future<void> _submitPost() async {
    if (!_hasContent || _isLoading) return;

    // Check connectivity
    final hasConnection = await _checkConnectivity();
    if (!hasConnection) {
      _showErrorMessage(
          'No internet connection. Please check your network and try again.');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Prepare post data
      final postData = {
        'content': _textController.text.trim(),
        'tags': _selectedTags,
        'timestamp': DateTime.now().toIso8601String(),
        'characterCount': _textController.text.length,
      };

      // Mock AWS API Gateway endpoint
      const String apiEndpoint = 'https://api.postmaster.example.com/posts';

      final response = await _dio.post(
        apiEndpoint,
        data: postData,
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer mock-token-12345',
          },
          sendTimeout: const Duration(seconds: 30),
          receiveTimeout: const Duration(seconds: 30),
        ),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        // Success - provide haptic feedback
        HapticFeedback.lightImpact();

        // Clear draft and form
        await _clearDraft();
        _textController.clear();
        setState(() {
          _selectedTags.clear();
          _hasContent = false;
        });

        // Show success toast
        Fluttertoast.showToast(
          msg: "Post submitted successfully!",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: AppTheme.successLight,
          textColor: Colors.white,
        );

        // Navigate to post history after brief delay
        Future.delayed(const Duration(milliseconds: 1500), () {
          if (mounted) {
            Navigator.pushReplacementNamed(context, '/post-history-screen');
          }
        });
      } else {
        _showErrorMessage(
            'Failed to submit post. Server returned status: \${response.statusCode}');
      }
    } on DioException catch (e) {
      String errorMessage = 'Failed to submit post. ';

      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.sendTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        errorMessage += 'Request timed out. Please try again.';
      } else if (e.type == DioExceptionType.connectionError) {
        errorMessage +=
            'Connection failed. Please check your internet connection.';
      } else if (e.response?.statusCode == 400) {
        errorMessage += 'Invalid post content. Please check your input.';
      } else if (e.response?.statusCode == 401) {
        errorMessage += 'Authentication failed. Please log in again.';
      } else if (e.response?.statusCode == 429) {
        errorMessage += 'Too many requests. Please wait before trying again.';
      } else {
        errorMessage += 'Please try again later.';
      }

      _showErrorMessage(errorMessage);
    } catch (e) {
      _showErrorMessage('An unexpected error occurred. Please try again.');
      debugPrint('Unexpected error: \$e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showErrorMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppTheme.errorLight,
        behavior: SnackBarBehavior.floating,
        action: SnackBarAction(
          label: 'Retry',
          textColor: Colors.white,
          onPressed: _submitPost,
        ),
      ),
    );
  }

  Future<bool> _onWillPop() async {
    if (_hasContent) {
      final shouldSave = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Save Draft?'),
          content: const Text(
              'You have unsaved changes. Would you like to save them as a draft?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Discard'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Save Draft'),
            ),
          ],
        ),
      );

      if (shouldSave == true) {
        await _saveDraft();
      } else if (shouldSave == false) {
        await _clearDraft();
      }

      return shouldSave != null;
    }
    return true;
  }

  void _onTagSelected(String tag) {
    setState(() {
      if (_selectedTags.contains(tag)) {
        _selectedTags.remove(tag);
      } else {
        _selectedTags.add(tag);
      }
    });
  }

  void _dismissKeyboard() {
    FocusScope.of(context).unfocus();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
        appBar: AppBar(
          title: Text(
            'New Post',
            style: AppTheme.lightTheme.textTheme.titleLarge,
          ),
          leading: TextButton(
            onPressed: _isLoading
                ? null
                : () async {
                    final canPop = await _onWillPop();
                    if (canPop && mounted) {
                      Navigator.of(context).pop();
                    }
                  },
            child: Text(
              'Cancel',
              style: TextStyle(
                color: _isLoading
                    ? AppTheme.lightTheme.colorScheme.onSurfaceVariant
                    : AppTheme.lightTheme.colorScheme.primary,
                fontSize: 16,
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: (_hasContent && !_isLoading) ? _submitPost : null,
              child: _isLoading
                  ? SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          AppTheme.lightTheme.colorScheme.primary,
                        ),
                      ),
                    )
                  : Text(
                      'Post',
                      style: TextStyle(
                        color: (_hasContent && !_isLoading)
                            ? AppTheme.lightTheme.colorScheme.primary
                            : AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
            ),
          ],
        ),
        body: SafeArea(
          child: GestureDetector(
            onTap: _dismissKeyboard,
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Main text input field
                        Container(
                          width: double.infinity,
                          constraints: const BoxConstraints(minHeight: 200),
                          child: TextField(
                            controller: _textController,
                            focusNode: _textFocusNode,
                            enabled: !_isLoading,
                            maxLength: _characterLimit,
                            maxLines: null,
                            textInputAction: TextInputAction.newline,
                            style: AppTheme.lightTheme.textTheme.bodyLarge,
                            decoration: InputDecoration(
                              hintText: "What's on your mind?",
                              hintStyle: AppTheme
                                  .lightTheme.inputDecorationTheme.hintStyle,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color:
                                      AppTheme.lightTheme.colorScheme.outline,
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color:
                                      AppTheme.lightTheme.colorScheme.outline,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color:
                                      AppTheme.lightTheme.colorScheme.primary,
                                  width: 2,
                                ),
                              ),
                              counterText: '',
                              contentPadding: const EdgeInsets.all(16),
                            ),
                          ),
                        ),

                        const SizedBox(height: 8),

                        // Character counter
                        CharacterCounterWidget(
                          currentLength: _textController.text.length,
                          maxLength: _characterLimit,
                        ),

                        const SizedBox(height: 24),

                        // Tags section
                        Text(
                          'Tags (Optional)',
                          style: AppTheme.lightTheme.textTheme.titleMedium,
                        ),

                        const SizedBox(height: 12),

                        TagSelectorWidget(
                          availableTags: _availableTags,
                          selectedTags: _selectedTags,
                          onTagSelected: _onTagSelected,
                          isEnabled: !_isLoading,
                        ),

                        const SizedBox(height: 32),
                      ],
                    ),
                  ),
                ),

                // Bottom post button
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppTheme.lightTheme.colorScheme.surface,
                    border: Border(
                      top: BorderSide(
                        color: AppTheme.lightTheme.colorScheme.outline
                            .withValues(alpha: 0.2),
                      ),
                    ),
                  ),
                  child: PostButtonWidget(
                    onPressed:
                        (_hasContent && !_isLoading) ? _submitPost : null,
                    isLoading: _isLoading,
                    hasContent: _hasContent,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
