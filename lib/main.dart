import 'package:flutter/material.dart';
import 'package:se_wmp_project/pages/home_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue, // Base color for the app
        scaffoldBackgroundColor: Colors.white, // Background for pages
        primaryColor: Colors.blue, // Main color for the app
        colorScheme: ColorScheme.fromSwatch(
          primarySwatch: Colors.blue,
        ).copyWith(
          secondary: Colors.blueAccent, // Color for accent elements
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.blue, // Apply color to AppBar
          foregroundColor: Colors.white, // Text/icon color for AppBar
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue, // Button background color
            foregroundColor: Colors.white, // Button text color
          ),
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: Colors.blue, // TextButton color
          ),
        ),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: Colors.blue, // FloatingActionButton color
        ),
      ),
      home: const HomePage(),
    );
  }
}