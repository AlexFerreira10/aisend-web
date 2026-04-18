import 'package:aisend/core/constants/app_dimensions.dart';
import 'package:aisend/core/constants/app_spacer.dart';
import 'package:aisend/core/theme/context_extension.dart';
import 'package:aisend/models/follow_up_rule_model.dart';
import 'package:aisend/models/instance_model.dart';
import 'package:aisend/view_models/follow_up_view_model.dart';
import 'package:aisend/widgets/aisend_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class FollowUpView extends StatelessWidget {
  const FollowUpView({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<FollowUpViewModel>();

    return Scaffold(
      appBar: const AiSendAppBar(currentRoute: '/follow_up'),
      body: SingleChildScrollView(
        padding: AppDimensions.paddingExtraLarge(context),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _PageHeader(vm: vm),
            const AppSpacerVertical.extraLarge(),
            if (vm.isLoading)
              const Center(child: CircularProgressIndicator())
            else if (vm.selectedInstance?.consultantId == null)
              _EmptyState(
                icon: Icons.person_search_rounded,
                message: 'Selecione um consultor para gerenciar as regras de follow-up.',
              )
            else if (vm.hasError)
              _EmptyState(
                icon: Icons.cloud_off_rounded,
                message: 'Erro ao carregar regras. Tente novamente.',
              )
            else ...[
              _RulesList(vm: vm),
            ],
          ],
        ),
      ),
    );
  }
}

// ─── Page Header ─────────────────────────────────────────────────────────────

class _PageHeader extends StatelessWidget {
  final FollowUpViewModel vm;
  const _PageHeader({required this.vm});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Follow-up Automático', style: context.textTheme.displayMedium),
        const AppSpacerVertical.tiny(),
        Text(
          'Configure regras de recontato automático por consultor.',
          style: context.textTheme.bodyMedium
              ?.copyWith(color: context.colorScheme.onSurfaceVariant),
        ),
        const AppSpacerVertical.large(),
        _InstanceSelector(vm: vm),
      ],
    );
  }
}

class _InstanceSelector extends StatelessWidget {
  final FollowUpViewModel vm;
  const _InstanceSelector({required this.vm});

  @override
  Widget build(BuildContext context) {
    if (vm.instances.isEmpty) return const SizedBox.shrink();

    return DropdownButtonFormField<InstanceModel>(
      initialValue: vm.selectedInstance,
      decoration: const InputDecoration(
        labelText: 'Consultor',
        prefixIcon: Icon(Icons.person_rounded),
      ),
      items: vm.instances
          .map((i) => DropdownMenuItem(value: i, child: Text(i.displayName)))
          .toList(),
      onChanged: (i) {
        if (i != null) vm.selectInstance(i);
      },
    );
  }
}

// ─── Rules List ───────────────────────────────────────────────────────────────

class _RulesList extends StatelessWidget {
  final FollowUpViewModel vm;
  const _RulesList({required this.vm});

  @override
  Widget build(BuildContext context) {
    final consultantId = vm.selectedInstance!.consultantId!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              vm.rules.isEmpty ? 'Nenhuma regra criada' : '${vm.rules.length} regra${vm.rules.length != 1 ? 's' : ''}',
              style: context.textTheme.titleMedium
                  ?.copyWith(color: context.colorScheme.onSurfaceVariant),
            ),
            FilledButton.tonalIcon(
              onPressed: () => _openForm(context, vm, consultantId, null),
              icon: const Icon(Icons.add_rounded),
              label: const Text('Nova regra'),
            ),
          ],
        ),
        const AppSpacerVertical.large(),
        if (vm.rules.isEmpty)
          _EmptyState(
            icon: Icons.tune_rounded,
            message:
                'Crie sua primeira regra para ativar o follow-up automático.',
          )
        else
          ...vm.rules.map((rule) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _RuleCard(vm: vm, rule: rule, consultantId: consultantId),
              )),
      ],
    );
  }

  void _openForm(BuildContext context, FollowUpViewModel vm,
      String consultantId, FollowUpRuleModel? rule) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ChangeNotifierProvider.value(
          value: vm,
          child: FollowUpRuleFormView(
            consultantId: consultantId,
            existing: rule,
          ),
        ),
      ),
    );
  }
}

