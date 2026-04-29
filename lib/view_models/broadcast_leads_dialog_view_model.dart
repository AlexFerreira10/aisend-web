import 'dart:async';
import 'package:flutter/foundation.dart';
import '../data/services/leads_service.dart';
import '../data/services/consultants_service.dart';
import '../models/lead_model.dart';
import '../models/instance_model.dart';
import '../models/enums/lead_status_enum.dart';

class BroadcastLeadsDialogViewModel extends ChangeNotifier {
  final LeadsService _leadsService;
  final ConsultantsService _consultantsService;

  String _search = '';
  LeadStatusEnum? _statusFilter;
  String? _consultantFilter;
  int _page = 1;
  int _total = 0;
  static const int _kPageSize = 20;
  List<LeadModel> _leads = [];
  List<InstanceModel> _instances = [];
  // Cross-page selection: IDs + snapshots para reconstituir a lista final
  final Set<String> _selectedIds = {};
  final Map<String, LeadModel> _selectedLeadsMap = {};
  bool _isLoading = false;
  String? _error;
  Timer? _searchDebounce;

  BroadcastLeadsDialogViewModel({
    required LeadsService leadsService,
    required ConsultantsService consultantsService,
  })  : _leadsService = leadsService,
        _consultantsService = consultantsService;

  List<LeadModel> get leads => _leads;
  List<InstanceModel> get instances => _instances;
  int get page => _page;
  int get totalPages => (_total / _kPageSize).ceil().clamp(1, 9999);
  bool get isLoading => _isLoading;
  String? get error => _error;
  int get selectedCount => _selectedIds.length;
  List<LeadModel> get selectedLeads => _selectedLeadsMap.values.toList();
  String? get consultantFilter => _consultantFilter;
  LeadStatusEnum? get statusFilter => _statusFilter;

  bool isSelected(String id) => _selectedIds.contains(id);

  bool get isAllPageSelected =>
      _leads.isNotEmpty && _leads.every((l) => _selectedIds.contains(l.id));

  Future<void> init() async {
    await Future.wait([_loadInstances(), loadLeads()]);
  }

  Future<void> _loadInstances() async {
    try {
      _instances = await _consultantsService.fetchInstances();
      notifyListeners();
    } catch (_) {}
  }

  Future<void> loadLeads() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final response = await _leadsService.fetchLeads(
        search: _search.isEmpty ? null : _search,
        classification: _classificationParam,
        consultantId: _consultantFilter,
        page: _page,
        pageSize: _kPageSize,
      );
      _leads = response.items;
      _total = response.total;
    } catch (e) {
      _error = 'Erro ao carregar leads. Tente novamente.';
      debugPrint('[BroadcastLeadsDialogVM] $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void setSearch(String query) {
    _search = query;
    _page = 1;
    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 400), loadLeads);
  }

  void setStatusFilter(LeadStatusEnum? status) {
    _statusFilter = status;
    _page = 1;
    loadLeads();
  }

  void setConsultantFilter(String? consultantId) {
    _consultantFilter = consultantId;
    _page = 1;
    loadLeads();
  }

  void setPage(int p) {
    _page = p;
    loadLeads();
  }

  void toggleLead(LeadModel lead) {
    if (_selectedIds.contains(lead.id)) {
      _selectedIds.remove(lead.id);
      _selectedLeadsMap.remove(lead.id);
    } else {
      _selectedIds.add(lead.id);
      _selectedLeadsMap[lead.id] = lead;
    }
    notifyListeners();
  }

  void toggleAllOnPage() {
    if (isAllPageSelected) {
      for (final lead in _leads) {
        _selectedIds.remove(lead.id);
        _selectedLeadsMap.remove(lead.id);
      }
    } else {
      for (final lead in _leads) {
        _selectedIds.add(lead.id);
        _selectedLeadsMap[lead.id] = lead;
      }
    }
    notifyListeners();
  }

  // activeClient → 'active_client' para compatibilidade com a API
  String? get _classificationParam => switch (_statusFilter) {
    null => null,
    LeadStatusEnum.activeClient => 'active_client',
    _ => _statusFilter!.name,
  };

  @override
  void dispose() {
    _searchDebounce?.cancel();
    super.dispose();
  }
}
