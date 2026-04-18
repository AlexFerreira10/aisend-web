import 'package:aisend/data/services/schemas/api_exception.dart';
import 'package:flutter/foundation.dart';
import '../data/services/consultants_service.dart';
import '../data/services/follow_up_rules_service.dart';
import '../models/follow_up_rule_model.dart';
import '../models/instance_model.dart';

class FollowUpViewModel extends ChangeNotifier {
  final ConsultantsService _consultantsService;
  final FollowUpRulesService _rulesService;

  FollowUpViewModel({
    required ConsultantsService consultantsService,
    required FollowUpRulesService rulesService,
  })  : _consultantsService = consultantsService,
        _rulesService = rulesService {
    _loadInstances();
  }

  // ─── Instances ───────────────────────────────────────────────────────────────
  List<InstanceModel> _instances = [];
  InstanceModel? _selectedInstance;

  List<InstanceModel> get instances => _instances;
  InstanceModel? get selectedInstance => _selectedInstance;

  Future<void> _loadInstances() async {
    try {
      _instances = await _consultantsService.fetchInstances();
      if (_instances.isNotEmpty) {
        _selectedInstance = _instances.first;
        await _loadRules();
      }
    } catch (_) {
      _hasError = true;
    }
    notifyListeners();
  }

  void selectInstance(InstanceModel instance) {
    _selectedInstance = instance;
    _rules = [];
    _hasError = false;
    notifyListeners();
    _loadRules();
  }

  // ─── Rules ───────────────────────────────────────────────────────────────────
  List<FollowUpRuleModel> _rules = [];
  bool _isLoading = false;
  bool _hasError = false;

  List<FollowUpRuleModel> get rules => _rules;
  bool get isLoading => _isLoading;
  bool get hasError => _hasError;

  String? get _consultantId => _selectedInstance?.consultantId;

  Future<void> _loadRules() async {
    final id = _consultantId;
    if (id == null) return;
    _isLoading = true;
    _hasError = false;
    notifyListeners();
    try {
      _rules = await _rulesService.fetchRules(id);
    } on ApiException {
      _hasError = true;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<FollowUpRuleModel?> createRule(FollowUpRuleModel rule) async {
    final id = _consultantId;
    if (id == null) return null;
    try {
      final created = await _rulesService.createRule(id, rule);
      _rules = [..._rules, created];
      notifyListeners();
      return created;
    } on ApiException {
      return null;
    }
  }

  Future<bool> updateRule(FollowUpRuleModel rule) async {
    try {
      final updated = await _rulesService.updateRule(rule);
      _rules = _rules.map((r) => r.id == updated.id ? updated : r).toList();
      notifyListeners();
      return true;
    } on ApiException {
      return false;
    }
  }

  Future<void> toggleRule(String id) async {
    try {
      await _rulesService.toggleRule(id);
      _rules = _rules
          .map((r) => r.id == id ? r.withEnabled(!r.isEnabled) : r)
          .toList();
      notifyListeners();
    } on ApiException {
      // silently ignore — UI stays as-is
    }
  }

  Future<void> deleteRule(String id) async {
    try {
      await _rulesService.deleteRule(id);
      _rules = _rules.where((r) => r.id != id).toList();
      notifyListeners();
    } on ApiException {
      // silently ignore
    }
  }
}
