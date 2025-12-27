---
description: how to use and customize the dynamic theme system
---

# Flutter Dynamic Theme System

A complete guide to using the dynamic theme system with support for **Light**, **Dark**, and **System** (auto-follows device) theme modes.

---

## ✨ Features

- ✅ Three theme modes: Light, Dark, System (auto-detect)
- ✅ Persists user preference across app restarts
- ✅ Real-time system theme detection (when System mode is selected)
- ✅ Reactive UI updates using MobX
- ✅ Clean context extensions for theme-aware color access
- ✅ System UI overlay styling (status bar, navigation bar)
- ✅ Material 3 support

---

## 📁 Key Files

```
lib/
├── app_theme.dart                          # Theme definitions (light/dark)
├── store/
│   └── AppStore.dart                       # MobX store with setDarkMode/setThemeModeIndex
├── utils/
│   ├── constant.dart                       # Theme mode constants (THEME_MODE_LIGHT/DARK/SYSTEM)
│   ├── theme_colors.dart                   # Color definitions (LightThemeColors, DarkThemeColors)
│   └── context_extensions.dart             # Theme color extensions on BuildContext
└── components/
    └── theme_selection_dailog.dart         # Theme picker UI
```

---

## 📖 Usage Examples

### 1. Access Theme Colors Anywhere

```dart
// In any widget with BuildContext:

// Primary brand color
Color primary = context.primary;

// Text colors
Color mainText = context.primaryTextColor;  // or context.onSurface
Color mutedText = context.secondaryTextColor;  // or context.onSurfaceVariant

// Background colors
Color background = context.scaffold;
Color cardBg = context.card;
Color componentBg = context.surface;

// Container colors
Color greenContainer = context.primaryContainer;
Color lightGreenContainer = context.secondaryContainer;

// Icon colors
Color icon = context.icon;  // or context.onSurface
Color mutedIcon = context.iconMuted;

// Border colors
Color inputBorder = context.outline;
Color greenBorder = context.greenBorderColor;

// Check current theme
bool isDark = context.isDarkMode;

// Error/Success colors
Color errorColor = context.error;
Color successColor = context.successColor;

// Dialog colors
Color dialogBg = context.dialogBackgroundColor;
```

### 2. Toggle Theme Programmatically

```dart
// Import appStore
import 'package:handyman_provider_flutter/main.dart';
import 'package:handyman_provider_flutter/utils/constant.dart';

// Set to dark mode
await appStore.setThemeModeIndex(THEME_MODE_DARK);

// Set to light mode
await appStore.setThemeModeIndex(THEME_MODE_LIGHT);

// Follow system
await appStore.setThemeModeIndex(THEME_MODE_SYSTEM);
```

### 3. Show Theme Picker Dialog

```dart
// Import the dialog
import 'package:handyman_provider_flutter/components/theme_selection_dailog.dart';

// Use the new helper function
showThemeSelectionDialog(context);

// Or use the legacy widget directly
showDialog(
  context: context,
  builder: (context) => Dialog(
    child: ThemeSelectionDialog(),
  ),
);
```

---

## 🎨 Context Extensions Reference

### ColorScheme Accessors (Auto theme-aware)
| Extension | Description |
|-----------|-------------|
| `context.primary` | Primary brand color |
| `context.onPrimary` | Color on primary |
| `context.primaryContainer` | Shaded green container |
| `context.onPrimaryContainer` | Text on primary container |
| `context.secondary` | Secondary color |
| `context.secondaryContainer` | Light shaded green container |
| `context.onSecondaryContainer` | Text on secondary container |
| `context.surface` | Surface/component background |
| `context.onSurface` | Text on surface |
| `context.onSurfaceVariant` | Hint/muted text |
| `context.outline` | Input border color |
| `context.error` | Error color |

### Semantic Aliases
| Extension | Maps To | Description |
|-----------|---------|-------------|
| `context.primaryTextColor` | `onSurface` | Primary text color |
| `context.secondaryTextColor` | `onSurfaceVariant` | Muted text color |
| `context.hintTextColor` | `onSurfaceVariant` | Hint text color |
| `context.icon` | `onSurface` | Main icon color |
| `context.iconMuted` | `onSurfaceVariant` | Muted icon color |
| `context.inputBorderColor` | `outline` | Input field border |

### Custom Colors (Need manual dark/light handling)
| Extension | Description |
|-----------|-------------|
| `context.dialogBackgroundColor` | Dialog background |
| `context.bottomSheetBackgroundColor` | Bottom sheet background |
| `context.serviceComponentColor` | Service/provider component bg |
| `context.successColor` | Success indicator color |
| `context.greenBorderColor` | Green border color |
| `context.mainDividerColor` | Main divider color |

---

## 🔧 Theme Mode Constants

```dart
const THEME_MODE_LIGHT = 0;   // Force light mode
const THEME_MODE_DARK = 1;    // Force dark mode
const THEME_MODE_SYSTEM = 2;  // Follow system setting

const THEME_MODE_INDEX = 'THEME_MODE_INDEX';  // SharedPreferences key
```

---

## 🐛 Troubleshooting

### Issue: Theme doesn't update immediately
Make sure your `MaterialApp` is wrapped with `Observer`:
```dart
Observer(
  builder: (_) => MaterialApp(
    themeMode: appStore.isDarkMode ? ThemeMode.dark : ThemeMode.light,
    ...
  ),
)
```

### Issue: `iconColor` conflict
Use `context.icon` instead of `context.iconColor` to avoid conflicts with nb_utils extensions.

### Issue: System theme changes not detected
Ensure your `State` class:
1. Mixes in `WidgetsBindingObserver`
2. Calls `WidgetsBinding.instance.addObserver(this)` in `initState`
3. Calls `WidgetsBinding.instance.removeObserver(this)` in `dispose`
4. Overrides `didChangePlatformBrightness()`

### Issue: Status bar icons not visible
The `setDarkMode` action automatically updates `SystemUiOverlayStyle`. Make sure you're calling `appStore.setThemeModeIndex()` instead of directly setting variables.

---

## 📝 Adding New Colors

1. Add color to `LightThemeColors` and `DarkThemeColors` in `utils/theme_colors.dart`
2. Add extension accessor in `utils/context_extensions.dart`
3. Use via `context.yourNewColor`

Example:
```dart
// In theme_colors.dart
class LightThemeColors {
  static const Color newColor = Color(0xFF..);
}
class DarkThemeColors {
  static const Color newColor = Color(0xFF..);
}

// In context_extensions.dart
Color get newColor => isDarkMode
    ? DarkThemeColors.newColor
    : LightThemeColors.newColor;

// Usage
Container(color: context.newColor)
```

---

**Happy theming! 🎨**
