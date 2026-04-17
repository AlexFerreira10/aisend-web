import 'package:aisend/models/message_model.dart';
import 'package:flutter/foundation.dart';
import '../data/services/leads_service.dart';
import '../models/lead_model.dart';

class LeadDetailViewModel extends ChangeNotifier {
  final LeadsService _leadsService;
  final LeadModel lead;

  List<MessageModel> _messages = [];
  bool _isLoading = true;
  bool _hasError = false;
  bool _updatingWaiting = false;
  bool _waitingHuman;
  String? _toggleError;

  LeadDetailViewModel({required LeadsService leadsService, required this.lead})
      : _leadsService = leadsService,
        _waitingHuman = lead.waitingHuman {
    loadMessages();
  }

  List<MessageModel> get messages => _messages;
  bool get isLoading => _isLoading;
  bool get hasError => _hasError;
  bool get waitingHuman => _waitingHuman;
  bool get updatingWaiting => _updatingWaiting;
  String? get toggleError => _toggleError;

  Future<void> loadMessages() async {
    _isLoading = true;
    _hasError = false;
    notifyListeners();

    try {
  _messages = await _leadsService.fetchMessages(lead.phone);
    } catch (_) {
      _hasError = true;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> toggleWaitingHuman() async {
    _updatingWaiting = true;
    notifyListeners();

    try {
      final newValue = !_waitingHuman;
      await _leadsService.setWaitingHuman(lead.phone, waiting: newValue);
      _waitingHuman = newValue;
      _toggleError = null;
    } catch (e) {
      _toggleError = 'Erro ao atualizar atendimento: $e';
    } finally {
      _updatingWaiting = false;
      notifyListeners();
    }
  }
}
