import 'dart:convert';
import 'package:aisend/data/services/schemas/api_exception.dart';
import 'package:aisend/models/instance_model.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import '../data/services/leads_service.dart';
import '../data/services/broadcast_service.dart';
import '../data/services/consultants_service.dart';
import '../data/services/schedule_service.dart';
import '../models/lead_model.dart';

enum MessageMode { aiGenerated, fixed }
enum SendMode { immediate, scheduled }

class BroadcastViewModel extends ChangeNotifier {
  final LeadsService _leadsService;
  final BroadcastService _broadcastService;
  final ConsultantsService _consultantsService;
  final ScheduleService _scheduleService;

  BroadcastViewModel({
    required LeadsService leadsService,
    required BroadcastService broadcastService,
    required ConsultantsService consultantsService,
    required ScheduleService scheduleService,
  })  : _leadsService = leadsService,
        _broadcastService = broadcastService,
        _consultantsService = consultantsService,
        _scheduleService = scheduleService {
    _loadInstances();
  }

  // ─── Instances ───────────────────────────────────────────────────────────────
  List<InstanceModel> _instances = [];
  bool _loadingInstances = true;

  List<InstanceModel> get instances => _instances;
  bool get loadingInstances => _loadingInstances;

  Future<void> _loadInstances() async {
    try {
  _instances = await _consultantsService.fetchInstances();
    } catch (_) {
      _instances = [];
    } finally {
      _loadingInstances = false;
      notifyListeners();
    }
  }

  // ─── Form State ──────────────────────────────────────────────────────────────
  InstanceModel? _selectedInstance;
  String _contactReason = '';
  String? _uploadedFileName;
  bool _leadsFromBase = false;
  List<LeadModel> _dynamicLeads = [];
  bool _isLoadingLeads = false;
  String? _pullLeadsError;

  InstanceModel? get selectedInstance => _selectedInstance;
  String get contactReason => _contactReason;
  String? get uploadedFileName => _uploadedFileName;
  bool get leadsFromBase => _leadsFromBase;
  int get dynamicLeadsCount => _dynamicLeads.length;
  bool get isLoadingLeads => _isLoadingLeads;
  String? get pullLeadsError => _pullLeadsError;

  // ─── Message Mode ─────────────────────────────────────────────────────────
  MessageMode _messageMode = MessageMode.aiGenerated;
  String _fixedMessage = '';

  MessageMode get messageMode => _messageMode;
  String get fixedMessage => _fixedMessage;

  void setMessageMode(MessageMode mode) {
    _messageMode = mode;
    _previewParts = [];
    _previewError = null;
    notifyListeners();
  }

  void setFixedMessage(String value) {
    _fixedMessage = value;
    notifyListeners();
  }

  void selectInstance(InstanceModel? instance) {
    _selectedInstance = instance;
    notifyListeners();
  }

  void setReason(String value) {
    _contactReason = value;
    notifyListeners();
  }

  String? _parseWarnings;
  String? get parseWarnings => _parseWarnings;

