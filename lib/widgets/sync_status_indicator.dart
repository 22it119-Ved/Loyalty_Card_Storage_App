import 'package:flutter/material.dart';

class SyncStatusIndicator extends StatelessWidget {
  final bool isOnline;
  final bool isSyncing;
  final DateTime? lastSyncTime;
  
  const SyncStatusIndicator({
    Key? key,
    required this.isOnline,
    required this.isSyncing,
    this.lastSyncTime,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 16),
      color: isOnline ? Colors.green.shade100 : Colors.orange.shade100,
      child: Row(
        children: [
          Icon(
            isOnline ? Icons.cloud_done : Icons.cloud_off,
            size: 16,
            color: isOnline ? Colors.green.shade700 : Colors.orange.shade700,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              isOnline
                  ? isSyncing
                      ? 'Syncing...'
                      : lastSyncTime != null
                          ? 'Online - Last sync: ${_formatDateTime(lastSyncTime!)}'
                          : 'Online - Ready to sync'
                  : 'Offline - Changes will sync when online',
              style: TextStyle(
                fontSize: 12,
                color: isOnline ? Colors.green.shade700 : Colors.orange.shade700,
              ),
            ),
          ),
          if (isSyncing)
            SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(
                  isOnline ? Colors.green.shade700 : Colors.orange.shade700,
                ),
              ),
            ),
        ],
      ),
    );
  }
  
  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}
