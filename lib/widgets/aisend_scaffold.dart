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

  static const _routeTitles = {
    '/': 'Central de Resultados',
    '/broadcast': 'Máquina de Disparos',
    '/schedule': 'Agendamentos',
    '/follow_up': 'Follow-up',
    '/leads': 'Gestão de Leads',
  };

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.sizeOf(context).width >= 900;

    if (isDesktop) {
      return Scaffold(
        body: MediaQuery.removePadding(
          context: context,
          removeTop: true,
          child: Row(
            children: <Widget>[
              SideNav(currentRoute: currentRoute),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    _ContentHeader(title: _routeTitles[currentRoute] ?? ''),
                    Expanded(child: body),
                  ],
                ),
              ),
            ],
          ),
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

class _ContentHeader extends StatelessWidget {
  final String title;
  const _ContentHeader({required this.title});

  @override
  Widget build(BuildContext context) => Container(
        height: 56,
        padding: const EdgeInsets.symmetric(horizontal: 32),
        decoration: BoxDecoration(
          color: context.colorScheme.surface,
          border: Border(
            bottom: BorderSide(color: context.theme.dividerColor, width: 1),
          ),
        ),
        alignment: Alignment.centerLeft,
        child: Text(title, style: context.textTheme.headlineSmall),
      );
}
