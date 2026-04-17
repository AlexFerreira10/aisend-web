import 'package:aisend/data/services/schedule_service.dart';
import 'package:aisend/models/enums/blast_status_enum.dart';
import 'package:flutter/foundation.dart';

class ScheduleViewModel extends ChangeNotifier {
  final ScheduleService _service;

  ScheduleViewModel({required ScheduleService service}) : _service = service {
    loadScheduled();
  }

  List<ScheduledBlastItem> _items = [];
  bool _isLoading = false;
  String? _error;
  String? _cancelError;

  List<ScheduledBlastItem> get items => _items;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String? get cancelError => _cancelError;

  Future<void> loadScheduled() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _items = await _service.fetchScheduled();
    } catch (e) {
      _error = 'Erro ao carregar agendamentos: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> cancel(String id) async {
    _cancelError = null;
    try {
      await _service.cancel(id);
      _items = _items.map((item) {
        if (item.id == id) {
          return ScheduledBlastItem(
            id: item.id,
            scheduledAt: item.scheduledAt,
            status: BlastStatus.cancelled,
            motivo: item.motivo,
            totalContacts: item.totalContacts,
            sentCount: item.sentCount,
            errorCount: item.errorCount,
            executedAt: item.executedAt,
            consultantName: item.consultantName,
            instance: item.instance,
          );
        }
        return item;
      }).toList();
      notifyListeners();
      return true;
    } catch (e) {
      _cancelError = 'Erro ao cancelar: $e';
      notifyListeners();
      return false;
    }
  }
}
