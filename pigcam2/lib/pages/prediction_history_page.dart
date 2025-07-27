import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pigcam2/models/classification_history.dart';
import 'package:pigcam2/widgets/classification_result_widget.dart';
import 'package:pigcam2/widgets/platform_image_widget.dart';
import 'dart:io';

class PredictionHistoryPage extends StatefulWidget {
  const PredictionHistoryPage({Key? key}) : super(key: key);

  @override
  _PredictionHistoryPageState createState() => _PredictionHistoryPageState();
}

class _PredictionHistoryPageState extends State<PredictionHistoryPage> {
  String _selectedFilter = 'all';
  String _selectedSource = 'all';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Classification History'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              setState(() {
                _selectedFilter = value;
              });
            },
            itemBuilder: (context) => [
              PopupMenuItem(value: 'all', child: Text('All Results')),
              PopupMenuItem(value: 'action_required', child: Text('Action Required')),
              PopupMenuItem(value: 'high_severity', child: Text('High Severity')),
            ],
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Icon(Icons.filter_list),
            ),
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              setState(() {
                _selectedSource = value;
              });
            },
            itemBuilder: (context) => [
              PopupMenuItem(value: 'all', child: Text('All Sources')),
              PopupMenuItem(value: 'camera', child: Text('Camera')),
              PopupMenuItem(value: 'gallery', child: Text('Gallery')),
              PopupMenuItem(value: 'stream', child: Text('Stream')),
            ],
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Icon(Icons.source),
            ),
          ),
        ],
      ),
      body: Consumer<ClassificationHistoryProvider>(
        builder: (context, historyProvider, child) {
          final filteredHistory = _getFilteredHistory(historyProvider.history);

          if (filteredHistory.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.history,
                    size: 64,
                    color: Colors.grey,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'No classification history',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Start classifying images to see your history here',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }

          return Column(
            children: [
              // Filter Summary
              Container(
                padding: EdgeInsets.all(16),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.blue),
                    SizedBox(width: 8),
                    Text(
                      'Showing ${filteredHistory.length} of ${historyProvider.history.length} results',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    Spacer(),
                    TextButton.icon(
                      onPressed: () {
                        _showClearHistoryDialog(context, historyProvider);
                      },
                      icon: Icon(Icons.clear_all, color: Colors.red),
                      label: Text('Clear History', style: TextStyle(color: Colors.red)),
                    ),
                  ],
                ),
              ),
              
              // History List
              Expanded(
                child: ListView.builder(
                  itemCount: filteredHistory.length,
                  itemBuilder: (context, index) {
                    final item = filteredHistory[index];
                    return _buildHistoryItem(context, item);
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  List<ClassificationHistoryItem> _getFilteredHistory(List<ClassificationHistoryItem> history) {
    var filtered = history;

    // Filter by source
    if (_selectedSource != 'all') {
      filtered = filtered.where((item) => item.source == _selectedSource).toList();
    }

    // Filter by results
    switch (_selectedFilter) {
      case 'action_required':
        filtered = filtered.where((item) => 
          item.results.any((result) => result.requiresAction)
        ).toList();
        break;
      case 'high_severity':
        filtered = filtered.where((item) => 
          item.results.any((result) => 
            result.severity.toLowerCase().contains('high') || 
            result.severity.toLowerCase().contains('very high')
          )
        ).toList();
        break;
    }

    return filtered;
  }

  Widget _buildHistoryItem(BuildContext context, ClassificationHistoryItem item) {
    final hasActionRequired = item.results.any((result) => result.requiresAction);
    final hasHighSeverity = item.results.any((result) => 
      result.severity.toLowerCase().contains('high') || 
      result.severity.toLowerCase().contains('very high')
    );

    return Card(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ExpansionTile(
        leading: CircleAvatar(
          backgroundColor: _getSourceColor(item.source),
          child: Icon(
            _getSourceIcon(item.source),
            color: Colors.white,
          ),
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                '${item.results.length} condition(s) detected',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            if (hasActionRequired)
              Container(
                padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'ACTION',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            if (hasHighSeverity)
              Container(
                margin: EdgeInsets.only(left: 4),
                padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.orange,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'HIGH',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Source: ${_getSourceDisplayName(item.source)}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            Text(
              'Date: ${_formatDateTime(item.timestamp)}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
        children: [
          // Image preview
          if (File(item.imagePath).existsSync())
            Container(
              height: 200,
              margin: EdgeInsets.all(16),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: PlatformImageWidget(
                  imagePath: item.imagePath,
                  fit: BoxFit.cover,
                  width: double.infinity,
                ),
              ),
            ),
          
          // Classification results
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: ClassificationResultWidget(
              results: item.results,
              showDetails: true,
            ),
          ),
          
          // Action buttons
          Padding(
            padding: EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed: () => _shareResults(item),
                  icon: Icon(Icons.share),
                  label: Text('Share'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () => _deleteHistoryItem(item),
                  icon: Icon(Icons.delete),
                  label: Text('Delete'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getSourceColor(String source) {
    switch (source) {
      case 'camera':
        return Colors.blue;
      case 'gallery':
        return Colors.orange;
      case 'stream':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  IconData _getSourceIcon(String source) {
    switch (source) {
      case 'camera':
        return Icons.camera_alt;
      case 'gallery':
        return Icons.photo_library;
      case 'stream':
        return Icons.videocam;
      default:
        return Icons.image;
    }
  }

  String _getSourceDisplayName(String source) {
    switch (source) {
      case 'camera':
        return 'Device Camera';
      case 'gallery':
        return 'Photo Gallery';
      case 'stream':
        return 'ESP32 Stream';
      default:
        return 'Unknown';
    }
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  void _shareResults(ClassificationHistoryItem item) {
    // TODO: Implement sharing functionality
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Share functionality coming soon!'),
        backgroundColor: Colors.blue,
      ),
    );
  }

  void _deleteHistoryItem(ClassificationHistoryItem item) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete History Item'),
        content: Text('Are you sure you want to delete this classification result?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              // TODO: Implement delete functionality
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Delete functionality coming soon!'),
                  backgroundColor: Colors.orange,
                ),
              );
            },
            child: Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showClearHistoryDialog(BuildContext context, ClassificationHistoryProvider historyProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Clear History'),
        content: Text('Are you sure you want to clear all classification history? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              historyProvider.clearHistory();
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('History cleared successfully'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            child: Text('Clear All', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