class _RuleCard extends StatelessWidget {
  final FollowUpViewModel vm;
  final FollowUpRuleModel rule;
  final String consultantId;
  const _RuleCard(
      {required this.vm, required this.rule, required this.consultantId});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: AppDimensions.paddingLarge(context),
      decoration: BoxDecoration(
        color: context.colorScheme.surfaceContainer,
        borderRadius: AppDimensions.radiusExtraLarge,
        border: Border.all(
          color: rule.isEnabled
              ? context.colorScheme.primary.withValues(alpha: 0.3)
              : context.colorScheme.outline,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(rule.name,
                        style: context.textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w700)),
                    const AppSpacerVertical.tiny(),
                    Wrap(
                      spacing: 6,
                      children: rule.targetClassifications
                          .map((c) => _ClassificationChip(cls: c))
                          .toList(),
                    ),
                  ],
                ),
              ),
              Switch(
                value: rule.isEnabled,
                onChanged: (_) => vm.toggleRule(rule.id),
              ),
            ],
          ),
          const AppSpacerVertical.regular(),
          const Divider(height: 1),
          const AppSpacerVertical.regular(),
          Row(
            children: [
              _InfoChip(
                  icon: Icons.schedule_rounded,
                  label: '${rule.daysWithoutResponse}d sem resposta'),
              const AppSpacerHorizontal.regular(),
              _InfoChip(
                  icon: Icons.access_time_rounded,
                  label: '${rule.scheduleHour.toString().padLeft(2, '0')}:00h'),
              const AppSpacerHorizontal.regular(),
              _InfoChip(
                  icon: Icons.repeat_rounded,
                  label: 'Max ${rule.maxAttempts}x'),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.edit_rounded),
                tooltip: 'Editar',
                onPressed: () => _openForm(context, rule),
              ),
              IconButton(
                icon: Icon(Icons.delete_rounded,
                    color: context.colorScheme.error),
                tooltip: 'Excluir',
                onPressed: () => _confirmDelete(context),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _openForm(BuildContext context, FollowUpRuleModel rule) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ChangeNotifierProvider.value(
          value: vm,
          child: FollowUpRuleFormView(
            consultantId: consultantId,
            existing: rule,
          ),
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Excluir regra'),
        content: Text('Deseja excluir "${rule.name}"? Esta ação não pode ser desfeita.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
                backgroundColor: Theme.of(ctx).colorScheme.error),
            onPressed: () {
              Navigator.pop(ctx);
              vm.deleteRule(rule.id);
            },
            child: const Text('Excluir'),
          ),
        ],
      ),
    );
  }
}

class _ClassificationChip extends StatelessWidget {
  final String cls;
  const _ClassificationChip({required this.cls});

  static const _labels = {'hot': 'Quente', 'warm': 'Morno', 'cold': 'Frio'};
  static const _icons = {'hot': '🔥', 'warm': '☀️', 'cold': '❄️'};

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: context.colorScheme.primaryContainer,
        borderRadius: AppDimensions.radiusRound,
      ),
      child: Text(
        '${_icons[cls] ?? ''} ${_labels[cls] ?? cls}',
        style: context.textTheme.labelSmall?.copyWith(
            color: context.colorScheme.onPrimaryContainer,
            fontWeight: FontWeight.w600),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  const _InfoChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: context.colorScheme.onSurfaceVariant),
        const SizedBox(width: 4),
        Text(label,
            style: context.textTheme.bodySmall
                ?.copyWith(color: context.colorScheme.onSurfaceVariant)),
      ],
    );
  }
}

class _EmptyState extends StatelessWidget {
  final IconData icon;
  final String message;
  const _EmptyState({required this.icon, required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 48),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 56, color: context.colorScheme.onSurfaceVariant),
            const AppSpacerVertical.large(),
            Text(message,
                textAlign: TextAlign.center,
                style: context.textTheme.bodyMedium
                    ?.copyWith(color: context.colorScheme.onSurfaceVariant)),
          ],
        ),
      ),
    );
  }
}

