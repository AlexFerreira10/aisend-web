import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/theme/app_theme.dart';
import 'data/sources/n8n_api_source.dart';
import 'view_models/dashboard_view_model.dart';
import 'view_models/broadcast_view_model.dart';
import 'views/dashboard/dashboard_view.dart';
import 'views/broadcast/broadcast_view.dart';

void main() {
  runApp(const AiSendApp());
}

class AiSendApp extends StatelessWidget {
  const AiSendApp({super.key});

  @override
  Widget build(BuildContext context) => MultiProvider(
    providers: [
      ChangeNotifierProvider<DashboardViewModel>(create: (_) => DashboardViewModel()),
      ChangeNotifierProvider<BroadcastViewModel>(
        create: (_) => BroadcastViewModel(repository: N8nApiSource()),
      ),
    ],
    child: MaterialApp(
      title: 'AiSend – Intelligent Broadcasts',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      initialRoute: '/',
      routes: {
        '/': (_) => const DashboardView(),
        '/broadcast': (_) => const BroadcastView(),
      },
    ),
  );
}
