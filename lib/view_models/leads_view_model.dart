import 'dart:async';
import 'package:flutter/foundation.dart';
import '../data/services/leads_service.dart';
import '../data/services/consultants_service.dart';
import '../models/lead_model.dart';
import '../models/instance_model.dart';

class LeadsViewModel extends ChangeNotifier {
  final LeadsService _leadsService;
  final ConsultantsService _consultantsService;

  LeadsViewModel({
    required LeadsService leadsService,
    required ConsultantsService consultantsService,
  })  : _leadsService = leadsService,
        _consultantsService = consultantsService {
    _loadInstances();
    loadLeads();
  }

  // ─── State ───────────────────────────────────────────────────────────────────

  List<LeadModel> _leads = [];
  List<InstanceModel> _instances = [];
  int _total = 0;
  int _page = 1;
  bool _isLoading = false;
  bool _isMutating = false;
  String _errorMessage = '';

  static const int _kPageSize = 20;

  List<LeadModel> get leads => _leads;
  List<InstanceModel> get instances => _instances;
  int get total => _total;
  int get page => _page;
  bool get isLoading => _isLoading;
  bool get isMutating => _isMutating;
  String get errorMessage => _errorMessage;
  int get totalPages => (_total / _kPageSize).ceil().clamp(1, 9999);

  // ─── Filters ─────────────────────────────────────────────────────────────────

  String? _selectedConsultantId;
  String? _selectedClassification;
  String _search = '';
  Timer? _searchDebounce;

  String? get selectedConsultantId => _selectedConsultantId;
  String? get selectedClassification => _selectedClassification;
  String get search => _search;

  void setConsultantFilter(String? consultantId) {
    _selectedConsultantId = consultantId;
    _page = 1;
    loadLeads();
  }

  void setClassificationFilter(String? classification) {
    _selectedClassification = classification;
    _page = 1;
    loadLeads();
  }

  void setSearch(String query) {
    _search = query;
    _page = 1;
    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 400), loadLeads);
  }

  void setPage(int p) {
    _page = p;
    loadLeads();
  }

  // ─── Load ─────────────────────────────────────────────────────────────────────

  Future<void> loadLeads() async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    try {
      final response = await _leadsService.fetchLeads(
        consultantId: _selectedConsultantId,
        classification: _selectedClassification,
        search: _search.isEmpty ? null : _search,
        page: _page,
        pageSize: _kPageSize,
      );
      _leads = response.items;
      _total = response.total;
    } catch (e) {
      _errorMessage = 'Erro ao carregar leads: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _loadInstances() async {
    try {
      _instances = await _consultantsService.fetchInstances();
      notifyListeners();
    } catch (_) {}
  }

  // ─── CRUD ─────────────────────────────────────────────────────────────────────

  Future<String?> createLead(Map<String, dynamic> dto) async {
    _isMutating = true;
    notifyListeners();
    try {
      await _leadsService.createLead(dto);
      await loadLeads();
      return null;
    } catch (e) {
      _isMutating = false;
      notifyListeners();
      return e.toString();
    }
  }

  Future<String?> updateLead(String id, Map<String, dynamic> dto) async {
    _isMutating = true;
    notifyListeners();
    try {
      await _leadsService.updateLead(id, dto);
      await loadLeads();
      return null;
    } catch (e) {
      _isMutating = false;
      notifyListeners();
      return e.toString();
    }
  }

  Future<String?> deleteLead(String id) async {
    _isMutating = true;
    notifyListeners();
    try {
      await _leadsService.deleteLead(id);
      await loadLeads();
      return null;
    } catch (e) {
      _isMutating = false;
      notifyListeners();
      return e.toString();
    }
  }

  Future<String?> sendMessage(String id, Map<String, dynamic> dto) async {
    try {
      await _leadsService.sendMessage(id, dto);
      return null;
    } catch (e) {
      return e.toString();
    }
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    super.dispose();
  }
}
