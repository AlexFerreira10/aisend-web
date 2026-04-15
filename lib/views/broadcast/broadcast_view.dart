import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/context_extension.dart';
import '../../core/theme/custom_colors_extension.dart';
import '../../core/utils/app_toast.dart';
import '../../core/constants/app_dimensions.dart';
import '../../core/constants/app_spacer.dart';
import '../../models/lead_model.dart';
import '../../view_models/broadcast_view_model.dart';
import '../../widgets/aisend_app_bar.dart';
import 'widgets/upload_zone.dart';
import 'widgets/broadcast_progress.dart';
import 'widgets/sidebar_benefits.dart';

class BroadcastView extends StatelessWidget {
  const BroadcastView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AiSendAppBar(currentRoute: '/broadcast'),
      body: SingleChildScrollView(
        child: Padding(
          padding: AppDimensions.extraLarge(context).isFinite 
              ? AppDimensions.paddingExtraLarge(context)
              : AppDimensions.paddingLarge(context),
          // We can use a simpler approach for page padding
          child: context.isDesktop ? _DesktopLayout() : _MobileLayout(),
        ),
      ),
    );
  }
}

class _DesktopLayout extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Expanded(flex: 65, child: _MainContent()),
        const AppSpacerHorizontal.large(),
        // Right — sidebar (35%)
        const SizedBox(width: 320, child: SidebarBenefits()),
      ],
    );
  }
}

class _MobileLayout extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Column(
    children: <Widget>[
      _MainContent(),
      const AppSpacerVertical.large(),
      const SidebarBenefits(),
    ],
  );
}

class _MainContent extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final vm = context.watch<BroadcastViewModel>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section 1: Upload
        _SectionCard(
          number: '1',
          title: 'Entrada de Dados',
          child: Column(
            children: [
              UploadZone(
                uploadedFileName: vm.uploadedFileName,
                leadCount: vm.dynamicLeadsCount > 0
                    ? vm.dynamicLeadsCount
                    : null,
                onUpload: vm.pickAndParseJson,
                onClear: vm.clearUpload,
              ),

              if (vm.uploadedFileName == null && !vm.leadsFromBase) ...[
                const AppSpacerVertical.medium(),
                Row(
                  children: [
                    const Expanded(child: Divider()),
                    Padding(
                      padding: AppDimensions.paddingHorizontalMedium(context),
                      child: Text(
                        'ou',
                        style: context.textTheme.bodySmall,
                      ),
                    ),
                    const Expanded(child: Divider()),
                  ],
                ),
                const AppSpacerVertical.medium(),
                _PullLeadsButton(),
              ],

              if (vm.leadsFromBase) ...[
                const AppSpacerVertical.medium(),
                _BaseLeadsChip(onClear: vm.clearUpload),
              ],
            ],
          ),
        ),
        const AppSpacerVertical.large(),

        // Section 2: Config
        _SectionCard(
          number: '2',
          title: 'Configuração do Disparo',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Instance dropdown
              Text(
                'Selecionar Instância',
                style: context.textTheme.titleLarge?.copyWith(
                  color: context.colorScheme.onSurfaceVariant,
                ),
              ),
              const AppSpacerVertical.regular(),
              _InstanceDropdown(),
              const AppSpacerVertical.large(),

              // Reason
              Text(
                'Motivo do Contato',
                style: context.textTheme.titleLarge?.copyWith(
                  color: context.colorScheme.onSurfaceVariant,
                ),
              ),
              const AppSpacerVertical.regular(),
              _ReasonField(),
              const AppSpacerVertical.tiny(),
              Text(
                'A IA gerará variações naturais com base neste contexto',
                style: context.textTheme.bodySmall?.copyWith(
                  fontStyle: FontStyle.italic,
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ),
        const AppSpacerVertical.large(),

        // Progress (visible during/after broadcast)
        if (vm.isBroadcasting || vm.isCompleted) ...[
          BroadcastProgress(
            progress: vm.progress,
            sentCount: vm.sentCount,
            repliedCount: vm.repliedCount,
            errorCount: vm.errorCount,
            currentLeadName: vm.currentLeadName,
            isCompleted: vm.isCompleted,
          ),
          const AppSpacerVertical.large(),
        ],

        // Start Button
        _StartButton(),
      ],
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String number;
  final String title;
  final Widget child;

  const _SectionCard({
    required this.number,
    required this.title,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: AppDimensions.paddingExtraLarge(context),
      decoration: BoxDecoration(
        color: context.colorScheme.surfaceContainer,
        borderRadius: AppDimensions.radiusExtraLarge,
        border: Border.all(color: context.colorScheme.outline, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section header
          Row(
            children: [
              Container(
                width: 26,
                height: 26,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  gradient: context.customColors.primaryGradient,
                  borderRadius: AppDimensions.radiusSmall,
                ),
                child: Text(
                  number,
                  style: context.textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
              const AppSpacerHorizontal.regular(),
              Text(
                title,
                style: context.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: context.colorScheme.onSurface,
                ),
              ),
            ],
          ),
          const AppSpacerVertical.large(),
          child,
        ],
      ),
    );
  }
}

class _PullLeadsButton extends StatefulWidget {
  @override
  State<_PullLeadsButton> createState() => _PullLeadsButtonState();
}

