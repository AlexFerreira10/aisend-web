import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import '../data/services/api_client.dart';
import '../data/services/leads_service.dart';
import '../data/services/broadcast_service.dart';
import '../data/services/consultants_service.dart';
import '../data/services/schedule_service.dart';
import '../view_models/dashboard_view_model.dart';
import '../view_models/broadcast_view_model.dart';
import '../view_models/schedule_view_model.dart';

class AppProviders {
  static List<SingleChildWidget> providers = [
    Provider<ApiClient>(
      create: (_) => ApiClient(),
    ),
    Provider<LeadsService>(
      create: (ctx) => LeadsService(ctx.read<ApiClient>()),
    ),
    Provider<BroadcastService>(
      create: (ctx) => BroadcastService(ctx.read<ApiClient>()),
    ),
    Provider<ConsultantsService>(
      create: (ctx) => ConsultantsService(ctx.read<ApiClient>()),
    ),
    Provider<ScheduleService>(
      create: (ctx) => ScheduleService(ctx.read<ApiClient>()),
    ),
    ChangeNotifierProvider<DashboardViewModel>(
      create: (ctx) => DashboardViewModel(
        leadsService: ctx.read<LeadsService>(),
        consultantsService: ctx.read<ConsultantsService>(),
      ),
    ),
    ChangeNotifierProvider<BroadcastViewModel>(
      create: (ctx) => BroadcastViewModel(
        leadsService: ctx.read<LeadsService>(),
        broadcastService: ctx.read<BroadcastService>(),
        consultantsService: ctx.read<ConsultantsService>(),
        scheduleService: ctx.read<ScheduleService>(),
      ),
    ),
    ChangeNotifierProvider<ScheduleViewModel>(
      create: (ctx) => ScheduleViewModel(service: ctx.read<ScheduleService>()),
    ),
  ];
}
