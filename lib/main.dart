import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'di/app_providers.dart';
import 'core/theme/app_theme.dart';
import 'models/lead_model.dart';
import 'views/dashboard/dashboard_view.dart';
import 'views/broadcast/broadcast_view.dart';
import 'views/lead_detail/lead_detail_view.dart';

void main() {
  runApp(const AiSendApp());
}

class AiSendApp extends StatelessWidget {
  const AiSendApp({super.key});

  @override
  Widget build(BuildContext context) => MultiProvider(
        providers: AppProviders.providers,
        child: MaterialApp(
          title: 'AiSend – Intelligent Broadcasts',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.darkTheme,
          initialRoute: '/',
          routes: {
            '/': (_) => const DashboardView(),
            '/broadcast': (_) => const BroadcastView(),
          },
          onGenerateRoute: (settings) {
            if (settings.name == '/lead_detail') {
              final lead = settings.arguments as LeadModel;
              return MaterialPageRoute(
                builder: (_) => LeadDetailView(lead: lead),
              );
            }
            return null;
          },
        ),
      );
}
