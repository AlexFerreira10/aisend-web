import 'package:aisend/core/theme/context_extension.dart';
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
    final isDesktop = MediaQuery.sizeOf(context).width >= 900;

    if (isDesktop) {
      return Container(
        color: context.colorScheme.surface,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            SideNav(currentRoute: currentRoute),
            Expanded(
              child: Material(color: Colors.transparent, child: body),
            ),
          ],
        ),
      );
    }

    return Scaffold(
      appBar: AiSendAppBar(currentRoute: currentRoute),
      drawer: AiSendDrawer(currentRoute: currentRoute),
      floatingActionButton: floatingActionButton,
      body: body,
    );
  }
}
