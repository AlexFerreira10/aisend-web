# Tasks: UI Design System — AiSend

**Feature ID:** ui-design-system  
**Status:** ✅ Complete  
**Created:** 2026-04-29  
**Completed:** 2026-04-29

---

## Legend

- `[P]` — Paralela (pode rodar simultaneamente com outras `[P]` do mesmo grupo)
- `[S]` — Sequencial (depende de tasks anteriores)
- Status: `⬜ Pending` | `🔄 In Progress` | `✅ Done` | `❌ Blocked`

---

## Grupo 1 — Fundação (Paralelas)

### T1 — Adicionar shared_preferences ao pubspec.yaml `[P]`
**Status:** ✅ Done  
**Arquivo:** `pubspec.yaml`  
**O que fazer:** Adicionar `shared_preferences: ^2.3.3` em `dependencies`, após `desktop_drop`.  
**Done when:** `flutter pub get` resolve sem erros.  
**Impacto:** Nenhum — arquivo de config apenas.

---

### T2 — Refatorar app_colors.dart — Nova Paleta Blue Corporate `[P]`
**Status:** ✅ Done  
**Arquivo:** `lib/core/theme/app_colors.dart`  
**O que fazer:**
1. Renomear a classe atual `AppColors` para `AppColorsDark`
2. Criar classe `AppColorsLight` com todos os tokens light (ver spec R01)
3. Criar alias `typedef AppColors = AppColorsDark` para não quebrar referencias
4. Substituir todos os valores de cor pelos tokens Blue Corporate (dark)
5. Manter `statusHot/Warm/Cold`, `success/error/warning` e seus `*Bg` inalterados
6. Atualizar gradientes com as novas cores

**Done when:** Arquivo compila sem erros; `AppColors.primary` é `#3B82F6`.  
**Impacto:** Quebrará `custom_colors_extension.dart` até T3 ser feita.

---

### T3 — Criar ThemeProvider `[P]`
**Status:** ✅ Done  
**Arquivo:** `lib/core/providers/theme_provider.dart` (novo)  
**O que fazer:** Implementar `ThemeProvider` conforme design.md — `ChangeNotifier`, `SharedPreferences`, `toggleDarkLight()`, `init()`.  
**Done when:** Arquivo criado e compila isoladamente.  
**Impacto:** Nenhum até T5 (wiring).

---

## Grupo 2 — Tema Completo (Sequencial após Grupo 1)

### T4 — Atualizar custom_colors_extension.dart `[S após T2]`
**Status:** ✅ Done  
**Arquivo:** `lib/core/theme/custom_colors_extension.dart`  
**O que fazer:**
1. Atualizar `AppCustomColors.dark` para referenciar `AppColorsDark.*`
2. Adicionar `static const light = AppCustomColors(...)` usando `AppColorsLight.*`
3. Status/feedback em `light` usam os mesmos valores que `dark`

**Done when:** Ambas as instâncias (`dark` e `light`) existem e compilam.

---

### T5 — Atualizar app_theme.dart — lightTheme + Plus Jakarta Sans `[S após T2, T4]`
**Status:** ✅ Done  
**Arquivo:** `lib/core/theme/app_theme.dart`  
**O que fazer:**
1. Substituir `GoogleFonts.interTextTheme` por `GoogleFonts.plusJakartaSansTextTheme` em `darkTheme`
2. Atualizar `darkTheme`: paleta dark tokens + `extensions: [AppCustomColors.dark]`
3. Criar `static ThemeData get lightTheme` espelhando a estrutura de `darkTheme` com paleta light tokens + `Brightness.light` + `extensions: [AppCustomColors.light]`

**Done when:** Ambos `darkTheme` e `lightTheme` existem; `flutter analyze` sem erros.

---

### T6 — Wiring: app_providers.dart + main.dart `[S após T3, T5]`
**Status:** ✅ Done  
**Arquivos:** `lib/di/app_providers.dart`, `lib/main.dart`  
**O que fazer:**

