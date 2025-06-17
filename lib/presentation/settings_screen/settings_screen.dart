import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/app_export.dart';
import './widgets/api_test_widget.dart';
import './widgets/settings_row_widget.dart';
import './widgets/settings_section_widget.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _apiEndpointController = TextEditingController();
  final TextEditingController _characterLimitController =
      TextEditingController();

  bool _autoSaveEnabled = true;
  bool _successNotifications = true;
  bool _failureNotifications = true;
  String _authMethod = 'API Key';
  String _retentionPeriod = '30 days';
  String _autoSaveFrequency = '5 minutes';
  bool _isTestingConnection = false;
  String _connectionStatus = '';

  final List<String> _authMethods = ['API Key', 'Bearer Token', 'Basic Auth'];
  final List<String> _retentionPeriods = [
    '7 days',
    '30 days',
    '90 days',
    'Never'
  ];
  final List<String> _autoSaveFrequencies = [
    '1 minute',
    '5 minutes',
    '10 minutes',
    '30 minutes'
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this, initialIndex: 2);
    _apiEndpointController.text =
        'https://api.gateway.amazonaws.com/prod/posts';
    _characterLimitController.text = '280';
  }

  @override
  void dispose() {
    _tabController.dispose();
    _apiEndpointController.dispose();
    _characterLimitController.dispose();
    super.dispose();
  }

  void _testConnection() async {
    setState(() {
      _isTestingConnection = true;
      _connectionStatus = '';
    });

    // Simulate API test
    await Future.delayed(const Duration(seconds: 2));

    setState(() {
      _isTestingConnection = false;
      _connectionStatus = 'success';
    });

    if (mounted) {
      HapticFeedback.lightImpact();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Connection test successful'),
          backgroundColor: AppTheme.lightTheme.colorScheme.tertiary,
        ),
      );
    }
  }

  void _showConfirmationDialog(
      String title, String content, VoidCallback onConfirm) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(content),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                onConfirm();
              },
              child: Text('Confirm'),
            ),
          ],
        );
      },
    );
  }

  void _clearDraftHistory() {
    HapticFeedback.lightImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Draft history cleared')),
    );
  }

  void _exportPosts() {
    HapticFeedback.lightImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Posts exported to JSON')),
    );
  }

  void _resetToDefaults() {
    setState(() {
      _apiEndpointController.text =
          'https://api.gateway.amazonaws.com/prod/posts';
      _characterLimitController.text = '280';
      _autoSaveEnabled = true;
      _successNotifications = true;
      _failureNotifications = true;
      _authMethod = 'API Key';
      _retentionPeriod = '30 days';
      _autoSaveFrequency = '5 minutes';
    });
    HapticFeedback.lightImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Settings reset to defaults')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text('PostMaster'),
        bottom: TabBar(
          controller: _tabController,
          onTap: (index) {
            if (index == 0) {
              Navigator.pushNamed(context, '/post-creation-screen');
            } else if (index == 1) {
              Navigator.pushNamed(context, '/post-history-screen');
            }
          },
          tabs: [
            Tab(
              icon: CustomIconWidget(
                iconName: 'create',
                color: AppTheme.lightTheme.colorScheme.onSurface,
                size: 20,
              ),
              text: 'Create',
            ),
            Tab(
              icon: CustomIconWidget(
                iconName: 'history',
                color: AppTheme.lightTheme.colorScheme.onSurface,
                size: 20,
              ),
              text: 'History',
            ),
            Tab(
              icon: CustomIconWidget(
                iconName: 'settings',
                color: AppTheme.lightTheme.colorScheme.primary,
                size: 20,
              ),
              text: 'Settings',
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // API Configuration Section
              SettingsSectionWidget(
                title: 'API Configuration',
                children: [
                  SettingsRowWidget(
                    title: 'Endpoint URL',
                    subtitle: 'AWS API Gateway endpoint',
                    trailing: SizedBox(
                      width: 200,
                      child: TextFormField(
                        controller: _apiEndpointController,
                        style: Theme.of(context).textTheme.bodySmall,
                        decoration: InputDecoration(
                          isDense: true,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        onChanged: (value) {
                          setState(() {
                            _connectionStatus = '';
                          });
                        },
                      ),
                    ),
                  ),
                  SettingsRowWidget(
                    title: 'Authentication Method',
                    trailing: DropdownButton<String>(
                      value: _authMethod,
                      underline: Container(),
                      items: _authMethods.map((String method) {
                        return DropdownMenuItem<String>(
                          value: method,
                          child: Text(method),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        if (newValue != null) {
                          setState(() {
                            _authMethod = newValue;
                          });
                        }
                      },
                    ),
                  ),
                  ApiTestWidget(
                    isLoading: _isTestingConnection,
                    status: _connectionStatus,
                    onTest: _testConnection,
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Post Preferences Section
              SettingsSectionWidget(
                title: 'Post Preferences',
                children: [
                  SettingsRowWidget(
                    title: 'Default Character Limit',
                    trailing: SizedBox(
                      width: 80,
                      child: TextFormField(
                        controller: _characterLimitController,
                        keyboardType: TextInputType.number,
                        style: Theme.of(context).textTheme.bodySmall,
                        decoration: InputDecoration(
                          isDense: true,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                  ),
                  SettingsRowWidget(
                    title: 'Auto-save Frequency',
                    trailing: DropdownButton<String>(
                      value: _autoSaveFrequency,
                      underline: Container(),
                      items: _autoSaveFrequencies.map((String frequency) {
                        return DropdownMenuItem<String>(
                          value: frequency,
                          child: Text(frequency),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        if (newValue != null) {
                          setState(() {
                            _autoSaveFrequency = newValue;
                          });
                        }
                      },
                    ),
                  ),
                  SettingsRowWidget(
                    title: 'Auto-save Enabled',
                    subtitle: 'Automatically save drafts',
                    trailing: Switch(
                      value: _autoSaveEnabled,
                      onChanged: (bool value) {
                        setState(() {
                          _autoSaveEnabled = value;
                        });
                        HapticFeedback.lightImpact();
                      },
                    ),
                  ),
                  SettingsRowWidget(
                    title: 'Draft Retention Period',
                    trailing: DropdownButton<String>(
                      value: _retentionPeriod,
                      underline: Container(),
                      items: _retentionPeriods.map((String period) {
                        return DropdownMenuItem<String>(
                          value: period,
                          child: Text(period),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        if (newValue != null) {
                          setState(() {
                            _retentionPeriod = newValue;
                          });
                        }
                      },
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Notifications Section
              SettingsSectionWidget(
                title: 'Notifications',
                children: [
                  SettingsRowWidget(
                    title: 'Success Alerts',
                    subtitle: 'Notify when posts are successful',
                    trailing: Switch(
                      value: _successNotifications,
                      onChanged: (bool value) {
                        setState(() {
                          _successNotifications = value;
                        });
                        HapticFeedback.lightImpact();
                      },
                    ),
                  ),
                  SettingsRowWidget(
                    title: 'Failure Alerts',
                    subtitle: 'Notify when posts fail',
                    trailing: Switch(
                      value: _failureNotifications,
                      onChanged: (bool value) {
                        setState(() {
                          _failureNotifications = value;
                        });
                        HapticFeedback.lightImpact();
                      },
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Data Management Section
              SettingsSectionWidget(
                title: 'Data Management',
                children: [
                  SettingsRowWidget(
                    title: 'Clear Draft History',
                    subtitle: 'Remove all saved drafts',
                    trailing: CustomIconWidget(
                      iconName: 'chevron_right',
                      color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                      size: 20,
                    ),
                    onTap: () {
                      _showConfirmationDialog(
                        'Clear Draft History',
                        'Are you sure you want to clear all saved drafts? This action cannot be undone.',
                        _clearDraftHistory,
                      );
                    },
                  ),
                  SettingsRowWidget(
                    title: 'Export Posts',
                    subtitle: 'Export posts in JSON format',
                    trailing: CustomIconWidget(
                      iconName: 'chevron_right',
                      color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                      size: 20,
                    ),
                    onTap: _exportPosts,
                  ),
                  SettingsRowWidget(
                    title: 'Reset to Defaults',
                    subtitle: 'Restore all settings to default values',
                    trailing: CustomIconWidget(
                      iconName: 'chevron_right',
                      color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                      size: 20,
                    ),
                    onTap: () {
                      _showConfirmationDialog(
                        'Reset to Defaults',
                        'Are you sure you want to reset all settings to their default values?',
                        _resetToDefaults,
                      );
                    },
                  ),
                ],
              ),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}