// ─── Rule Form View ───────────────────────────────────────────────────────────

class FollowUpRuleFormView extends StatefulWidget {
  final String consultantId;
  final FollowUpRuleModel? existing;

  const FollowUpRuleFormView({
    super.key,
    required this.consultantId,
    this.existing,
  });

  @override
  State<FollowUpRuleFormView> createState() => _FollowUpRuleFormViewState();
}

class _FollowUpRuleFormViewState extends State<FollowUpRuleFormView> {
  late FollowUpRuleModel _draft;
  late TextEditingController _nameCtrl;
  late TextEditingController _fixedMsgCtrl;
  bool _isSaving = false;

  bool get _isEdit => widget.existing != null;

  @override
  void initState() {
    super.initState();
    _draft = widget.existing ??
        emptyRule(widget.consultantId);
    _nameCtrl = TextEditingController(text: _draft.name);
    _fixedMsgCtrl = TextEditingController(text: _draft.fixedMessage ?? '');
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _fixedMsgCtrl.dispose();
    super.dispose();
  }

  void _update(FollowUpRuleModel updated) => setState(() => _draft = updated);

  Future<void> _save() async {
    final vm = context.read<FollowUpViewModel>();
    setState(() => _isSaving = true);

    final toSave = _draft.copyWith(
      name: _nameCtrl.text.trim().isEmpty ? 'Nova regra' : _nameCtrl.text.trim(),
      fixedMessage: _draft.messageMode == 'fixed' ? _fixedMsgCtrl.text : null,
    );

    bool ok;
    if (_isEdit) {
      ok = await vm.updateRule(toSave);
    } else {
      final created = await vm.createRule(toSave);
      ok = created != null;
    }

    if (mounted) {
      setState(() => _isSaving = false);
      if (ok) Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEdit ? 'Editar regra' : 'Nova regra'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: AppDimensions.paddingExtraLarge(context),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _NameCard(ctrl: _nameCtrl),
            const AppSpacerVertical.large(),
            _EnabledCard(draft: _draft, onUpdate: _update),
            const AppSpacerVertical.large(),
            _TimingCard(draft: _draft, onUpdate: _update),
            const AppSpacerVertical.large(),
            _AudienceCard(draft: _draft, onUpdate: _update),
            const AppSpacerVertical.large(),
            _MessageCard(draft: _draft, fixedMsgCtrl: _fixedMsgCtrl, onUpdate: _update),
            const AppSpacerVertical.large(),
            _AttemptsCard(draft: _draft, onUpdate: _update),
            const AppSpacerVertical.extraLarge(),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: _isSaving ? null : _save,
                icon: _isSaving
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white),
                      )
                    : Icon(_isEdit ? Icons.save_rounded : Icons.add_rounded),
                label: Text(_isSaving
                    ? 'Salvando...'
                    : _isEdit
                        ? 'Salvar alterações'
                        : 'Criar regra'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Form Cards ───────────────────────────────────────────────────────────────

class _NameCard extends StatelessWidget {
  final TextEditingController ctrl;
  const _NameCard({required this.ctrl});

  @override
  Widget build(BuildContext context) {
    return _Card(
      title: 'Nome da regra',
      child: TextField(
        controller: ctrl,
        decoration: const InputDecoration(
          hintText: 'ex: Mornos — 7 dias',
        ),
      ),
    );
  }
}

class _EnabledCard extends StatelessWidget {
  final FollowUpRuleModel draft;
  final ValueChanged<FollowUpRuleModel> onUpdate;
  const _EnabledCard({required this.draft, required this.onUpdate});

  @override
  Widget build(BuildContext context) {
    return _Card(
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Regra ativada',
                    style: context.textTheme.titleMedium
                        ?.copyWith(fontWeight: FontWeight.w700)),
                const AppSpacerVertical.tiny(),
                Text(
                  draft.isEnabled
                      ? 'O bot enviará follow-up conforme esta regra'
                      : 'A regra está desativada e será ignorada pelo bot',
                  style: context.textTheme.bodySmall,
                ),
              ],
            ),
          ),
          Switch(
            value: draft.isEnabled,
            onChanged: (v) => onUpdate(draft.copyWith(isEnabled: v)),
          ),
        ],
      ),
    );
  }
}