  Future<void> pickAndParseFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json', 'csv', 'xlsx'],
        withData: true,
      );

      if (result == null || result.files.single.bytes == null) return;

      final file = result.files.single;
      final bytes = file.bytes!;
      final ext = file.extension?.toLowerCase() ?? '';

      _parseWarnings = null;

      if (ext == 'json') {
        // Client-side JSON parse (existing behaviour)
        final content = utf8.decode(bytes);
        final dynamic data = jsonDecode(content);
        if (data is List) {
          _dynamicLeads = data.map((item) {
            final map = item as Map<String, dynamic>;
            final String name = map['nome'] ?? map['name'] ?? 'Sem nome';
            final String phone =
                map['numero'] ?? map['phone'] ?? map['telefone'] ?? '';
            return LeadModel(
              id: '${DateTime.now().millisecondsSinceEpoch}$phone',
              name: name,
              phone: phone,
              createdAt: DateTime.now(),
            );
          }).where((l) => l.phone.isNotEmpty).toList();
          _uploadedFileName = file.name;
          _leadsFromBase = false;
          notifyListeners();
        }
      } else {
        // CSV / XLSX → backend parse
        final parsed = await _broadcastService.parseContacts(bytes, file.name);
        _dynamicLeads = parsed.contacts.map((c) => LeadModel(
              id: '${DateTime.now().millisecondsSinceEpoch}${c.phone}',
              name: c.name,
              phone: c.phone,
              createdAt: DateTime.now(),
            )).toList();
        _uploadedFileName = file.name;
        _leadsFromBase = false;
        if (parsed.warnings.isNotEmpty) {
          _parseWarnings = '${parsed.warnings.length} ignorado(s): ${parsed.warnings.first}'
              '${parsed.warnings.length > 1 ? ' (+${parsed.warnings.length - 1})' : ''}';
        }
        notifyListeners();
      }
    } catch (e) {
      debugPrint('[BroadcastVM] Error importing file: $e');
    }
  }

  Future<void> pullLeadsFromBase() async {
    _isLoadingLeads = true;
    _pullLeadsError = null;
    notifyListeners();

    try {
      final response = await _leadsService.fetchLeads(
        classification: 'cold',
        pageSize: 100,
      );
      _dynamicLeads = response.items;
      _leadsFromBase = true;
      _uploadedFileName = null;
    } catch (e) {
      _leadsFromBase = false;
      _pullLeadsError = 'Erro ao buscar leads: $e';
    } finally {
      _isLoadingLeads = false;
      notifyListeners();
    }
  }

  void clearUpload() {
    _uploadedFileName = null;
    _leadsFromBase = false;
    _dynamicLeads = [];
    _parseWarnings = null;
    notifyListeners();
  }

  // ─── Preview State ───────────────────────────────────────────────────────────
  List<String> _previewParts = [];
  bool _isPreviewing = false;
  String? _previewError;

  List<String> get previewParts => _previewParts;
  bool get isPreviewing => _isPreviewing;
  bool get hasPreview => _previewParts.isNotEmpty;
  String? get previewError => _previewError;

  bool get _hasValidMessage =>
      _messageMode == MessageMode.aiGenerated
          ? _contactReason.trim().isNotEmpty
          : _fixedMessage.trim().isNotEmpty;

  bool get canPreview =>
      _selectedInstance != null &&
      _hasValidMessage &&
      (_uploadedFileName != null || _leadsFromBase) &&
      _dynamicLeads.isNotEmpty &&
      !_isBroadcasting &&
      !_isPreviewing;

  Future<void> previewBlast() async {
    if (!canPreview) return;
    _isPreviewing = true;
    _previewParts = [];
    _previewError = null;
    notifyListeners();
    try {
      final sampleName = _dynamicLeads.isNotEmpty ? _dynamicLeads.first.name : 'João';
      final body = <String, dynamic>{
        'instancia': _selectedInstance!.id,
        'motivo': _contactReason,
        'sampleName': sampleName,
        if (_messageMode == MessageMode.fixed) 'fixedMessage': _fixedMessage.trim(),
      };
      _previewParts = await _broadcastService.preview(body);
    } catch (e) {
      _previewError = 'Erro ao gerar prévia: $e';
    } finally {
      _isPreviewing = false;
      notifyListeners();
    }
  }

  void resetPreview() {
    _previewParts = [];
    _previewError = null;
    notifyListeners();
  }

  void updatePreviewPart(int index, String value) {
    if (index < _previewParts.length) {
      _previewParts[index] = value;
    }
  }

  // ─── Broadcast State ──────────────────────────────────────────────────────────
  bool _isBroadcasting = false;
  bool _isCompleted = false;
  double _progress = 0.0;
  int _sentCount = 0;
  // _repliedCount is not populated in real-time by the blast API (MVP limitation)
  int _repliedCount = 0;
  int _errorCount = 0;
  String _currentLeadName = '';
  String? _broadcastError;

  bool get isBroadcasting => _isBroadcasting;
  bool get isCompleted => _isCompleted;
  double get progress => _progress;
  int get sentCount => _sentCount;
  int get repliedCount => _repliedCount;
  int get errorCount => _errorCount;
  String get currentLeadName => _currentLeadName;
  String? get broadcastError => _broadcastError;

  bool get canBroadcast =>
      _selectedInstance != null &&
      _hasValidMessage &&
      (_uploadedFileName != null || _leadsFromBase) &&
      _dynamicLeads.isNotEmpty &&
      !_isBroadcasting;

  Future<void> startBroadcast(VoidCallback onComplete) async {
    if (!canBroadcast) return;

    _isBroadcasting = true;
    _isCompleted = false;
    _progress = 0.0;
    _sentCount = 0;
    _errorCount = 0;
    _broadcastError = null;
    notifyListeners();

    try {
      final contacts = _dynamicLeads
          .map((l) => {'phone': l.phone, 'name': l.name})
          .toList();

      final total = contacts.length;
      int processed = 0;

      // Split into batches of 10 to give incremental progress feedback.
      // The backend controls the actual sending delay (2–5s random per message).
      const batchSize = 10;
      final batches = <List<Map<String, String>>>[];
      for (var i = 0; i < contacts.length; i += batchSize) {
        final end = (i + batchSize).clamp(0, contacts.length);
        batches.add(contacts.sublist(i, end));
      }

      for (final batch in batches) {
        _currentLeadName = batch.first['name'] ?? '';
        notifyListeners();

        final payload = <String, dynamic>{
          'instancia': _selectedInstance!.id,
          'motivo': _contactReason,
          'contacts': batch,
          if (_messageMode == MessageMode.fixed)
            'fixedMessage': _fixedMessage.trim()
          else if (_previewParts.isNotEmpty)
            'baseMessage': _previewParts.join('|||'),
        };
        final response = await _broadcastService.sendBlast(payload);

        _sentCount += response.sent;
        _errorCount += response.errors;
        processed += batch.length;
        _progress = processed / total;
        notifyListeners();
      }

      _isCompleted = true;
      onComplete();
    } on ApiException catch (e) {
      _broadcastError = e.isNetworkError
          ? 'Sem conexão com o servidor.'
          : 'Erro ao disparar: ${e.message}';
    } catch (e) {
      _broadcastError = 'Erro inesperado: $e';
    } finally {
      _isBroadcasting = false;
      _currentLeadName = '';
      _progress = _isCompleted ? 1.0 : _progress;
      notifyListeners();
    }
  }

  // ─── Send Mode (immediate vs scheduled) ──────────────────────────────────────
  SendMode _sendMode = SendMode.immediate;
  DateTime? _scheduledAt;
  bool _isScheduling = false;
  bool _scheduleSuccess = false;
  String? _scheduleError;

  SendMode get sendMode => _sendMode;
  DateTime? get scheduledAt => _scheduledAt;
  bool get isScheduling => _isScheduling;
  bool get scheduleSuccess => _scheduleSuccess;
  String? get scheduleError => _scheduleError;

  void setSendMode(SendMode mode) {
    _sendMode = mode;
    notifyListeners();
  }

  void setScheduledAt(DateTime dt) {
    _scheduledAt = dt;
    notifyListeners();
  }

  bool get canSchedule =>
      canPreview && _scheduledAt != null && _scheduledAt!.isAfter(DateTime.now());

  Future<void> scheduleBlast() async {
    if (!canSchedule) return;
    _isScheduling = true;
    _scheduleError = null;
    _scheduleSuccess = false;
    notifyListeners();
    try {
      final contacts = _dynamicLeads
          .map((l) => {'phone': l.phone, 'name': l.name})
          .toList();
      await _scheduleService.createSchedule({
        'instancia': _selectedInstance!.id,
        'motivo': _contactReason,
        'scheduledAt': _scheduledAt!.toUtc().toIso8601String(),
        'contacts': contacts,
        if (_messageMode == MessageMode.fixed) 'fixedMessage': _fixedMessage.trim(),
      });
      _scheduleSuccess = true;
    } catch (e) {
      _scheduleError = 'Erro ao agendar: $e';
    } finally {
      _isScheduling = false;
      notifyListeners();
    }
  }

  void resetBroadcast() {
    _isBroadcasting = false;
    _isCompleted = false;
    _progress = 0.0;
    _sentCount = 0;
    _repliedCount = 0;
    _errorCount = 0;
    _currentLeadName = '';
    _broadcastError = null;
    _previewParts = [];
    _previewError = null;
    notifyListeners();
  }
}
