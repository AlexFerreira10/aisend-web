import 'package:aisend/core/constants/app_dimensions.dart';
import 'package:aisend/core/constants/app_spacer.dart';
import 'package:aisend/core/theme/context_extension.dart';
import 'package:aisend/core/widgets/app_dialog.dart';
import 'package:aisend/models/follow_up_rule_model.dart';
import 'package:aisend/models/instance_model.dart';
import 'package:aisend/view_models/follow_up_view_model.dart';
import 'package:aisend/widgets/aisend_scaffold.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class FollowUpView extends StatelessWidget {
  const FollowUpView({super.key});

  @override
  Widget build(BuildContext context) {
    return AiSendScaffold(
      currentRoute: '/follow_up',
      body: SingleChildScrollView(
        padding: context.isDesktop
            ? const EdgeInsets.all(32)
            : (AppDimensions.extraLarge(context).isFinite
                  ? AppDimensions.paddingExtraLarge(context)
                  : AppDimensions.paddingLarge(context)),
        child: context.isDesktop
            ? const _DesktopLayout()
            : const _MainContent(),
      ),
    );
  }
}

class _DesktopLayout extends StatelessWidget {
  const _DesktopLayout();

  @override
  Widget build(BuildContext context) => const _MainContent();
}

class _MainContent extends StatelessWidget {
  const _MainContent();

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<FollowUpViewModel>();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        _PageHeader(vm: vm),
        const AppSpacerVertical.extraLarge(),
        if (vm.isLoading)
          const Center(child: CircularProgressIndicator())
        else if (vm.selectedInstance?.consultantId == null)
          const _EmptyState(
            icon: Icons.person_search_rounded,
            message:
                'Selecione um consultor para gerenciar as regras de follow-up.',
          )
        else if (vm.hasError)
          const _EmptyState(
            icon: Icons.cloud_off_rounded,
            message: 'Erro ao carregar regras. Tente novamente.',
          )
        else
          _RulesList(vm: vm),
      ],
    );
  }
}

// ─── Page Header ─────────────────────────────────────────────────────────────

class _PageHeader extends StatelessWidget {
  final FollowUpViewModel vm;
  const _PageHeader({required this.vm});

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: <Widget>[
      Text('Follow-up Automático', style: context.textTheme.displayMedium),
      const AppSpacerVertical.tiny(),
      Text(
        'Regras ativas de recontato automático. Para criar, use a Máquina de Disparos.',
        style: context.textTheme.bodyMedium?.copyWith(
          color: context.colorScheme.onSurfaceVariant,
        ),
      ),
      const AppSpacerVertical.large(),
      _InstanceSelector(vm: vm),
    ],
  );
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
      children: <Widget>[
        Text(
          vm.rules.isEmpty
              ? 'Nenhuma regra ativa'
              : '${vm.rules.length} regra${vm.rules.length != 1 ? 's' : ''}',
          style: context.textTheme.titleMedium?.copyWith(
            color: context.colorScheme.onSurfaceVariant,
          ),
        ),
        const AppSpacerVertical.large(),
        if (vm.rules.isEmpty)
          const _EmptyState(
            icon: Icons.tune_rounded,
            message:
                'Nenhuma regra de follow-up ativa. Crie uma na Máquina de Disparos.',
          )
        else
          ...vm.rules.map(
            (rule) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _RuleCard(vm: vm, rule: rule, consultantId: consultantId),
            ),
          ),
      ],
    );
  }
}

class _RuleCard extends StatelessWidget {
  final FollowUpViewModel vm;
  final FollowUpRuleModel rule;
  final String consultantId;
  const _RuleCard({
    required this.vm,
    required this.rule,
    required this.consultantId,
  });

  @override
  Widget build(BuildContext context) => Container(
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
      children: <Widget>[
        Row(
          children: <Widget>[
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    rule.name,
                    style: context.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
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
              label: '${rule.daysWithoutResponse}d sem resposta',
            ),
            const AppSpacerHorizontal.regular(),
            _InfoChip(
              icon: Icons.access_time_rounded,
              label: '${rule.scheduleHour.toString().padLeft(2, '0')}:00h',
            ),
            const AppSpacerHorizontal.regular(),
            _InfoChip(
              icon: Icons.repeat_rounded,
              label: 'Max ${rule.maxAttempts}x',
            ),
            const AppSpacerHorizontal.regular(),
            _InfoChip(
              icon: rule.messageMode == 'fixed'
                  ? Icons.edit_rounded
                  : Icons.auto_awesome_rounded,
              label: rule.messageMode == 'fixed' ? 'Fixa' : 'IA',
            ),
            const Spacer(),
            IconButton(
              icon: Icon(
                Icons.delete_rounded,
                color: context.colorScheme.error,
              ),
              tooltip: 'Excluir',
              onPressed: () => _confirmDelete(context),
            ),
          ],
        ),
      ],
    ),
  );

  void _confirmDelete(BuildContext context) => AppDialog.show<void>(
    context,
    title: 'Excluir regra',
    icon: Icons.delete_outline_rounded,
    content: Text(
      'Deseja excluir "${rule.name}"? Esta ação não pode ser desfeita.',
    ),
    actions: <Widget>[
      TextButton(
        onPressed: () => Navigator.pop(context),
        child: const Text('Cancelar'),
      ),
      FilledButton(
        style: FilledButton.styleFrom(
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
        onPressed: () {
          Navigator.pop(context);
          vm.deleteRule(rule.id);
        },
        child: const Text('Excluir'),
      ),
    ],
  );
}

class _ClassificationChip extends StatelessWidget {
  final String cls;
  const _ClassificationChip({required this.cls});

  static const _labels = {'hot': 'Quente', 'warm': 'Morno', 'cold': 'Frio'};
  static const _icons = {'hot': '🔥', 'warm': '☀️', 'cold': '❄️'};

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
    decoration: BoxDecoration(
      color: context.colorScheme.primaryContainer,
      borderRadius: AppDimensions.radiusRound,
    ),
    child: Text(
      '${_icons[cls] ?? ''} ${_labels[cls] ?? cls}',
      style: context.textTheme.labelSmall?.copyWith(
        color: context.colorScheme.onPrimaryContainer,
        fontWeight: FontWeight.w600,
      ),
    ),
  );
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  const _InfoChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: <Widget>[
      Icon(icon, size: 14, color: context.colorScheme.onSurfaceVariant),
      const SizedBox(width: 4),
      Text(
        label,
        style: context.textTheme.bodySmall?.copyWith(
          color: context.colorScheme.onSurfaceVariant,
        ),
      ),
    ],
  );
}

class _EmptyState extends StatelessWidget {
  final IconData icon;
  final String message;
  const _EmptyState({required this.icon, required this.message});

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.symmetric(vertical: 48),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(icon, size: 56, color: context.colorScheme.onSurfaceVariant),
          const AppSpacerVertical.large(),
          Text(
            message,
            textAlign: TextAlign.center,
            style: context.textTheme.bodyMedium?.copyWith(
              color: context.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    ),
  );
}