class _TimingCard extends StatelessWidget {
  final FollowUpRuleModel draft;
  final ValueChanged<FollowUpRuleModel> onUpdate;
  const _TimingCard({required this.draft, required this.onUpdate});

  @override
  Widget build(BuildContext context) {
    return _Card(
      title: 'Quando disparar',
      children: [
        _SettingRow(
          label: 'Dias sem resposta',
          description:
              'Follow-up após ${draft.daysWithoutResponse} dia${draft.daysWithoutResponse != 1 ? 's' : ''} sem responder',
          child: _Stepper(
            value: draft.daysWithoutResponse,
            min: 1,
            max: 90,
            onChanged: (v) => onUpdate(draft.copyWith(daysWithoutResponse: v)),
          ),
        ),
        const Divider(height: 24),
        _SettingRow(
          label: 'Horário de envio',
          description:
              'Disparos às ${draft.scheduleHour.toString().padLeft(2, '0')}:00h (horário de Brasília)',
          child: DropdownButton<int>(
            value: draft.scheduleHour,
            underline: const SizedBox(),
            items: List.generate(24, (i) => i)
                .map((h) => DropdownMenuItem(
                      value: h,
                      child: Text('${h.toString().padLeft(2, '0')}:00'),
                    ))
                .toList(),
            onChanged: (v) {
              if (v != null) onUpdate(draft.copyWith(scheduleHour: v));
            },
          ),
        ),
      ],
    );
  }
}

class _AudienceCard extends StatelessWidget {
  final FollowUpRuleModel draft;
  final ValueChanged<FollowUpRuleModel> onUpdate;
  const _AudienceCard({required this.draft, required this.onUpdate});

  static const _options = [
    ('hot', '🔥 Quentes'),
    ('warm', '☀️ Mornos'),
    ('cold', '❄️ Frios'),
  ];

  @override
  Widget build(BuildContext context) {
    return _Card(
      title: 'Para quem enviar',
      children: _options.map((opt) {
        final selected = draft.targetClassifications.contains(opt.$1);
        return CheckboxListTile(
          value: selected,
          title: Text(opt.$2, style: context.textTheme.bodyMedium),
          contentPadding: EdgeInsets.zero,
          onChanged: (v) {
            final updated = List<String>.from(draft.targetClassifications);
            if (v == true) {
              updated.add(opt.$1);
            } else if (updated.length > 1) {
              updated.remove(opt.$1);
            }
            onUpdate(draft.copyWith(targetClassifications: updated));
          },
        );
      }).toList(),
    );
  }
}

class _MessageCard extends StatelessWidget {
  final FollowUpRuleModel draft;
  final TextEditingController fixedMsgCtrl;
  final ValueChanged<FollowUpRuleModel> onUpdate;
  const _MessageCard(
      {required this.draft,
      required this.fixedMsgCtrl,
      required this.onUpdate});

