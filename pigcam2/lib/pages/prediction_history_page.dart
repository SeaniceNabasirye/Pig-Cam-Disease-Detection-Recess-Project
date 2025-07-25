import 'package:flutter/material.dart';

class PredictionHistoryPage extends StatefulWidget {
  const PredictionHistoryPage({Key? key}) : super(key: key);

  @override
  State<PredictionHistoryPage> createState() => _PredictionHistoryPageState();
}

class _PredictionHistoryPageState extends State<PredictionHistoryPage> {
  List<Map<String, dynamic>> _predictions = [];

  @override
  void initState() {
    super.initState();
    _loadPredictions();
  }

  Future<void> _loadPredictions() async {
    // Simulate loading prediction history from storage or provider
    await Future.delayed(const Duration(milliseconds: 500));
    setState(() {
      _predictions = [
        {
          'result': 'Healthy',
          'timestamp': '2024-06-01 10:00:00',
          'details': 'Prediction based on image analysis showing healthy pigs.',
        },
        {
          'result': 'Sick',
          'timestamp': '2024-06-02 14:30:00',
          'details':
              'Prediction based on image analysis showing signs of illness.',
        },
      ];
    });
  }

  void _clearHistory() {
    // Simulate clearing prediction history from storage or provider
    setState(() {
      _predictions.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Prediction History'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: _clearHistory,
            tooltip: 'Clear History',
          ),
        ],
      ),
      body: _predictions.isEmpty
          ? const Center(child: Text('No prediction history found'))
          : ListView.builder(
              itemCount: _predictions.length,
              itemBuilder: (context, index) {
                final prediction = _predictions[index];
                return ListTile(
                  title: Text(prediction['result'] ?? 'Unknown'),
                  subtitle: Text(prediction['timestamp'] ?? ''),
                  onTap: () {
                    final prediction = _predictions[index];
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: Text('Prediction Details'),
                        content: Text(
                          prediction['details'] ?? 'No details available.',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(),
                            child: const Text('Close'),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
    );
  }
}
