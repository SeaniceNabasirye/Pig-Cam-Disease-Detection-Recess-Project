import 'package:flutter/material.dart';
import 'package:pigcam2/services/image_classification_service.dart';

class ClassificationResultWidget extends StatelessWidget {
  final List<ClassificationResult> results;
  final bool showDetails;

  const ClassificationResultWidget({
    Key? key,
    required this.results,
    this.showDetails = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (results.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Icon(
                Icons.warning_amber_rounded,
                color: Colors.orange,
                size: 48,
              ),
              SizedBox(height: 8),
              Text(
                'No classifications detected',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              Text(
                'The model did not detect any conditions above the confidence threshold.',
                style: Theme.of(context).textTheme.bodySmall,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.analytics,
                  color: Theme.of(context).primaryColor,
                ),
                SizedBox(width: 8),
                Text(
                  'Classification Results',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            ...results.map((result) => _buildResultItem(context, result)),
          ],
        ),
      ),
    );
  }

  Widget _buildResultItem(BuildContext context, ClassificationResult result) {
    final severityColor = _getSeverityColor(result.severity);
    final confidencePercentage = (result.confidence * 100).toStringAsFixed(1);

    return Container(
      margin: EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: severityColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: severityColor.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: severityColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  result.label,
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
              Spacer(),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.grey.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '$confidencePercentage%',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 8),
          Row(
            children: [
              Icon(
                _getSeverityIcon(result.severity),
                color: severityColor,
                size: 16,
              ),
              SizedBox(width: 4),
              Text(
                'Severity: ${result.severity}',
                style: TextStyle(
                  color: severityColor,
                  fontWeight: FontWeight.w500,
                  fontSize: 12,
                ),
              ),
              if (result.requiresAction) ...[
                SizedBox(width: 8),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'ACTION REQUIRED',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ],
          ),
          if (showDetails && result.description.isNotEmpty) ...[
            SizedBox(height: 8),
            Text(
              result.description,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ],
      ),
    );
  }

  Color _getSeverityColor(String severity) {
    switch (severity.toLowerCase()) {
      case 'none':
        return Colors.green;
      case 'low':
        return Colors.blue;
      case 'moderate':
        return Colors.orange;
      case 'high':
        return Colors.red;
      case 'very high':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  IconData _getSeverityIcon(String severity) {
    switch (severity.toLowerCase()) {
      case 'none':
        return Icons.check_circle;
      case 'low':
        return Icons.info;
      case 'moderate':
        return Icons.warning;
      case 'high':
      case 'very high':
        return Icons.error;
      default:
        return Icons.help;
    }
  }
} 