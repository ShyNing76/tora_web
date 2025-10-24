import '../models/user.dart';
import '../models/post.dart';
import '../../../viewmodels/base_viewmodel.dart';

class HomeViewModel extends BaseViewModel {
  
  List<User> _users = [];
  List<Post> _posts = [];
  User? _selectedUser;
  
  List<User> get users => _users;
  List<Post> get posts => _posts;
  User? get selectedUser => _selectedUser;
  
  // Filtered posts for selected user
  // List<Post> get userPosts {
  //   if (_selectedUser == null) return _posts;
  //   return _posts.where((post) => post.userId == _selectedUser!.id).toList();
  // }

  // Future<void> loadInitialData() async {
  //   await runBusyFuture(_loadData());
  // }

  // Future<void> _loadData() async {
  //   // Load users and posts concurrently
  //   await Future.wait([
  //     _loadUsers(),
  //     _loadPosts(),
  //   ]);
  // }

  // Future<void> _loadUsers() async {
  //   try {
  //     final response = await _apiService.get('/users');
  //     if (response is List) {
  //       _users = response.map((json) => User.fromJson(json as Map<String, dynamic>)).toList();
  //       if (_users.isNotEmpty) {
  //         _selectedUser = _users.first;
  //       }
  //     }
  //   } catch (e) {
  //     throw Exception('Failed to load users: $e');
  //   }
  // }

  // Future<void> _loadPosts() async {
  //   try {
  //     final response = await _apiService.get('/posts');
  //     if (response is List) {
  //       _posts = response.map((json) => Post.fromJson(json as Map<String, dynamic>)).toList();
  //     }
  //   } catch (e) {
  //     throw Exception('Failed to load posts: $e');
  //   }
  // }

  // void selectUser(User user) {
  //   _selectedUser = user;
  //   notifyListeners();
  // }

  // Future<void> refreshData() async {
  //   clearError();
  //   await loadInitialData();
  // }

  // Future<void> createPost(String title, String body) async {
  //   if (_selectedUser == null) return;

  //   final result = await runBusyFuture(_createPost(title, body));
  //   if (result != null) {
  //     // Add the new post to the list
  //     _posts.insert(0, result);
  //     notifyListeners();
  //   }
  // }

  // Future<Post> _createPost(String title, String body) async {
  //   try {
  //     final response = await _apiService.post('/posts', {
  //       'title': title,
  //       'body': body,
  //       'userId': _selectedUser!.id,
  //     });
  //     return Post.fromJson(response);
  //   } catch (e) {
  //     throw Exception('Failed to create post: $e');
  //   }
  // }

  // Future<void> deletePost(int postId) async {
  //   final result = await runBusyFuture(_deletePost(postId));
  //   if (result != null) {
  //     _posts.removeWhere((post) => post.id == postId);
  //     notifyListeners();
  //   }
  // }

  // Future<bool> _deletePost(int postId) async {
  //   try {
  //     await _apiService.delete('/posts/$postId');
  //     return true;
  //   } catch (e) {
  //     throw Exception('Failed to delete post: $e');
  //   }
  // }
}