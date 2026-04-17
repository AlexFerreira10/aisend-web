import 'package:aisend/data/services/schemas/api_exception.dart';
// ...existing code...
import 'package:flutter/foundation.dart';
import '../data/services/leads_service.dart';
import '../data/services/consultants_service.dart';
import '../models/lead_model.dart';

class DashboardViewModel extends ChangeNotifier {
  final LeadsService _leadsService;
  final ConsultantsService _consultantsService;

  DashboardViewModel({
    required LeadsService leadsService,
    required ConsultantsService consultantsService,
  })  : _leadsService = leadsService,
        _consultantsService = consultantsService {
    _loadInstances();
    loadData();
  }

  // ─── Filter State ────────────────────────────────────────────────────────────
  String _selectedInstanceId = 'all';
  String _selectedPeriod = '7';

  String get selectedInstanceId => _selectedInstanceId;
  String get selectedPeriod => _selectedPeriod;

  List<({String id, String label})> _instanceFilters = [
    (id: 'all', label: 'Todas as Instâncias'),
  ];
  List<({String id, String label})> get instanceFilters => _instanceFilters;
  List<String> get periodFilters => ['7', '15', '30'];
  String periodLabel(String days) => 'Últimos $days dias';

  // ─── Loading / Error ─────────────────────────────────────────────────────────
  bool _isLoading = false;
  bool _hasError = false;
  String _errorMessage = '';

  bool get isLoading => _isLoading;
  bool get hasError => _hasError;
  String get errorMessage => _errorMessage;

  // ─── Data ────────────────────────────────────────────────────────────────────
  int _totalLeads = 0;
  double _responseRate = 0.0;
  int _hotLeadsCount = 0;
  List<LeadModel> _leads = [];

  int get totalLeads => _totalLeads;
  double get responseRate => _responseRate;
  int get hotLeadsCount => _hotLeadsCount;
  List<LeadModel> get leads => _leads;

  // ─── Actions ─────────────────────────────────────────────────────────────────

  void selectInstance(String id) {
    _selectedInstanceId = id;
    notifyListeners();
    loadData();
  }

  void selectPeriod(String days) {
    _selectedPeriod = days;
    notifyListeners();
    loadData();
  }

  Future<void> loadData() async {
    _isLoading = true;
    _hasError = false;
    notifyListeners();

    try {
      final instanceName = _selectedInstanceId == 'all' ? null : _selectedInstanceId;

      final leadsResponse = await _leadsService.fetchLeads(
        instanceName: instanceName,
        pageSize: 20,
      );
      _leads = leadsResponse.items;
      _totalLeads = leadsResponse.total;
      _responseRate = _leads.isEmpty ? 0.0 : _leads.where((l) => l.lastInteractionAt != null).length / _leads.length;
      _hotLeadsCount = _leads.where((l) => l.aiClassification == 'hot').length;
    } on ApiException catch (e) {
      _hasError = true;
      _errorMessage = e.isNetworkError
          ? 'Sem conexão com o servidor. Verifique se o backend está rodando.'
          : 'Erro ao carregar dados: ${e.message}';
    } catch (e) {
      _hasError = true;
      _errorMessage = 'Erro inesperado: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _loadInstances() async {
    try {
      final instances = await _consultantsService.fetchInstances();
      _instanceFilters = [
        (id: 'all', label: 'Todas as Instâncias'),
        ...instances.map((i) => (id: i.id, label: i.label)),
      ];
      notifyListeners();
    } catch (_) {
      // Silently fail — filter stays as "Todas as Instâncias"
    }
  }
}
