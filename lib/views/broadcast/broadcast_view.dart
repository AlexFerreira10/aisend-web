import 'package:aisend/core/constants/app_dimensions.dart';
import 'package:aisend/core/constants/app_spacer.dart';
import 'package:aisend/core/theme/context_extension.dart';
import 'package:aisend/view_models/broadcast_view_model.dart';
import 'package:aisend/widgets/aisend_scaffold.dart';
import 'package:aisend/widgets/section_card.dart';
import 'package:aisend/core/utils/app_toast.dart'; // Added
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'widgets/upload_zone.dart';
import 'widgets/sidebar_benefits.dart';
import 'widgets/pull_leads_button.dart';
import 'widgets/base_leads_chip.dart';
import 'widgets/instance_dropdown.dart';
import 'widgets/message_mode_toggle.dart';
import 'widgets/message_input_field.dart';
import 'widgets/send_mode_section.dart';
import 'widgets/preview_card.dart';
import 'widgets/action_button.dart';

class BroadcastView extends StatelessWidget {
  const BroadcastView({super.key});

  @override
  Widget build(BuildContext context) => AiSendScaffold(
    currentRoute: '/broadcast',
    body: SingleChildScrollView(
      child: Padding(
        padding: AppDimensions.extraLarge(context).isFinite
            ? AppDimensions.paddingExtraLarge(context)
            : AppDimensions.paddingLarge(context),
        child: context.isDesktop
            ? const _DesktopLayout()
            : const _MobileLayout(),
      ),
    ),
  );
}

class _DesktopLayout extends StatelessWidget {
  const _DesktopLayout();

  @override
  Widget build(BuildContext context) => const Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: <Widget>[
      Expanded(flex: 65, child: _MainContent()),
      AppSpacerHorizontal.large(),
      SizedBox(width: 320, child: SidebarBenefits()),
    ],
  );
}

class _MobileLayout extends StatelessWidget {
  const _MobileLayout();

  @override
  Widget build(BuildContext context) => const Column(
    children: <Widget>[
      _MainContent(),
      AppSpacerVertical.large(),
      SidebarBenefits(),
    ],
  );
}

class _MainContent extends StatelessWidget {
  const _MainContent();

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<BroadcastViewModel>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        SectionCard(
          number: '1',
          title: 'Entrada de Dados',
          child: _DataEntrySection(vm: vm),
        ),
        const AppSpacerVertical.large(),
        SectionCard(
          number: '2',
          title: 'Configuração do Disparo',
          child: _ConfigSection(),
        ),
        const AppSpacerVertical.large(),
        SectionCard(
          number: '3',
          title: 'Envio',
          child: const SendModeSection(),
        ),
        if (vm.previewError != null) ...[
          const AppSpacerVertical.regular(),
          _ParseWarning(message: vm.previewError!),
        ],
        if (vm.hasPreview && !vm.isBroadcasting && !vm.isCompleted) ...[
          const AppSpacerVertical.large(),
          PreviewCard(
            parts: vm.previewParts,
            onReset: vm.resetPreview,
            onPartChanged: vm.updatePreviewPart,
          ),
        ],
        if (vm.broadcastError != null) ...[
          const AppSpacerVertical.regular(),
          _ParseWarning(message: vm.broadcastError!),
        ],
        const AppSpacerVertical.large(),
        const ActionButton(),
      ],
    );
  }
}

class _DataEntrySection extends StatelessWidget {
  final BroadcastViewModel vm;

  const _DataEntrySection({required this.vm});

  @override
  Widget build(BuildContext context) => Column(
    children: <Widget>[
      UploadZone(
        uploadedFileName: vm.uploadedFileName,
        leadCount: vm.dynamicLeadsCount > 0 ? vm.dynamicLeadsCount : null,
        onUpload: () =>
            vm.pickAndParseFile(onError: (err) => AppToast.show(context, err)),
        onClear: vm.clearUpload,
      ),
      if (vm.parseWarnings != null) ...[
        const AppSpacerVertical.regular(),
        _ParseWarning(message: vm.parseWarnings!),
      ],
      if (vm.uploadedFileName == null && !vm.leadsFromBase) ...[
        const AppSpacerVertical.medium(),
        _OrDivider(),
        const AppSpacerVertical.medium(),
        const PullLeadsButton(),
        if (vm.pullLeadsError != null) ...[
          const AppSpacerVertical.regular(),
          _ParseWarning(message: vm.pullLeadsError!),
        ],
      ],
      if (vm.leadsFromBase) ...[
        const AppSpacerVertical.medium(),
        BaseLeadsChip(onClear: vm.clearUpload),
      ],
    ],
  );
}

class _ParseWarning extends StatelessWidget {
  final String message;

  const _ParseWarning({required this.message});

  @override
  Widget build(BuildContext context) => Row(
    children: <Widget>[
      Icon(
        Icons.warning_amber_rounded,
        size: 14,
        color: context.colorScheme.error.withValues(alpha: 0.8),
      ),
      const AppSpacerHorizontal.tiny(),
      Expanded(
        child: Text(
          message,
          style: context.textTheme.bodySmall?.copyWith(
            color: context.colorScheme.error.withValues(alpha: 0.8),
          ),
        ),
      ),
    ],
  );
}

class _OrDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Row(
    children: <Widget>[
      const Expanded(child: Divider()),
      Padding(
        padding: AppDimensions.paddingHorizontalMedium(context),
        child: Text('ou', style: context.textTheme.bodySmall),
      ),
      const Expanded(child: Divider()),
    ],
  );
}

class _ConfigSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: <Widget>[
      Text(
        'Selecionar consultor',
        style: context.textTheme.titleLarge?.copyWith(
          color: context.colorScheme.onSurfaceVariant,
        ),
      ),
      const AppSpacerVertical.regular(),
      const InstanceDropdown(),
      const AppSpacerVertical.large(),
      const MessageModeToggle(),
      const AppSpacerVertical.large(),
      const MessageInputField(),
    ],
  );
}