`app_providers.dart`:
- Adicionar import de `ThemeProvider`
- Inserir como primeiro item da lista: `ChangeNotifierProvider<ThemeProvider>(create: (_) => ThemeProvider()..init())`

`main.dart`:
- Adicionar import de `ThemeProvider` e `AppTheme.lightTheme`
- Envolver `MaterialApp` em `Consumer<ThemeProvider>`
- Adicionar `theme: AppTheme.lightTheme`, `darkTheme: AppTheme.darkTheme`, `themeMode: themeProvider.mode`

**Done when:** App inicia sem erros; tema segue o sistema.

---

### T7 — Toggle de Tema no SideNav e Drawer `[S após T6]`
**Status:** ✅ Done  
**Arquivos:** `lib/widgets/side_nav.dart`, `lib/widgets/aisend_drawer.dart`  
**O que fazer:**

`side_nav.dart` — `_SideNavFooter`:
- Importar `ThemeProvider` e `Provider`
- Adicionar `Row` com versão existente (`v1.1.0`) + `Spacer()` + `IconButton` de toggle
- `IconButton`: `tooltip: 'Alternar tema'`, ícone baseado em `themeProvider.mode`
- Enquanto T7.2 (GestureDetector) não está nesta task: só footer

`side_nav.dart` — `_SideNavItem` (fix acessibilidade R07.1):
- Substituir `GestureDetector` por `InkWell` com `borderRadius: AppDimensions.radiusMedium`
- Adicionar `Semantics(label: label, button: true)` envolvendo o `InkWell`
- Guard reduced-motion: `final reduce = MediaQuery.disableAnimationsOf(context)` antes do build; se `reduce`, retorna `Container` estático em vez de `AnimatedContainer`
- Adicionar `overflow: TextOverflow.ellipsis` no `Text(label)`

`aisend_drawer.dart` — `_DrawerFooter`:
- Mesma lógica de toggle que SideNav

`aisend_drawer.dart` — `_DrawerItem` (fix acessibilidade R07.1):
- Substituir `GestureDetector` por `InkWell` (se aplicável)
- Adicionar `overflow: TextOverflow.ellipsis` no `Text(label)` (R07.3)

**Done when:** Toggle visível no footer; clicar muda o tema instantaneamente.

---

## Grupo 3 — AppDialog + Dialogs (Sequencial após T5)

### T8 — Criar AppDialog Component `[S após T5]`
**Status:** ✅ Done  
**Arquivo:** `lib/core/widgets/app_dialog.dart` (novo)  
**O que fazer:** Implementar `AppDialog` conforme design.md — `Dialog` base, header com ícone/título/×, dividers, `showGeneralDialog` helper, guard reduced-motion.  
**Done when:** Arquivo criado e compila; `flutter analyze` sem warnings.

---

### T9 — Refatorar lead_form_dialog.dart `[S após T8]`
**Status:** ✅ Done  
**Arquivo:** `lib/views/leads/widgets/lead_form_dialog.dart`  
**O que fazer:**
1. Substituir `AlertDialog` por `AppDialog` com `icon: Icons.person_add_rounded`
2. Fix R07.5: `SnackBar(backgroundColor: Colors.red)` → `backgroundColor: context.customColors.error`

**Done when:** Dialog abre com visual AppDialog; erro usa cor do tema.

---

### T10 — Refatorar send_message_dialog.dart `[S após T8]`
**Status:** ✅ Done  
**Arquivo:** `lib/views/leads/widgets/send_message_dialog.dart`  
**O que fazer:**
1. Substituir `AlertDialog` por `AppDialog` com `icon: Icons.send_rounded`
2. Fix R07.1: `_Chip` — `GestureDetector` → `InkWell`
3. Fix R07.5: todos os 3 `SnackBar` hardcoded → `customColors.error/warning`
4. Fix R07.6: data via `DateFormat('dd/MM/yyyy HH:mm', 'pt_BR').format(_scheduledAt!)`
5. Fix R07.7: `TextFormField` mensagem fixa → adicionar `labelText: 'Mensagem'`