  @override
  Widget build(BuildContext context) {
    return _Card(
      title: 'Tipo de mensagem',
      children: [
        Row(
          children: [
            Expanded(
              child: _ModeButton(
                label: 'IA gera variações',
                icon: Icons.auto_awesome_rounded,
                selected: draft.messageMode == 'ai',
                onTap: () => onUpdate(draft.copyWith(messageMode: 'ai')),
              ),
            ),
            const AppSpacerHorizontal.regular(),
            Expanded(
              child: _ModeButton(
                label: 'Mensagem fixa',
                icon: Icons.edit_rounded,
                selected: draft.messageMode == 'fixed',
                onTap: () => onUpdate(draft.copyWith(messageMode: 'fixed')),
              ),
            ),
          ],
        ),
        if (draft.messageMode == 'fixed') ...[
          const AppSpacerVertical.large(),
          TextField(
            controller: fixedMsgCtrl,
            maxLines: 4,
            decoration: const InputDecoration(
              hintText:
                  'Olá {nome}! Vim ver se você teve chance de avaliar nossa proposta...',
            ),
          ),
          const AppSpacerVertical.small(),
          Text(
            'Use {nome} para inserir o nome do lead automaticamente.',
            style: context.textTheme.bodySmall
                ?.copyWith(fontStyle: FontStyle.italic),
          ),
        ] else ...[
          const AppSpacerVertical.regular(),
          Text(
            'A IA criará uma mensagem personalizada com base no histórico de cada lead.',
            style: context.textTheme.bodySmall,
          ),
        ],
      ],
    );
  }
}

class _AttemptsCard extends StatelessWidget {
  final FollowUpRuleModel draft;
  final ValueChanged<FollowUpRuleModel> onUpdate;
  const _AttemptsCard({required this.draft, required this.onUpdate});

  @override
  Widget build(BuildContext context) {
    return _Card(
      title: 'Máximo de tentativas',
      child: _SettingRow(
        label: 'Tentativas por lead',
        description:
            'Após ${draft.maxAttempts} follow-up${draft.maxAttempts != 1 ? 's' : ''} sem resposta, o lead é arquivado',
        child: _Stepper(
          value: draft.maxAttempts,
          min: 1,
          max: 10,
          onChanged: (v) => onUpdate(draft.copyWith(maxAttempts: v)),
        ),
      ),
    );
  }
}

// ─── Shared Widgets ───────────────────────────────────────────────────────────

class _Card extends StatelessWidget {
  final String? title;
  final Widget? child;
  final List<Widget>? children;

  const _Card({this.title, this.child, this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: AppDimensions.paddingLarge(context),
      decoration: BoxDecoration(
        color: context.colorScheme.surfaceContainer,
        borderRadius: AppDimensions.radiusExtraLarge,
        border: Border.all(color: context.colorScheme.outline, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title != null) ...[
            Text(title!,
                style: context.textTheme.titleMedium
                    ?.copyWith(fontWeight: FontWeight.w700)),
            const AppSpacerVertical.large(),
          ],
          ?child,
          ...?children,
        ],
      ),
    );
  }
}

class _SettingRow extends StatelessWidget {
  final String label;
  final String description;
  final Widget child;

  const _SettingRow(
      {required this.label, required this.description, required this.child});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: context.textTheme.bodyMedium
                      ?.copyWith(fontWeight: FontWeight.w600)),
              const AppSpacerVertical.tiny(),
              Text(description, style: context.textTheme.bodySmall),
            ],
          ),
        ),
        child,
      ],
    );
  }
}

class _Stepper extends StatelessWidget {
  final int value;
  final int min;
  final int max;
  final ValueChanged<int> onChanged;

  const _Stepper(
      {required this.value,
      required this.min,
      required this.max,
      required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: const Icon(Icons.remove_rounded),
          onPressed: value > min ? () => onChanged(value - 1) : null,
        ),
        Text('$value',
            style: context.textTheme.titleLarge
                ?.copyWith(fontWeight: FontWeight.w700)),
        IconButton(
          icon: const Icon(Icons.add_rounded),
          onPressed: value < max ? () => onChanged(value + 1) : null,
        ),
      ],
    );
  }
}

class _ModeButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  const _ModeButton(
      {required this.label,
      required this.icon,
      required this.selected,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected
              ? context.colorScheme.primary
              : context.colorScheme.surface,
          borderRadius: AppDimensions.radiusLarge,
          border: Border.all(
            color: selected
                ? context.colorScheme.primary
                : context.colorScheme.outline,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon,
                size: 16,
                color: selected
                    ? Colors.white
                    : context.colorScheme.onSurface),
            const SizedBox(width: 6),
            Text(
              label,
              style: context.textTheme.labelLarge?.copyWith(
                color: selected ? Colors.white : context.colorScheme.onSurface,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