class _PullLeadsButtonState extends State<_PullLeadsButton> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final vm = context.read<BroadcastViewModel>();
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: vm.pullLeadsFromBase,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: double.infinity,
          padding: AppDimensions.paddingVerticalMediumLarge(context),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: _hovered ? context.colorScheme.primary.withValues(alpha: 0.1) : Colors.transparent,
            borderRadius: AppDimensions.radiusLarge,
            border: Border.all(
              color: _hovered ? context.colorScheme.primary : context.colorScheme.outline,
              width: 1.5,
            ),
          ),
          child: Text(
            'Puxar Leads Frios do Banco de Dados',
            style: context.textTheme.labelLarge?.copyWith(
              color: _hovered ? context.colorScheme.primary : context.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      ),
    );
  }
}

class _BaseLeadsChip extends StatelessWidget {
  final VoidCallback onClear;
  const _BaseLeadsChip({required this.onClear});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: AppDimensions.paddingHorizontalLarge(
        context,
      ).add(AppDimensions.paddingVerticalMedium(context)),
      decoration: BoxDecoration(
        color: context.colorScheme.secondary.withValues(alpha: 0.1),
        borderRadius: AppDimensions.radiusLarge,
        border: Border.all(
          color: context.colorScheme.secondary.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.people_alt_rounded,
            color: context.colorScheme.secondary,
            size: 18,
          ),
          const AppSpacerHorizontal.regular(),
          Expanded(
            child: Text(
              'Leads Frios do Banco de Dados selecionados',
              style: context.textTheme.labelLarge?.copyWith(
                color: context.colorScheme.secondary,
              ),
            ),
          ),
          IconButton(
            icon: Icon(
              Icons.close_rounded,
              color: context.colorScheme.onSurfaceVariant,
              size: 16,
            ),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            onPressed: onClear,
          ),
        ],
      ),
    );
  }
}

class _InstanceDropdown extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final vm = context.watch<BroadcastViewModel>();

    return Container(
      height: 48,
      padding: AppDimensions.paddingHorizontalMediumLarge(context),
      decoration: BoxDecoration(
        color: context.colorScheme.surface,
        borderRadius: AppDimensions.radiusLarge,
        border: Border.all(color: context.colorScheme.outline, width: 1),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<InstanceModel>(
          value: vm.selectedInstance,
          hint: Text(
            'Selecione uma instância...',
            style: context.textTheme.bodyMedium?.copyWith(
              color: context.colorScheme.onSurfaceVariant,
            ),
          ),
          isExpanded: true,
          dropdownColor: context.colorScheme.surfaceContainer,
          icon: Icon(
            Icons.keyboard_arrow_down_rounded,
            color: context.colorScheme.onSurfaceVariant,
            size: 20,
          ),
          items: vm.instances
              .map(
                (i) => DropdownMenuItem(
                  value: i,
                  child: Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: i.isConnected
                              ? context.customColors.statusCold // success if connected? 
                              : context.colorScheme.error,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const AppSpacerHorizontal.regular(),
                      Text(
                        i.displayName,
                        style: context.textTheme.bodyMedium?.copyWith(
                          color: context.colorScheme.onSurface,
                        ),
                      ),
                    ],
                  ),
                ),
              )
              .toList(),
          onChanged: (v) => vm.selectInstance(v),
        ),
      ),
    );
  }
}

class _ReasonField extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final vm = context.read<BroadcastViewModel>();

    return TextField(
      maxLines: 4,
      style: context.textTheme.bodyMedium?.copyWith(
        color: context.colorScheme.onSurface,
      ),
      decoration: const InputDecoration(
        hintText:
            'Descreva o objetivo do contato. Ex: Avisar sobre o novo lote de Tirzepatida disponível para entrega imediata.',
        alignLabelWithHint: true,
      ),
      onChanged: vm.setReason,
    );
  }
}

class _StartButton extends StatefulWidget {
  @override
  State<_StartButton> createState() => _StartButtonState();
}

class _StartButtonState extends State<_StartButton> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<BroadcastViewModel>();
    final enabled = vm.canBroadcast;

    return MouseRegion(
      cursor: enabled ? SystemMouseCursors.click : SystemMouseCursors.forbidden,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: enabled
            ? () => vm.startBroadcast(
                () => AppToast.show(
                  context,
                  'Disparo concluído! ${vm.sentCount} mensagens enviadas.',
                ),
              )
            : null,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: double.infinity,
          padding: AppDimensions.paddingVerticalLarge(context),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            gradient: enabled ? context.customColors.primaryGradient : null,
            color: enabled ? null : context.colorScheme.surface,
            borderRadius: AppDimensions.radiusExtraLarge,
            border: enabled
                ? null
                : Border.all(color: context.colorScheme.outline, width: 1),
            boxShadow: enabled && _hovered
                ? [
                    BoxShadow(
                      color: context.colorScheme.primary.withValues(alpha: 0.4),
                      blurRadius: 24,
                      offset: const Offset(0, 8),
                    ),
                  ]
                : [],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Icon(
                vm.isBroadcasting
                    ? Icons.hourglass_empty_rounded
                    : Icons.send_rounded,
                size: 18,
                color: enabled ? Colors.white : context.colorScheme.onSurfaceVariant,
              ),
              const AppSpacerHorizontal.regular(),
              Text(
                vm.isBroadcasting
                    ? 'Disparando...'
                    : vm.isCompleted
                    ? 'Novo Disparo'
                    : 'Iniciar Disparo',
                style: context.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: enabled ? Colors.white : context.colorScheme.onSurfaceVariant,
                  letterSpacing: 0.2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
