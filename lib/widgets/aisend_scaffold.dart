import 'package:aisend/core/theme/app_colors.dart';
import 'package:aisend/widgets/aisend_app_bar.dart';
import 'package:aisend/widgets/aisend_drawer.dart';
import 'package:aisend/widgets/side_nav.dart';
import 'package:flutter/material.dart';

class AiSendScaffold extends StatelessWidget {
  final String currentRoute;
  final Widget body;
  final Widget? floatingActionButton;

  const AiSendScaffold({
    super.key,
    required this.currentRoute,
    required this.body,
    this.floatingActionButton,
  });

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.sizeOf(context).width >= 1300;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (isDesktop) {
      final bg = isDark ? AppColorsDark.background : AppColorsLight.background;
      final surface = isDark ? AppColorsDark.surface : AppColorsLight.surface;
      return Container(
        color: bg,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            SideNav(currentRoute: currentRoute),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: Material(color: surface, child: body),
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Scaffold(
      backgroundColor: isDark
          ? AppColorsDark.background
          : AppColorsLight.background,
      appBar: AiSendAppBar(currentRoute: currentRoute),
      drawer: AiSendDrawer(currentRoute: currentRoute),
      floatingActionButton: floatingActionButton,
      body: body,
    );
  }
}
