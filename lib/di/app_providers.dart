import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import '../data/services/api_client.dart';
import '../data/services/leads_service.dart';
import '../data/services/broadcast_service.dart';
import '../data/services/consultants_service.dart';
import '../data/services/follow_up_rules_service.dart';
import '../data/services/schedule_service.dart';
import '../view_models/dashboard_view_model.dart';
import '../view_models/follow_up_view_model.dart';
import '../view_models/broadcast_view_model.dart';
import '../view_models/leads_view_model.dart';
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
    Provider<FollowUpRulesService>(
      create: (ctx) => FollowUpRulesService(ctx.read<ApiClient>()),
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
        followUpRulesService: ctx.read<FollowUpRulesService>(),
      ),
    ),
    ChangeNotifierProvider<ScheduleViewModel>(
      create: (ctx) => ScheduleViewModel(service: ctx.read<ScheduleService>()),
    ),
    ChangeNotifierProvider<FollowUpViewModel>(
      create: (ctx) => FollowUpViewModel(
        consultantsService: ctx.read<ConsultantsService>(),
        rulesService: ctx.read<FollowUpRulesService>(),
      ),
    ),
    ChangeNotifierProvider<LeadsViewModel>(
      create: (ctx) => LeadsViewModel(
        leadsService: ctx.read<LeadsService>(),
        consultantsService: ctx.read<ConsultantsService>(),
      ),
    ),
  ];
}
