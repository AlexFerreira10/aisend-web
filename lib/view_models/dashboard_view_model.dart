import 'package:flutter/foundation.dart';
import '../data/sources/mock_data_source.dart';
import '../models/lead_model.dart';

class DashboardViewModel extends ChangeNotifier {
  // ─── Filter State ────────────────────────────────────────────────────────────
  String _selectedInstanceId = 'all';
  String _selectedPeriod = '7';

  String get selectedInstanceId => _selectedInstanceId;
  String get selectedPeriod => _selectedPeriod;

  void selectInstance(String id) {
    _selectedInstanceId = id;
    notifyListeners();
  }

  void selectPeriod(String days) {
    _selectedPeriod = days;
    notifyListeners();
  }

  // ─── KPIs ────────────────────────────────────────────────────────────────────
  int get totalLeads => MockDataSource.totalLeads;
  double get responseRate => MockDataSource.responseRate;
  int get hotLeadsCount => MockDataSource.hotLeadsCount;

  // ─── Leads ───────────────────────────────────────────────────────────────────
  List<LeadModel> get leads => MockDataSource.recentLeads;

  // ─── Instances (for filter dropdown) ─────────────────────────────────────────
  List<({String id, String label})> get instanceFilters => [
        (id: 'all', label: 'Todas as Instâncias'),
        ...MockDataSource.instances.map((i) => (id: i.id, label: i.label)),
      ];

  List<String> get periodFilters => ['7', '15', '30'];

  String periodLabel(String days) => 'Últimos $days dias';
}
