# Design: UI Design System — AiSend

**Feature ID:** ui-design-system  
**Status:** Approved  
**Created:** 2026-04-29

---

## Architecture Overview

```
lib/
├── core/
│   ├── providers/
│   │   └── theme_provider.dart          ← NOVO: ThemeMode + SharedPreferences
│   ├── theme/
│   │   ├── app_colors.dart              ← MODIFY: duas classes (dark/light tokens)
│   │   ├── app_theme.dart               ← MODIFY: lightTheme + Plus Jakarta Sans
│   │   └── custom_colors_extension.dart ← MODIFY: adicionar .light static
│   └── widgets/
│       └── app_dialog.dart              ← NOVO: shell reutilizável animado
├── di/
│   └── app_providers.dart               ← MODIFY: ThemeProvider como primeiro provider
├── main.dart                            ← MODIFY: Consumer<ThemeProvider> + themeMode
└── widgets/
    ├── side_nav.dart                    ← MODIFY: toggle no footer + fixes
    └── aisend_drawer.dart               ← MODIFY: toggle no footer + fixes
```

---

## ThemeProvider

```dart
// lib/core/providers/theme_provider.dart
class ThemeProvider extends ChangeNotifier {
  static const _key = 'theme_mode';
  ThemeMode _mode = ThemeMode.system;

  ThemeMode get mode => _mode;

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString(_key);
    if (saved == 'dark') _mode = ThemeMode.dark;
    else if (saved == 'light') _mode = ThemeMode.light;
    else _mode = ThemeMode.system;
    notifyListeners();
  }

  Future<void> setMode(ThemeMode mode) async {
    _mode = mode;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, mode.name);
  }

  void toggleDarkLight() {
    final isDark = _mode == ThemeMode.dark ||
        (_mode == ThemeMode.system &&
            WidgetsBinding.instance.platformDispatcher.platformBrightness == Brightness.dark);
    setMode(isDark ? ThemeMode.light : ThemeMode.dark);
  }
}
```

**Init strategy:** `create: (_) => ThemeProvider()..init()` em `app_providers.dart`. O `init()` é async mas o widget tree já renderiza com `ThemeMode.system` (default). Quando o `SharedPreferences` resolve, `notifyListeners()` aciona um rebuild — imperceptível visualmente se o sistema e o saved mode forem iguais.

---

## AppColors — Estrutura de Dois Conjuntos

```dart
// Estrutura atual: uma classe plana
abstract final class AppColors { ... }

// Nova estrutura: dois conjuntos de tokens
abstract final class AppColorsDark { ... }   // tokens dark
abstract final class AppColorsLight { ... }  // tokens light

// AppColors mantido como alias de AppColorsDark para não quebrar
// referências existentes em AppCustomColors
abstract final class AppColors = AppColorsDark;
```

**Gradientes:** Cada conjunto tem seus próprios `primaryGradient`, `logoGradient`, `surfaceGradient` usando os tokens locais.

---

## AppTheme — lightTheme

```dart
abstract final class AppTheme {
  static ThemeData get darkTheme { ... }  // existente, atualizado
  static ThemeData get lightTheme { ... } // NOVO
}
```

**lightTheme** espelha `darkTheme` estruturalmente, usando `AppColorsLight` e `Brightness.light`.

**Fonte:** `GoogleFonts.plusJakartaSansTextTheme` em ambos os temas.

---

## AppCustomColors — Variante Light

```dart
static const light = AppCustomColors(
  statusHot: AppColorsLight.statusHot,
  // ... (mesmos valores de status/feedback — inalterados)
  primaryGradient: AppColorsLight.primaryGradient,
  logoGradient: AppColorsLight.logoGradient,
  surfaceGradient: AppColorsLight.surfaceGradient,
);
```

`darkTheme` usa `extensions: [AppCustomColors.dark]`  
`lightTheme` usa `extensions: [AppCustomColors.light]`

---

## AppDialog — Implementação

```dart
// lib/core/widgets/app_dialog.dart
class AppDialog extends StatelessWidget {
  final String title;
  final IconData? icon;
  final Widget content;
  final List<Widget> actions;
  final double width;
  final VoidCallback? onClose;

  // showDialog helper estático:
  static Future<T?> show<T>(BuildContext context, {
    required String title,
    IconData? icon,
    required Widget content,
    required List<Widget> actions,
    double width = 480,
    VoidCallback? onClose,
  }) => showGeneralDialog<T>(
    context: context,
    barrierDismissible: true,
    barrierLabel: title,
    barrierColor: Colors.black54,
    transitionDuration: const Duration(milliseconds: 180),
    transitionBuilder: (_, animation, __, child) {
      // Guard reduced-motion
      if (MediaQuery.disableAnimationsOf(context)) return child;
      return ScaleTransition(
        scale: Tween(begin: 0.92, end: 1.0)
            .animate(CurvedAnimation(parent: animation, curve: Curves.easeOutCubic)),
        child: FadeTransition(opacity: animation, child: child),
      );
    },
    pageBuilder: (ctx, _, __) => AppDialog(
      title: title, icon: icon, content: content,
      actions: actions, width: width, onClose: onClose,
    ),
  );
}
```

**Dialog shell:** `Dialog` (não `AlertDialog`) com decoração manual para controle total do visual. Padding interno: `24px`. Header: `Row` com ícone opcional + título + `×`. Divider após header. Content em `SingleChildScrollView`. Divider antes de actions. Actions em `Row` com `MainAxisAlignment.end`.

---

## Migração de Dialogs Existentes

Cada dialog existente mantém toda a lógica de estado (`StatefulWidget`, controllers, validações). O que muda é apenas o widget raiz retornado em `build()`:

```dart
// Antes
return AlertDialog(title: ..., content: ..., actions: [...]);

// Depois
return AppDialog(title: ..., icon: ..., content: ..., actions: [...]);
```

`showDialog(context: context, builder: (_) => ChangeNotifierProvider.value(...))` → mantido. Apenas o widget interno muda.

---

## Decisões de Arquitetura

| Decisão | Escolha | Motivo |
|---|---|---|
| Estrutura de cores | Dois conjuntos separados (`AppColorsDark` / `AppColorsLight`) | Evita condicionais espalhados; cada tema compila seus tokens staticamente |
| Alias `AppColors` | `AppColors = AppColorsDark` | Zero quebras em referencias existentes |
| ThemeProvider init | `..init()` síncrono + async resolve | UI não bloqueia; rebuild imperceptível |
| Dialog base | `Dialog` em vez de `AlertDialog` | Controle total de padding, dividers e animação |
| Animação | `showGeneralDialog` com `transitionBuilder` | `AlertDialog` via `showDialog` não expõe transição customizável |
| Reduced motion | `MediaQuery.disableAnimationsOf(context)` | API oficial Flutter para `prefers-reduced-motion` |
| `GestureDetector` → `InkWell` | `InkWell` com `borderRadius` | Acessibilidade via teclado + ripple effect nativo |
| Erros em SnackBar | `context.customColors.error` em vez de `Colors.red` | Respeita o tema ativo (dark/light) |

---

## Convenções de Código

- Sem comentários exceto WHY não óbvio
- Sem `const` quando valores dependem de tema (runtime)
- `withValues(alpha: x)` em vez de `withOpacity(x)` (padrão atual do projeto)
- Widgets privados (`_NomeWidget`) para sub-componentes de um arquivo
- `context.colorScheme.*` e `context.customColors.*` via `context_extension.dart`
