import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:se_wmp_project/providers/language_provider.dart';
import 'package:se_wmp_project/providers/user_provider.dart';

class CourseProvider with ChangeNotifier {
  String? _selectedCourseId;
  String? _selectedCourseTitle;

  String? get selectedCourseId => _selectedCourseId;
  String? get selectedCourseTitle => _selectedCourseTitle;

  // Select a course and fetch its title from Firestore
  Future<void> selectCourse(BuildContext context, String courseId) async {
    final userId = Provider.of<UserProvider>(context, listen: false).uid;
    final languageProvider =
        Provider.of<LanguageProvider>(context, listen: false);
    final selectedLanguage = languageProvider.selectedLanguage;

    _selectedCourseId = courseId;

    try {
      // Reference to the course document in the Firestore collection
      DocumentSnapshot courseSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('courses')
          .doc(selectedLanguage)
          .collection('lessons')
          .doc(courseId)
          .get();

      if (courseSnapshot.exists) {
        _selectedCourseTitle =
            courseSnapshot.get('title'); // Assuming 'title' field exists
      } else {
        _selectedCourseTitle = null;
        print('Course not found');
      }
    } catch (e) {
      print('Error fetching course title: $e');
      _selectedCourseTitle = null;
    }

    // Notify listeners only once, after all updates are done
    notifyListeners();
  }
}
