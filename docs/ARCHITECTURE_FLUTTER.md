# Flutter Architecture: MVVM Pattern

The `aisend` project follows a strict **MVVM (Model-View-ViewModel)** architecture to ensure separation of concerns and testability.

## 📁 Folder Structure
- `lib/models/`: Data classes (JSON serialization).
- `lib/views/`: UI Layer (StatelessWidgets or StatefullWidgets).
- `lib/view_models/`: Business logic and state management using `ChangeNotifier`.
- `lib/data/services/`: API communication and external data handling.
- `lib/core/`: Constants, themes, and shared utilities.

## 🔄 State Management
- **Provider**: Used for Dependency Injection and connecting ViewModels to Views.
- **ChangeNotifier**: All ViewModels extend `ChangeNotifier` and use `notifyListeners()` to update the UI.

## 🏗️ MVVM Workflow
1. **View** (@ `lib/views`) calls a method in the **ViewModel**.
2. **ViewModel** (@ `lib/view_models`) calls a **Service** (@ `lib/data/services`).
3. **Service** performs an HTTP request and returns a **Model** (@ `lib/models`).
4. **ViewModel** updates its internal state and calls `notifyListeners()`.
5. **View** (rebuilt via `context.watch<T>()`) reflects the changes.

## 🎨 Design System
- **Theme Extensions**: We use `CustomColors` and `AppDimensions` extensions to keep colors and spacing standardized.
- **Material 3**: The app is built with Material 3 components for a premium, modern feel.
