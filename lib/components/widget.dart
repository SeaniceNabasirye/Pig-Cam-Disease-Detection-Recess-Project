import 'package:flutter/material.dart';

// Button Styles
final ButtonStyle outlinedButtonStyle = OutlinedButton.styleFrom(
  foregroundColor: Colors.lightBlue,
  side: const BorderSide(color: Colors.lightBlue),
);

// Text Field Styles
const InputDecoration greenBorderTextFieldDecoration = InputDecoration(
  border: OutlineInputBorder(
    borderSide: BorderSide(color: Colors.green),
  ),
  focusedBorder: OutlineInputBorder(
    borderSide: BorderSide(color: Colors.green, width: 2.0),
  ),
  enabledBorder: OutlineInputBorder(
    borderSide: BorderSide(color: Colors.green),
  ),
);

// Background Styles
// This would typically be implemented with custom paint or a package for effects.
// For demonstration, a simple themed background color is provided.
BoxDecoration themedBackgroundDecoration(BuildContext context) {
  return BoxDecoration(
    color: Theme.of(context).brightness == Brightness.light
        ? Colors.white
        : Colors.grey[900],
  );
}


// Light and Dark Mode Themes
final ThemeData lightTheme = ThemeData(
  brightness: Brightness.light,
  primarySwatch: Colors.deepPurple,
  colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple, brightness: Brightness.light),
  outlinedButtonTheme: OutlinedButtonThemeData(style: outlinedButtonStyle),

);

final ThemeData darkTheme = ThemeData(
  brightness: Brightness.dark,
  primarySwatch: Colors.indigo,
  colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo, brightness: Brightness.dark),
  outlinedButtonTheme: OutlinedButtonThemeData(style: outlinedButtonStyle),
  
);

// Notification Format (Conceptual - actual implementation depends on a notification package)
// This would involve a StatefulWidget to manage multiple notifications, perhaps a ListView.builder
// of SnackBar or custom dialogs.
// Example of a basic notification structure:
class CustomNotification {
  final String title;
  final String message;
  final IconData icon;
  final Color color;

  CustomNotification({required this.title, required this.message, required this.icon, required this.color});
}

// Carousel Format (Horizontal Carousel)
// This typically uses a PageView or a package like carousel_slider.
// Example:
/*
PageView(
  scrollDirection: Axis.horizontal,
  children: <Widget>[
    // Your carousel items here
    Container(color: Colors.red),
    Container(color: Colors.blue),
    Container(color: Colors.green),
  ],
);
*/

// Progress Indicator Style (Line Progress Indicator)
Widget lineProgressIndicator = const LinearProgressIndicator(
  valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
  backgroundColor: Colors.grey,
);

// Chart List Formats (Pie Charts)
// This would require a charting library like `fl_chart` or `charts_flutter`.
// Example (conceptual, requires a library):
/*
PieChart(
  PieChartData(
    sections: [
      PieChartSectionData(value: 40, color: Colors.blue),
      PieChartSectionData(value: 30, color: Colors.green),
      PieChartSectionData(value: 20, color: Colors.red),
    ],
  ),
);
*/ 