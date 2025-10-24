import 'package:flutter/material.dart';
import '../models/course.dart';
import '../services/course_service.dart';

class CourseViewModel extends ChangeNotifier {
  final CourseService _courseService = CourseService();
  
  bool _isLoading = false;
  String? _errorMessage;
  List<Course> _courses = [];
  Map<String, dynamic>? _metadata;
  
  // Getters
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  List<Course> get courses => _courses;
  Map<String, dynamic>? get metadata => _metadata;
  
  // Clear error message
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
  
  // Fetch all courses
  Future<bool> fetchCourses({
    int page = 1,
    int pageSize = 10,
    String? searchQuery,
    String? type,
    String? level,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    
    try {
      final result = await _courseService.getCourses(
        page: page,
        pageSize: pageSize,
        searchQuery: searchQuery,
        type: type,
        level: level,
      );
      
      if (result['success'] == true) {
        _courses = result['courses'] ?? [];
        _metadata = result['metadata'];
        
        print('✅ Fetched ${_courses.length} courses successfully');
        
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage = result['message'] ?? 'Không thể tải danh sách khóa học';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      print('❌ Fetch courses error: $e');
      _errorMessage = 'Có lỗi xảy ra khi tải danh sách khóa học';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
  
  // Fetch course by ID
  Future<Course?> fetchCourseById(String courseId) async {
    try {
      final result = await _courseService.getCourseById(courseId);
      
      if (result['success'] == true) {
        return result['course'] as Course?;
      } else {
        _errorMessage = result['message'] ?? 'Không thể tải thông tin khóa học';
        notifyListeners();
        return null;
      }
    } catch (e) {
      print('❌ Fetch course detail error: $e');
      _errorMessage = 'Có lỗi xảy ra khi tải thông tin khóa học';
      notifyListeners();
      return null;
    }
  }
}
