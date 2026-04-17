import 'package:aisend/core/theme/context_extension.dart';
import 'package:flutter/material.dart';

class PullLeadsButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final bool loading;
  const PullLeadsButton({super.key, this.onPressed, this.loading = false});

  @override
  Widget build(BuildContext context) => SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: loading ? null : onPressed,
        icon: loading
            ? SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    context.colorScheme.onPrimary,
                  ),
                ),
              )
            : const Icon(Icons.download_rounded),
        label: loading
            ? const Text('Carregando...')
            : const Text('Puxar Leads Frios do Banco de Dados'),
      ),
    );
}
