import 'package:flutter/material.dart';
import 'package:se_wmp_project/pages/practice_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Home Page")),
      body: Center(
        child: ElevatedButton(
          child: const Text("Go to Practice"),
          onPressed: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => const PracticePage()));
          },
        ),
      ),
    );
  }
}