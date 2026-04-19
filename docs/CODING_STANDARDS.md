# Coding Standards: Flutter

To maintain project quality and performance, the following standards must be strictly followed by all contributors (human or AI).

## 🚫 No Widget-Returning Functions
**NEVER** use functions that return a `Widget` (e.g., `_buildHeader()`, `_getLogo()`).
- **Why?** It prevents Flutter from optimizing the widget tree and complicates Hot Reload and debugging.

### Correct Pattern: Private Class Widgets
Instead of a function, create a private `StatelessWidget` within the same file.

```dart
// ❌ WRONG
Widget _buildUserInfo() {
  return Text('Alex');
}

// ✅ CORRECT
class _UserInfo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Text('Alex');
  }
}
```

## 🏗️ View Structure
Every view should have a corresponding **ViewModel**.
- The View is responsible ONLY for layout.
- The ViewModel is responsible ONLY for logic.
- Avoid placing `if` conditions or complex logic inside the `build` method. Use ViewModel properties instead.

## 📱 Responsiveness
Always use `context.isMobile`, `context.isTablet`, or `context.isDesktop` (extensions on `BuildContext`) to adapt layouts. **Avoid hardcoding pixel-based checks** directly in views; use the breakpoints defined in `AppResponsive`.

## 🎨 Design Constancy
- Use `AppDimensions` for all padding, margins, and radii.
- Use `AppSpacerVertical` and `AppSpacerHorizontal` for spacing between elements.
- Never hardcode colors. Use `context.colorScheme` or `context.customColors`.
