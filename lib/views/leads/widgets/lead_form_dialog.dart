import 'package:aisend/core/constants/app_spacer.dart';
import 'package:aisend/models/enums/funnel_status_enum.dart';
import 'package:aisend/models/lead_model.dart';
import 'package:aisend/view_models/leads_view_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class LeadFormDialog extends StatefulWidget {
  final LeadModel? lead;

  const LeadFormDialog({super.key, this.lead});

  @override
  State<LeadFormDialog> createState() => _LeadFormDialogState();
}

class _LeadFormDialogState extends State<LeadFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _name;
  late final TextEditingController _phone;
  late final TextEditingController _specialty;
  late final TextEditingController _city;
  late final TextEditingController _registration;
  String? _selectedConsultantId;
  FunnelStatusEnum _funnelStatus = FunnelStatusEnum.cold;
  bool _saving = false;

  bool get _isEditing => widget.lead != null;

  @override
  void initState() {
    super.initState();
    final lead = widget.lead;
    _name = TextEditingController(text: lead?.name ?? '');
    _phone = TextEditingController(text: lead?.phone ?? '');
    _specialty = TextEditingController(text: lead?.specialty ?? '');
    _city = TextEditingController(text: '');
    _registration = TextEditingController(text: lead?.registration ?? '');
    _selectedConsultantId = lead?.consultantId;
    _funnelStatus = lead != null
        ? FunnelStatusEnumExtension.fromString(lead.funnelStatus.asString)
        : FunnelStatusEnum.cold;
  }

  @override
  void dispose() {
    _name.dispose();
    _phone.dispose();
    _specialty.dispose();
    _city.dispose();
    _registration.dispose();
    super.dispose();
  }

  Future<void> _save(LeadsViewModel vm) async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);

    final dto = {
      'name': _name.text.trim(),
      'phone': _phone.text.trim(),
      'specialty': _specialty.text.trim().isEmpty ? null : _specialty.text.trim(),
      'city': _city.text.trim().isEmpty ? null : _city.text.trim(),
      'registration': _registration.text.trim().isEmpty ? null : _registration.text.trim(),
      'consultantId': _selectedConsultantId,
      'funnelStatus': _funnelStatus.asString,
    };

    String? error;
    if (_isEditing) {
      error = await vm.updateLead(widget.lead!.id, dto);
    } else {
      error = await vm.createLead(dto);
    }

    if (!mounted) return;
    setState(() => _saving = false);

    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error), backgroundColor: Colors.red),
      );
    } else {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<LeadsViewModel>();

    return AlertDialog(
      title: Text(_isEditing ? 'Editar Lead' : 'Novo Lead'),
      content: SizedBox(
        width: 480,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _Field(
                  controller: _name,
                  label: 'Nome *',
                  validator: (v) =>
                      (v == null || v.trim().isEmpty) ? 'Nome obrigatório' : null,
                ),
                const AppSpacerVertical.medium(),
                _Field(
                  controller: _phone,
                  label: 'Telefone *',
                  hint: 'Ex: 11999990000',
                  keyboardType: TextInputType.phone,
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return 'Telefone obrigatório';
                    final digits = v.replaceAll(RegExp(r'\D'), '');
                    if (digits.length < 10) return 'Mínimo 10 dígitos';
                    return null;
                  },
                ),
                const AppSpacerVertical.medium(),
                _ConsultantDropdown(
                  instances: vm.instances,
                  value: _selectedConsultantId,
                  onChanged: (v) => setState(() => _selectedConsultantId = v),
                ),
                const AppSpacerVertical.medium(),
                _Field(controller: _specialty, label: 'Especialidade'),
                const AppSpacerVertical.medium(),
                _Field(controller: _city, label: 'Cidade'),
                const AppSpacerVertical.medium(),
                _Field(controller: _registration, label: 'Registro (CRM/CRF)'),
                const AppSpacerVertical.medium(),
                _FunnelStatusDropdown(
                  value: _funnelStatus,
                  onChanged: (v) => setState(() => _funnelStatus = v!),
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _saving ? null : () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: _saving ? null : () => _save(vm),
          child: _saving
              ? const SizedBox(
                  width: 16, height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                )
              : Text(_isEditing ? 'Salvar' : 'Criar Lead'),
        ),
      ],
    );
  }
}

class _Field extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String? hint;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;

  const _Field({
    required this.controller,
    required this.label,
    this.hint,
    this.keyboardType,
    this.validator,
  });

  @override
  Widget build(BuildContext context) => TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        validator: validator,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          border: const OutlineInputBorder(),
          isDense: true,
        ),
      );
}

class _ConsultantDropdown extends StatelessWidget {
  final List<dynamic> instances;
  final String? value;
  final ValueChanged<String?> onChanged;

  const _ConsultantDropdown({
    required this.instances,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final items = [
      const DropdownMenuItem<String>(value: null, child: Text('Sem consultor')),
      ...instances.map((i) => DropdownMenuItem<String>(
            value: i.consultantId as String?,
            child: Text(i.label as String),
          )),
    ];

    return DropdownButtonFormField<String>(
      value: value,
      items: items,
      onChanged: onChanged,
      decoration: const InputDecoration(
        labelText: 'Consultor',
        border: OutlineInputBorder(),
        isDense: true,
      ),
    );
  }
}

class _FunnelStatusDropdown extends StatelessWidget {
  final FunnelStatusEnum value;
  final ValueChanged<FunnelStatusEnum?> onChanged;

  const _FunnelStatusDropdown({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) => DropdownButtonFormField<FunnelStatusEnum>(
        value: value,
        onChanged: onChanged,
        decoration: const InputDecoration(
          labelText: 'Status do Funil',
          border: OutlineInputBorder(),
          isDense: true,
        ),
        items: const [
          DropdownMenuItem(value: FunnelStatusEnum.cold, child: Text('Frio')),
          DropdownMenuItem(value: FunnelStatusEnum.warm, child: Text('Morno')),
          DropdownMenuItem(value: FunnelStatusEnum.hot, child: Text('Quente')),
          DropdownMenuItem(value: FunnelStatusEnum.activeClient, child: Text('Cliente Ativo')),
        ],
      );
}
