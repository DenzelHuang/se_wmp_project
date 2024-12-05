import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:se_wmp_project/pages/home_page.dart';
import 'package:se_wmp_project/pages/scanner_page.dart';
import 'package:se_wmp_project/pages/courses_page.dart';
import 'package:se_wmp_project/pages/dictionary_page.dart';
import 'package:se_wmp_project/providers/language_provider.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        // Initialize LanguageProvider for state management
        ChangeNotifierProvider(create: (_) => LanguageProvider()),
      ],
      child: const MyApp(),
    ),
  );
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
      home: const BottomNavBarApp(), // Set the home to the new widget
    );
  }
}

class BottomNavBarApp extends StatefulWidget {
  const BottomNavBarApp({super.key});

  @override
  State<BottomNavBarApp> createState() => _BottomNavBarAppState();
}

class _BottomNavBarAppState extends State<BottomNavBarApp> {
  int _selectedIndex = 0;

  static final List<Widget> _widgetOptions = <Widget>[
    const HomePage(),
    CoursesPage(),
    const ScannerPage(),
    DictionaryPage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _widgetOptions.elementAt(_selectedIndex),
      bottomNavigationBar: BottomNavigationBar(
        selectedItemColor: Colors.blue, // Active icon color
        unselectedItemColor: Colors.grey, // Inactive icon color
        backgroundColor: Colors.white, // Background color of the navbar
        type: BottomNavigationBarType
            .fixed, // Fixes shifting when more than 3 items
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.school),
            label: 'Course',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.camera_alt),
            label: 'Scanner',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.menu_book), // Appropriate icon for dictionary
            label: 'Dictionary',
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}
