import 'package:http/http.dart' as http;
import 'dart:convert';

// Your Flask Server's IP and Port
const String flaskServerIp = '10.10.168.48'; // Your PC's IP
const int flaskServerPort = 5000;

Future<Map<String, dynamic>> fetchPredictionResults() async {
  try {
    final response = await http.get(Uri.parse('http://$flaskServerIp:$flaskServerPort/results'));

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      print('Failed to load results: ${response.statusCode}');
      return {'status': 'Error', 'predicted_class': 'N/A', 'confidence': 0.0};
    }
  } catch (e) {
    print('Error fetching results: $e');
    return {'status': 'Network Error', 'predicted_class': 'N/A', 'confidence': 0.0};
  }
}
