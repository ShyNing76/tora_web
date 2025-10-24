# Tora - Flutter MVVM Architecture App

Ứng dụng Flutter được xây dựng theo mô hình MVVM (Model-View-ViewModel) với kiến trúc clean và có thể mở rộng.

## 🏗️ Kiến trúc MVVM

### Cấu trúc thư mục

```
lib/
├── core/                          # Core functionality
│   ├── constants/                 # App constants, colors, themes
│   │   ├── app_constants.dart
│   │   ├── app_colors.dart
│   │   └── app_themes.dart
│   ├── services/                  # Business services
│   │   ├── api_service.dart      # HTTP API service
│   │   └── navigation_service.dart
│   └── utils/                     # Utility classes
├── models/                        # Data models (M in MVVM)
│   ├── user.dart
│   ├── user.g.dart               # Generated JSON serialization
│   ├── post.dart
│   └── post.g.dart
├── viewmodels/                    # ViewModels (VM in MVVM)
│   ├── base_viewmodel.dart       # Base ViewModel with common functionality
│   └── home_viewmodel.dart       # Home screen business logic
├── views/                         # UI Layer (V in MVVM)
│   ├── screens/                   # App screens
│   │   ├── home_screen.dart
│   │   ├── profile_screen.dart
│   │   └── settings_screen.dart
│   └── widgets/                   # Reusable widgets
│       ├── loading_widget.dart
│       ├── error_widget.dart
│       ├── user_selector.dart
│       └── post_list.dart
└── main.dart                      # App entry point
```

### Thành phần chính của MVVM

#### 1. **Model (M)**
- **Mục đích**: Đại diện cho dữ liệu và business logic
- **Vị trí**: `/lib/models/`
- **Ví dụ**: `User`, `Post`
- **Tính năng**: 
  - JSON serialization với `json_annotation`
  - Immutable data classes
  - Data validation

```dart
@JsonSerializable()
class User {
  final int id;
  final String name;
  final String email;
  // ...
}
```

#### 2. **View (V)**
- **Mục đích**: Hiển thị UI và handle user interactions
- **Vị trí**: `/lib/views/`
- **Đặc điểm**:
  - Stateless widgets khi có thể
  - Sử dụng `Consumer<ViewModel>` để lắng nghe thay đổi
  - Không chứa business logic

```dart
Consumer<HomeViewModel>(
  builder: (context, viewModel, child) {
    if (viewModel.isBusy) return LoadingWidget();
    return PostList(posts: viewModel.posts);
  },
)
```

#### 3. **ViewModel (VM)**
- **Mục đích**: Kết nối Model và View, chứa business logic
- **Vị trí**: `/lib/viewmodels/`
- **Đặc điểm**:
  - Extends `BaseViewModel` (ChangeNotifier)
  - Quản lý state (loading, error, data)
  - Không phụ thuộc vào Flutter widgets

```dart
class HomeViewModel extends BaseViewModel {
  List<User> _users = [];
  List<User> get users => _users;
  
  Future<void> loadUsers() async {
    final result = await runBusyFuture(_apiService.get('/users'));
    // Handle result...
  }
}
```

## 🚀 Tính năng

### State Management
- **Provider**: Quản lý state và dependency injection
- **Base ViewModel**: Class cơ sở với các functionality chung:
  - Loading states
  - Error handling
  - Async operation management

### API Integration
- **HTTP Service**: RESTful API client với error handling
- **JSON Serialization**: Tự động generate serialization code
- **Timeout Management**: Configurable request timeouts

### Navigation
- **Go Router**: Declarative routing
- **Navigation Service**: Centralized navigation management

### UI Components
- **Material Design 3**: Modern UI components
- **Custom Themes**: Light/Dark theme support
- **Responsive Widgets**: Reusable UI components

## 📦 Dependencies

### Production
```yaml
dependencies:
  flutter:
    sdk: flutter
  provider: ^6.1.2          # State management
  http: ^1.1.0              # HTTP client
  json_annotation: ^4.9.0   # JSON serialization
  go_router: ^13.2.0        # Navigation
```

### Development
```yaml
dev_dependencies:
  build_runner: ^2.4.8      # Code generation
  json_serializable: ^6.7.1 # JSON code generation
  flutter_lints: ^5.0.0     # Linting rules
```

## 🛠️ Setup và Chạy

### 1. Cài đặt dependencies
```bash
flutter pub get
```

### 2. Generate code cho models
```bash
dart run build_runner build
```

### 3. Chạy ứng dụng
```bash
# Web
flutter run -d web-server --web-port=8080

# Android/iOS
flutter run
```

## 🎯 Ưu điểm của MVVM

### 1. **Separation of Concerns**
- UI logic tách biệt với business logic
- Model không phụ thuộc vào UI
- Dễ test từng layer riêng biệt

### 2. **Testability**
- ViewModels có thể unit test dễ dàng
- Mock dependencies trong testing
- Test business logic độc lập với UI

### 3. **Maintainability**
- Code organization rõ ràng
- Dễ thêm tính năng mới
- Refactor an toàn

### 4. **Scalability**
- Cấu trúc project có thể mở rộng
- Reusable components
- Consistent patterns

## 📝 Best Practices

### 1. **ViewModel Guidelines**
- Không import Flutter widgets trong ViewModel
- Sử dụng `runBusyFuture` cho async operations
- Handle errors properly
- Keep ViewModels focused on single responsibility

### 2. **View Guidelines**
- Sử dụng `Consumer` hoặc `Selector` để listen changes
- Minimal logic trong widgets
- Extract common widgets để reuse

### 3. **Model Guidelines**
- Immutable data classes
- Implement `toString()`, `==`, `hashCode`
- Use JSON serialization cho API integration

## 🔄 Data Flow

```
User Interaction → View → ViewModel → Model → API
                    ↑        ↓         ↓      ↓
                    ←────── State ←─── Data ←──
```

1. User tương tác với View (tap button, scroll, etc.)
2. View gọi methods trong ViewModel
3. ViewModel xử lý business logic và gọi Model/API
4. Model/API trả về data
5. ViewModel update state và notify Views
6. Views tự động rebuild với data mới

## 🧪 Testing Strategy

### Unit Tests
- Test ViewModels business logic
- Test Models data transformation
- Test Services API integration

### Widget Tests
- Test UI components behavior
- Test user interactions
- Test state changes in UI

### Integration Tests
- Test complete user flows
- Test navigation between screens
- Test API integration end-to-end

## 📱 Screens và Features

### Home Screen
- Hiển thị danh sách users
- User selection
- Posts management (CRUD)
- Pull-to-refresh
- Error handling với retry

### Profile Screen
- User profile information
- Placeholder for future features

### Settings Screen
- App settings
- Theme switching (future)
- Placeholder for configurations

## 🔮 Future Enhancements

- [ ] User authentication
- [ ] Local database (SQLite/Hive)
- [ ] Push notifications
- [ ] Offline support
- [ ] Image handling
- [ ] Advanced state management (Bloc/Riverpod)
- [ ] Localization (i18n)
- [ ] Advanced testing coverage

---

Ứng dụng này demonstrator cách implement MVVM architecture trong Flutter một cách clean, scalable và maintainable. Phù hợp cho các dự án từ small đến enterprise-level.
