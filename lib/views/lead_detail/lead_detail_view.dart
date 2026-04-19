import 'package:aisend/core/constants/app_dimensions.dart';
import 'package:aisend/core/constants/app_spacer.dart';
import 'package:aisend/core/theme/context_extension.dart';
import 'package:aisend/core/theme/custom_colors_extension.dart';
import 'package:aisend/core/utils/app_toast.dart';
import 'package:aisend/data/services/leads_service.dart';
import 'package:aisend/models/lead_model.dart';
import 'package:aisend/models/message_model.dart';
import 'package:aisend/view_models/lead_detail_view_model.dart';
import 'package:aisend/views/dashboard/widgets/status_badge.dart';
import 'package:aisend/widgets/aisend_app_bar.dart';
import 'package:aisend/widgets/aisend_drawer.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class LeadDetailView extends StatelessWidget {
  final LeadModel lead;

  const LeadDetailView({super.key, required this.lead});

  @override
  Widget build(BuildContext context) => ChangeNotifierProvider(
    create: (ctx) =>
        LeadDetailViewModel(leadsService: ctx.read<LeadsService>(), lead: lead),
    child: _LeadDetailContent(lead: lead),
  );
}

class _LeadDetailContent extends StatefulWidget {
  final LeadModel lead;
  const _LeadDetailContent({required this.lead});

  @override
  State<_LeadDetailContent> createState() => _LeadDetailContentState();
}

class _LeadDetailContentState extends State<_LeadDetailContent> {
  late final LeadDetailViewModel _vm;

  @override
  void initState() {
    super.initState();
    _vm = context.read<LeadDetailViewModel>();
    _vm.addListener(_onVmChanged);
  }

  @override
  void dispose() {
    _vm.removeListener(_onVmChanged);
    super.dispose();
  }

  void _onVmChanged() {
    final error = _vm.toggleError;
    if (error != null && mounted) {
      AppToast.show(context, error, type: ToastType.error);
    }
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<LeadDetailViewModel>();

    return Scaffold(
      appBar: const AiSendAppBar(currentRoute: '/'),
      drawer: const AiSendDrawer(currentRoute: '/'),
      body: Column(
        children: <Widget>[
          _LeadHeader(lead: widget.lead, vm: vm),
          Divider(height: 1, color: context.colorScheme.outline),
          Expanded(
            child: vm.isLoading
                ? const Center(child: CircularProgressIndicator())
                : vm.hasError
                ? _ErrorState(onRetry: vm.loadMessages)
                : vm.messages.isEmpty
                ? Center(
                    child: Text(
                      'Nenhuma mensagem ainda',
                      style: context.textTheme.bodyLarge?.copyWith(
                        color: context.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  )
                : _MessageList(messages: vm.messages),
          ),
        ],
      ),
    );
  }
}

class _LeadHeader extends StatelessWidget {
  final LeadModel lead;
  final LeadDetailViewModel vm;

  const _LeadHeader({required this.lead, required this.vm});

  @override
  Widget build(BuildContext context) {
    final isMobile = context.isMobile;

    return Container(
      padding: AppDimensions.paddingLarge(context),
      color: context.colorScheme.surfaceContainer,
      child: Column(
        children: <Widget>[
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              IconButton(
                icon: const Icon(Icons.arrow_back_rounded),
                onPressed: () => Navigator.pop(context),
              ),
              const AppSpacerHorizontal.medium(),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Text(
                          lead.name,
                          style: context.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        StatusBadge(status: lead.status),
                        if (vm.waitingHuman) _WaitingBadge(),
                      ],
                    ),
                    const AppSpacerVertical.tiny(),
                    Text(lead.phone, style: context.textTheme.bodySmall),
                  ],
                ),
              ),
              if (!isMobile) ...[
                const AppSpacerHorizontal.medium(),
                _ActionButton(vm: vm),
              ],
            ],
          ),
          if (isMobile) ...[
            const AppSpacerVertical.medium(),
            SizedBox(
              width: double.infinity,
              child: _ActionButton(vm: vm),
            ),
          ],
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final LeadDetailViewModel vm;
  const _ActionButton({required this.vm});

