import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:loyalty_card_app/services/auth_service.dart';
import 'package:loyalty_card_app/services/card_service.dart';
import 'package:loyalty_card_app/services/sync_service.dart';
import 'package:loyalty_card_app/widgets/confirmation_dialog.dart';
import 'package:loyalty_card_app/widgets/settings_tile.dart';
import 'package:package_info_plus/package_info_plus.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String _appVersion = '';
  bool _isLoading = false;
  
  @override
  void initState() {
    super.initState();
    _loadAppVersion();
  }
  
  Future<void> _loadAppVersion() async {
    final packageInfo = await PackageInfo.fromPlatform();
    setState(() {
      _appVersion = '${packageInfo.version} (${packageInfo.buildNumber})';
    });
  }
  
  Future<void> _forceSync() async {
    setState(() {
      _isLoading = true;
    });
    // Sync is disabled in dummy mode
    await Future.delayed(const Duration(seconds: 1));
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Sync is disabled in demo mode'),
        ),
      );
      setState(() {
        _isLoading = false;
      });
    }
  }
  
  Future<void> _signOut() async {
    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      await authService.signOut();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Sign out failed: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
  
  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    final syncService = Provider.of<SyncService>(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                children: [
                  // User profile header
                  FutureBuilder<Map<String, String?>> (
                    future: authService.getUserInfo(),
                    builder: (context, snapshot) {
                      final userInfo = snapshot.data ?? {};
                      return Container(
                        padding: const EdgeInsets.all(24),
                        color: Theme.of(context).primaryColor,
                        child: Column(
                          children: [
                            // User avatar
                            CircleAvatar(
                              radius: 50,
                              backgroundColor: Colors.white,
                              child: const Icon(Icons.person, size: 50, color: Colors.grey),
                            ),
                            const SizedBox(height: 16),
                            // User name
                            Text(
                              userInfo['displayName'] ?? 'User',
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 4),
                            // User email
                            Text(
                              userInfo['email'] ?? '',
                              style: const TextStyle(
                                fontSize: 16,
                                color: Colors.white70,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                  
                  // Settings
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Settings',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        
                        // Sync status
                        SettingsTile(
                          icon: Icons.sync,
                          title: 'Sync Status',
                          subtitle: syncService.isOnline
                              ? 'Online - Last sync: ${syncService.lastSyncTime != null ? _formatDateTime(syncService.lastSyncTime!) : 'Never'}' 
                              : 'Offline - Changes will sync when online',
                          trailing: syncService.isOnline
                              ? IconButton(
                                  icon: const Icon(Icons.refresh),
                                  onPressed: _forceSync,
                                )
                              : null,
                        ),
                        
                        // Notifications
                        SettingsTile(
                          icon: Icons.notifications,
                          title: 'Notifications',
                          subtitle: 'Manage notification settings',
                          onTap: () {
                            // Navigate to notification settings
                          },
                        ),
                        
                        // Theme
                        SettingsTile(
                          icon: Icons.color_lens,
                          title: 'Theme',
                          subtitle: 'Change app appearance',
                          onTap: () {
                            // Navigate to theme settings
                          },
                        ),
                        
                        // About
                        SettingsTile(
                          icon: Icons.info,
                          title: 'About',
                          subtitle: 'Version $_appVersion',
                          onTap: () {
                            // Show about dialog
                          },
                        ),
                        
                        const SizedBox(height: 24),
                        
                        // Sign out button
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (context) => ConfirmationDialog(
                                  title: 'Sign Out',
                                  content: 'Are you sure you want to sign out?',
                                  confirmText: 'Sign Out',
                                  onConfirm: _signOut,
                                ),
                              );
                            },
                            icon: const Icon(Icons.logout),
                            label: const Text('Sign Out'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
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
  
  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}
