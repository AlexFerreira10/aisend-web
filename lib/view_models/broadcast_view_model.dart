import 'dart:convert';
import 'dart:async';
import 'dart:math';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import '../data/repositories/broadcast_repository.dart';
import '../data/sources/mock_data_source.dart';
import '../models/lead_model.dart';

class BroadcastViewModel extends ChangeNotifier {
  final BroadcastRepository _repository;

  BroadcastViewModel({required BroadcastRepository repository})
      : _repository = repository;

  // ─── Form State ──────────────────────────────────────────────────────────────
  InstanceModel? _selectedInstance;
  String _contactReason = '';
  String? _uploadedFileName;
  bool _leadsFromBase = false;
  List<LeadModel> _dynamicLeads = [];

  InstanceModel? get selectedInstance => _selectedInstance;
  String get contactReason => _contactReason;
  String? get uploadedFileName => _uploadedFileName;
  bool get leadsFromBase => _leadsFromBase;
  int get dynamicLeadsCount => _dynamicLeads.length;

  List<InstanceModel> get instances => MockDataSource.instances;

  void selectInstance(InstanceModel? instance) {
    _selectedInstance = instance;
    notifyListeners();
  }

  void setReason(String value) {
    _contactReason = value;
    notifyListeners();
  }

  Future<void> pickAndParseJson() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
        withData: true,
      );

      if (result != null && result.files.single.bytes != null) {
        final file = result.files.single;
        final content = utf8.decode(file.bytes!);
        final dynamic data = jsonDecode(content);

        if (data is List) {
          _dynamicLeads = data.map((item) {
            final map = item as Map<String, dynamic>;
            // Flexibility in field names
            final String name = map['nome'] ?? map['name'] ?? 'No Name';
            final String phone = map['numero'] ?? map['phone'] ?? map['telefone'] ?? '';
            
            return LeadModel(
              id: DateTime.now().millisecondsSinceEpoch.toString() + phone,
              name: name,
              phone: phone,
              lastMessage: 'Imported via JSON',
              status: LeadStatus.cold,
              time: 'Just now',
            );
          }).where((l) => l.phone.isNotEmpty).toList();

          _uploadedFileName = file.name;
          _leadsFromBase = false;
          notifyListeners();
        }
      }
    } catch (e) {
      debugPrint('[AiSend] Error importing JSON: $e');
    }
  }

  void pullLeadsFromBase() {
    _uploadedFileName = null;
    _leadsFromBase = true;
    notifyListeners();
  }

  void clearUpload() {
    _uploadedFileName = null;
    _leadsFromBase = false;
    notifyListeners();
  }

  // ─── Broadcast State ──────────────────────────────────────────────────────────
  bool _isBroadcasting = false;
  bool _isCompleted = false;
  double _progress = 0.0;
  int _sentCount = 0;
  int _repliedCount = 0;
  int _errorCount = 0;
  String _currentLeadName = '';

  Timer? _timer;
  final _random = Random();

  bool get isBroadcasting => _isBroadcasting;
  bool get isCompleted => _isCompleted;
  double get progress => _progress;
  int get sentCount => _sentCount;
  int get repliedCount => _repliedCount;
  int get errorCount => _errorCount;
  String get currentLeadName => _currentLeadName;

  bool get canBroadcast =>
      _selectedInstance != null &&
      _contactReason.trim().isNotEmpty &&
      (_uploadedFileName != null || _leadsFromBase) &&
      !_isBroadcasting;

  /// Starts the broadcast: iterates through all leads, calls n8n endpoint
  /// for each one, and updates progress with chaotic intervals.
  void startBroadcast(VoidCallback onComplete) {
    if (!canBroadcast) return;

    _isBroadcasting = true;
    _isCompleted = false;
    _progress = 0.0;
    _sentCount = 0;
    _repliedCount = 0;
    _errorCount = 0;
    notifyListeners();

    final leads = _leadsFromBase ? MockDataSource.leads : _dynamicLeads;
    final total = leads.length;
    
    if (total == 0) {
      _isBroadcasting = false;
      notifyListeners();
      return;
    }

    int index = 0;

    Future<void> sendNext() async {
      if (index >= total) {
        _isBroadcasting = false;
        _isCompleted = true;
        _progress = 1.0;
        _currentLeadName = '';
        notifyListeners();
        onComplete();
        return;
      }

      final lead = leads[index];
      _currentLeadName = lead.name;
      notifyListeners();

      // ── Chaotic delay (RN04) ──────────────────────────────────────────────
      final delayMs = 600 + _random.nextInt(1200);
      await Future.delayed(Duration(milliseconds: delayMs));

      // ── POST to n8n ───────────────────────────────────────────────────────
      final result = await _repository.sendLead(
        phone: lead.phone,
        name: lead.name,
        reason: _contactReason,
        instance: _selectedInstance!.label,
      );

      index++;

      if (!result.success) {
        _errorCount++;
        debugPrint(
          '[AiSend] Failed to send to ${lead.name}: ${result.errorMessage}',
        );
      } else {
        _sentCount++;
        // Simulates response rate (23% — aligned with mock KPI)
        if (_random.nextDouble() < 0.23) _repliedCount++;
      }

      _progress = index / total;
      notifyListeners();

      // Schedule next without blocking UI
      _timer = Timer(Duration.zero, sendNext);
    }

    sendNext();
  }

  void resetBroadcast() {
    _timer?.cancel();
    _isBroadcasting = false;
    _isCompleted = false;
    _progress = 0.0;
    _sentCount = 0;
    _repliedCount = 0;
    _errorCount = 0;
    _currentLeadName = '';
    notifyListeners();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