  @override
  Widget build(BuildContext context) {
    if (vm.updatingWaiting) {
      return const Center(
        child: SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      );
    }

    return OutlinedButton.icon(
      onPressed: vm.toggleWaitingHuman,
      icon: Icon(
        vm.waitingHuman ? Icons.smart_toy_rounded : Icons.person_rounded,
        size: 16,
      ),
      label: Text(vm.waitingHuman ? 'Devolver ao Bot' : 'Assumir Atendimento'),
      style: OutlinedButton.styleFrom(
        foregroundColor: vm.waitingHuman
            ? context.customColors.success
            : context.colorScheme.primary,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    );
  }
}

class _WaitingBadge extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
    decoration: BoxDecoration(
      color: context.colorScheme.error.withValues(alpha: 0.1),
      borderRadius: BorderRadius.circular(20),
      border: Border.all(
        color: context.colorScheme.error.withValues(alpha: 0.3),
      ),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Icon(Icons.person_rounded, size: 14, color: context.colorScheme.error),
        const SizedBox(width: 4),
        Text(
          'Aguardando humano',
          style: context.textTheme.labelSmall?.copyWith(
            color: context.colorScheme.error,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    ),
  );
}

class _ErrorState extends StatelessWidget {
  final VoidCallback onRetry;
  const _ErrorState({required this.onRetry});

  @override
  Widget build(BuildContext context) => Center(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Icon(
          Icons.error_outline,
          size: 48,
          color: context.colorScheme.onSurfaceVariant,
        ),
        const AppSpacerVertical.medium(),
        Text('Erro ao carregar mensagens', style: context.textTheme.bodyLarge),
        const AppSpacerVertical.regular(),
        TextButton(onPressed: onRetry, child: const Text('Tentar novamente')),
      ],
    ),
  );
}

class _MessageList extends StatelessWidget {
  final List<MessageModel> messages;
  const _MessageList({required this.messages});

  @override
  Widget build(BuildContext context) => ListView.builder(
    padding: AppDimensions.paddingExtraLarge(context),
    itemCount: messages.length,
    itemBuilder: (context, i) => _MessageBubble(message: messages[i]),
  );
}

class _MessageBubble extends StatelessWidget {
  final MessageModel message;
  const _MessageBubble({required this.message});

  @override
  Widget build(BuildContext context) {
    final isUser = message.isFromUser;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: isUser
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isUser) ...[
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                gradient: context.customColors.primaryGradient,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.bolt_rounded,
                color: Colors.white,
                size: 18,
              ),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              constraints: BoxConstraints(
                maxWidth: MediaQuery.sizeOf(context).width * 0.6,
              ),
              decoration: BoxDecoration(
                color: isUser
                    ? context.colorScheme.primary
                    : context.colorScheme.surfaceContainer,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(16),
                  topRight: const Radius.circular(16),
                  bottomLeft: Radius.circular(isUser ? 16 : 4),
                  bottomRight: Radius.circular(isUser ? 4 : 16),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    message.content,
                    style: context.textTheme.bodyMedium?.copyWith(
                      color: isUser
                          ? Colors.white
                          : context.colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _formatTime(message.createdAt),
                    style: context.textTheme.labelSmall?.copyWith(
                      color: isUser
                          ? Colors.white.withValues(alpha: 0.7)
                          : context.colorScheme.onSurfaceVariant,
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (isUser) const SizedBox(width: 8),
        ],
      ),
    );
  }

  String _formatTime(DateTime dt) {
    final local = dt.toLocal();
    return '${local.hour.toString().padLeft(2, '0')}:${local.minute.toString().padLeft(2, '0')}';
  }
}
