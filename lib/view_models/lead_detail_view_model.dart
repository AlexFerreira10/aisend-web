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
  bool _isSending = false;

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
  bool get isSending => _isSending;

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

  Future<String?> sendMessage(String content) async {
    _isSending = true;
    notifyListeners();

    try {
      final response = await _leadsService.sendDirectMessage(lead.id, content);
      final saved = MessageModel(
        id: response['id']?.toString() ?? DateTime.now().millisecondsSinceEpoch.toString(),
        role: 'assistant',
        content: content,
        createdAt: response['createdAt'] != null
            ? DateTime.parse(response['createdAt'].toString())
            : DateTime.now(),
      );
      _messages = [..._messages, saved];
      _waitingHuman = true;
      return null;
    } catch (e) {
      return 'Erro ao enviar mensagem: $e';
    } finally {
      _isSending = false;
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
