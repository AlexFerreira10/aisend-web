# Spec: UI Design System — AiSend

**Feature ID:** ui-design-system  
**Scope:** Large  
**Status:** In Progress  
**Created:** 2026-04-29

---

## Context

AiSend é um SaaS B2B para consultores farmacêuticos. A UI atual usa paleta ametista/cyan (#6B4FA3 + #06B6D4), fonte Inter e dialogs vanilla do Flutter. O resultado é genérico. O objetivo é elevar para um design system enterprise-grade.

**Scope:** UI apenas — sem alterações em ViewModels, serviços ou lógica de negócio.

---

## Requirements

### R01 — Paleta de Cores: Azul Corporativo
Substituir a paleta ametista/cyan por tokens azul corporativo com suporte a dark e light mode.

**Dark mode tokens:**
- `background`: `#0D1117`
- `surface`: `#161B22`
- `card`: `#21262D`
- `cardHover`: `#2D333B`
- `border`: `#30363D`
- `primary`: `#3B82F6` (Blue-500)
- `primaryDark`: `#1D4ED8` (Blue-700)
- `primaryLight`: `#93C5FD` (Blue-300)
- `primaryGlow`: `#333B82F6`
- `accent`: `#10B981` (Emerald-500)
- `accentGlow`: `#2210B981`
- `textPrimary`: `#F0F6FC`
- `textSecondary`: `#8B949E`
- `textMuted`: `#484F58`

**Light mode tokens:**
- `background`: `#F8FAFC` (Slate-50)
- `surface`: `#FFFFFF`
- `card`: `#F1F5F9` (Slate-100)
- `cardHover`: `#E2E8F0` (Slate-200)
- `border`: `#E2E8F0`
- `primary`: `#1E40AF` (Blue-800)
- `primaryDark`: `#1E3A8A` (Blue-900)
- `primaryLight`: `#3B82F6` (Blue-500)
- `primaryGlow`: `#331E40AF`
- `accent`: `#059669` (Emerald-600)
- `accentGlow`: `#22059669`
- `textPrimary`: `#0F172A` (Slate-900)
- `textSecondary`: `#64748B` (Slate-500)
- `textMuted`: `#94A3B8` (Slate-400)

**Status de leads** (inalterados — funcionam em ambos os temas):
- `statusHot`: `#F97316`, `statusHotBg`: `#1AF97316`
- `statusWarm`: `#EAB308`, `statusWarmBg`: `#1AEAB308`
- `statusCold`: `#60A5FA`, `statusColdBg`: `#1A60A5FA`

**Feedback** (inalterados em dark; light usa mesmos valores):
- `success`: `#10B981`, `successBg`: `#1A10B981`
- `error`: `#EF4444`, `errorBg`: `#1AEF4444`
- `warning`: `#F59E0B`, `warningBg`: `#1AF59E0B`

---

### R02 — Tipografia: Plus Jakarta Sans
Substituir `GoogleFonts.interTextTheme` por `GoogleFonts.plusJakartaSansTextTheme` em ambos os temas. Hierarquia de tamanhos e pesos permanece idêntica à atual.

---

### R03 — Dark/Light Mode Completo
- `ThemeProvider` (`ChangeNotifier`) com `ThemeMode` (system | dark | light)
- Persistência via `SharedPreferences` (chave: `'theme_mode'`)
- Default: `ThemeMode.system`
- Detecção do sistema via `WidgetsBinding.instance.platformDispatcher.platformBrightness`
- `MaterialApp` consome `ThemeProvider` via `Consumer` com `theme`, `darkTheme` e `themeMode`
- `ThemeProvider` deve ser o primeiro provider na lista (antes de todos os outros)

---

### R04 — Toggle de Tema no Sidebar e Drawer
- Toggle no footer de `SideNav` e `AiSendDrawer`
- Exibe ícone: `Icons.light_mode_rounded` (modo escuro ativo) / `Icons.dark_mode_rounded` (modo claro ativo)
- `onPressed`: chama `ThemeProvider.toggleDarkLight()`
- Tooltip: `'Alternar tema'`
- Acessível via teclado (usa `IconButton`)

---

### R05 — AppDialog: Shell Reutilizável
Substituir todos os `AlertDialog` vanilla por um componente `AppDialog` padronizado.

**Anatomia:**
```
┌─────────────────────────────────────────────────┐
│  [ícone]  Título do Dialog              [×]     │  ← Header
│  ─────────────────────────────────────────────  │  ← Divider
│                                                  │
│   Content (Form, lista, confirmação...)          │  ← Content
│                                                  │
│  ─────────────────────────────────────────────  │  ← Divider
│                    [Cancelar]  [Ação Primária]   │  ← Actions
└─────────────────────────────────────────────────┘
```

**Especificações:**
- Entrada: `ScaleTransition` (0.92→1.0) + `FadeTransition` (0→1), 180ms, `Curves.easeOutCubic`
- Guard `prefers-reduced-motion`: verificar `MediaQuery.disableAnimationsOf(context)` e pular animação
- Background: `colorScheme.surface`
- Border: `1px colorScheme.outline`, `borderRadius: 16px`
- Header: ícone (opcional) em container 32x32 com `primary.withValues(alpha: 0.12)`, título bold, botão `×`
- Largura: configurável (default 480px para forms, 680px para seleção)
- `barrierColor`: `Colors.black54`

**Parâmetros da API:**
```dart
AppDialog({
  required Widget content,
  required String title,
  required List<Widget> actions,
  IconData? icon,
  double width = 480,
  VoidCallback? onClose,
})
```

---

### R06 — Refatorar Dialogs Existentes
Migrar os seguintes dialogs para usar `AppDialog`:
- `lead_form_dialog.dart`
- `send_message_dialog.dart`
- `broadcast_leads_dialog.dart`
- Confirmações inline em `follow_up_view.dart` e `schedule_view.dart`

---

### R07 — Acessibilidade e Qualidade (Web Interface Guidelines)
Corrigir 18 issues identificados na auditoria:

**R07.1 — GestureDetector → InkWell/Semantics**
Componentes que precisam de migração (não acessíveis via teclado):
- `side_nav.dart:157` — `_SideNavItem`
- `aisend_app_bar.dart:177` — `_NavButton`
- `dashboard_view.dart:497` — `_Chip`
- `dashboard_view.dart:582` — `_GradientButton`
- `dashboard_view.dart:647` — `_CaptureLinkChip`
- `broadcast_leads_dialog.dart:195` — `_StatusChip`
- `send_message_dialog.dart:378` — `_Chip`

**R07.2 — Tooltips Ausentes**
- `aisend_app_bar.dart:33` — `IconButton` menu hambúrguer
- `dashboard_view.dart:541` — `IconButton` paginação

**R07.3 — Overflow Protection**
- `side_nav.dart:189` — `Text(label)` sem `overflow: TextOverflow.ellipsis`
- `aisend_drawer.dart:168` — `Text(label)` sem `overflow: TextOverflow.ellipsis`
- `broadcast_leads_dialog.dart:334` — `Text(lead.name)` sem overflow

**R07.4 — Reduced Motion Guard**
- `side_nav.dart:159` — `AnimatedContainer` sem guard
- `aisend_app_bar.dart:183` — `AnimatedContainer` sem guard
- `dashboard_view.dart:499` — `AnimatedContainer` sem guard

**R07.5 — Erros Hardcoded**
- `lead_form_dialog.dart:84` — `SnackBar(backgroundColor: Colors.red)` → usar `customColors.error`
- `send_message_dialog.dart:73` — `SnackBar(backgroundColor: Colors.orange)` → usar `customColors.warning`
- `send_message_dialog.dart:120` — `SnackBar(backgroundColor: Colors.red)` → usar `customColors.error`

**R07.6 — Formatação de Data**
- `send_message_dialog.dart:271` — concatenação manual de data → usar `DateFormat('dd/MM/yyyy HH:mm')` do pacote `intl`

**R07.7 — Acessibilidade de Campos**
- `send_message_dialog.dart:213` — `TextFormField` com apenas `hintText`, sem `labelText` → adicionar `labelText`

---

## Out of Scope

- Alterações em ViewModels ou serviços
- Alterações em rotas ou lógica de negócio
- Novos features de produto
- Testes automatizados (projeto não tem testing setup)