**Nota:** `intl` já está disponível via `google_fonts` (dependência transitiva). Se não compilar, verificar se precisa ser adicionado explicitamente ao `pubspec.yaml`.

**Done when:** Dialog abre com visual AppDialog; data formatada; erros no tema.

---

### T11 — Refatorar broadcast_leads_dialog.dart `[S após T8]`
**Status:** ✅ Done  
**Arquivo:** `lib/views/broadcast/widgets/broadcast_leads_dialog.dart`  
**O que fazer:**
1. Substituir `AlertDialog` por `AppDialog` com `icon: Icons.manage_search_rounded`
2. Fix R07.1: `_StatusChip` — `GestureDetector` → `InkWell`
3. Fix R07.3: `Text(lead.name)` → adicionar `overflow: TextOverflow.ellipsis`

**Done when:** Dialog abre com visual AppDialog; chips acessíveis.

---

### T12 — Fixes em aisend_app_bar.dart e dashboard_view.dart `[S após T5]`
**Status:** ✅ Done  
**Arquivos:** `lib/widgets/aisend_app_bar.dart`, `lib/views/dashboard/dashboard_view.dart`  
**O que fazer:**

`aisend_app_bar.dart`:
- Fix R07.1: `_NavButton` — `GestureDetector` → `InkWell`
- Fix R07.2: `IconButton` menu hambúrguer → `tooltip: 'Abrir menu'`
- Fix R07.4: `AnimatedContainer` em `_NavButton` → guard reduced-motion

`dashboard_view.dart`:
- Fix R07.1: `_Chip`, `_GradientButton`, `_CaptureLinkChip` — `GestureDetector` → `InkWell`
- Fix R07.2: `IconButton` paginação → `tooltip` descritivo
- Fix R07.4: `AnimatedContainer` em `_Chip` → guard reduced-motion

**Done when:** `flutter analyze` sem warnings de acessibilidade; `_NavButton` focusável via Tab.

---

## Grupo 4 — Confirmações Inline (Opcional, após T8)

### T13 — Refatorar confirmações inline em follow_up_view e schedule_view `[S após T8]`
**Status:** ✅ Done  
**Arquivos:** `lib/views/follow_up/follow_up_view.dart`, `lib/views/schedule/schedule_view.dart`  
**O que fazer:** Identificar `showDialog` inline que usam `AlertDialog` e migrar para `AppDialog.show()`.  
**Done when:** Confirmações inline usam `AppDialog`; visual consistente.

---

## Ordem de Execução

```
Grupo 1 (Paralelas):  T1 ─────────────────────────────────────────────────────►
                      T2 ─────►  T4 ─► T5 ─► T6 ─► T7
                      T3 ──────────────────────►
                                         T5 ─► T8 ─► T9, T10, T11
                                         T5 ─► T12
                                         T8 ─► T13
```

**Paralelas seguras:** T1 + T2 + T3 (Grupo 1)  
**T9 + T10 + T11 + T12** podem rodar em paralelo após T8 e T5 respectivamente  

---

## Verificação Final

1. `flutter pub get` — `shared_preferences` resolvido
2. `flutter analyze` — sem erros ou warnings
3. Hot restart: tema segue preferência do sistema
4. Clicar toggle no sidebar: tema muda instantaneamente em toda a UI
5. Reabrir o app: tema persiste (SharedPreferences)
6. Abrir cada dialog: animação de entrada, ícone no header, largura correta
7. Testar em dark + light: cores adaptam via `colorScheme` e `customColors`
8. Navegar pelo sidebar com Tab: foco visível em todos os itens
