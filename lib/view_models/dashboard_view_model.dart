import 'dart:async';
import 'package:aisend/data/services/schemas/api_exception.dart';
import 'package:flutter/foundation.dart';
import '../data/services/leads_service.dart';
import '../data/services/consultants_service.dart';
import '../models/lead_model.dart';
import '../models/enums/lead_status_enum.dart';

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

  // ─── KPI Filter State ────────────────────────────────────────────────────────
  String? _selectedInstanceId;
  String _selectedPeriod = '7';

  String? get selectedInstanceId => _selectedInstanceId;
  String get selectedPeriod => _selectedPeriod;

  List<({String? id, String label})> _instanceFilters = [
    (id: null, label: 'Todas as Instâncias'),
  ];
  List<({String? id, String label})> get instanceFilters => _instanceFilters;
  List<String> get periodFilters => ['7', '15', '30'];
  String periodLabel(String days) => 'Últimos $days dias';

  // ─── KPI Loading / Error ─────────────────────────────────────────────────────
  bool _isLoading = false;
  bool _hasError = false;
  String _errorMessage = '';

  bool get isLoading => _isLoading;
  bool get hasError => _hasError;
  String get errorMessage => _errorMessage;

  // ─── KPI Data ────────────────────────────────────────────────────────────────
  int _totalLeads = 0;
  double _responseRate = 0.0;
  int _hotLeadsCount = 0;

  int get totalLeads => _totalLeads;
  double get responseRate => _responseRate;
  int get hotLeadsCount => _hotLeadsCount;

  // ─── Activity Filters ─────────────────────────────────────────────────────────
  static const int _kActivityPageSize = 6;

  String? _activityClassification;
  bool? _activityWaitingHuman;
  String _activitySearch = '';
  int _activityPage = 1;
  Timer? _searchDebounce;

  String? get activityClassification => _activityClassification;
  bool? get activityWaitingHuman => _activityWaitingHuman;
  String get activitySearch => _activitySearch;
  int get activityPage => _activityPage;

  // ─── Activity Data ────────────────────────────────────────────────────────────
  List<LeadModel> _activityLeads = [];
  int _activityTotal = 0;
  bool _activityLoading = false;

  List<LeadModel> get activityLeads => _activityLeads;
  int get activityTotal => _activityTotal;
  bool get activityLoading => _activityLoading;
  int get activityTotalPages =>
      (_activityTotal / _kActivityPageSize).ceil().clamp(1, 9999);

  // ─── KPI Actions ─────────────────────────────────────────────────────────────

  void selectInstance(String? id) {
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
      final leadsResponse = await _leadsService.fetchLeads(
        instanceName: _selectedInstanceId,
        pageSize: 200,
      );
      final allLeads = leadsResponse.items;
      _totalLeads = leadsResponse.total;
      _responseRate = allLeads.isEmpty
          ? 0.0
          : allLeads.where((l) => l.lastInteractionAt != null).length /
              allLeads.length;
      _hotLeadsCount =
          allLeads.where((l) => l.aiClassification == LeadStatusEnum.hot).length;

      await _loadActivity();
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

  // ─── Activity Actions ─────────────────────────────────────────────────────────

  void setActivityClassification(String? classification,
      {bool? waitingHuman}) {
    _activityClassification = classification;
    _activityWaitingHuman = waitingHuman;
    _activityPage = 1;
    _loadActivity();
  }

  void setActivitySearch(String query) {
    _activitySearch = query;
    _activityPage = 1;
    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 400), _loadActivity);
  }

  void setActivityPage(int page) {
    _activityPage = page;
    _loadActivity();
  }

  Future<void> _loadActivity() async {
    _activityLoading = true;
    notifyListeners();

    try {
      final response = await _leadsService.fetchLeads(
        instanceName: _selectedInstanceId,
        classification: _activityClassification,
        waitingHuman: _activityWaitingHuman,
        search: _activitySearch.isEmpty ? null : _activitySearch,
        page: _activityPage,
        pageSize: _kActivityPageSize,
      );
      _activityLeads = response.items;
      _activityTotal = response.total;
    } catch (_) {
      // Silently keep previous list on activity errors
    } finally {
      _activityLoading = false;
      notifyListeners();
    }
  }

  Future<void> _loadInstances() async {
    try {
      final instances = await _consultantsService.fetchInstances();
      _instanceFilters = [
        (id: null, label: 'Todas as Instâncias'),
        ...instances.map((i) => (id: i.id as String?, label: i.label)),
      ];
      notifyListeners();
    } catch (_) {
      // Silently fail — filter stays as "Todas as Instâncias"
    }
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    super.dispose();
  }
}
