import 'package:flutter/material.dart';
import 'package:aisend/core/theme/context_extension.dart';

enum BlastStatus {
  pending,
  running,
  done,
  cancelled,
  error;

  static BlastStatus fromString(String s) => switch (s) {
        'pending' => pending,
        'running' => running,
        'done' => done,
        'cancelled' => cancelled,
        _ => error,
      };

  String get label => switch (this) {
        pending => 'Pendente',
        running => 'Executando',
        done => 'Concluído',
        cancelled => 'Cancelado',
        error => 'Erro',
      };
}

extension BlastStatusColor on BlastStatus {
  Color color(BuildContext context) => switch (this) {
        BlastStatus.pending => context.colorScheme.primary,
        BlastStatus.running => Colors.orange,
        BlastStatus.done => Colors.green,
        BlastStatus.cancelled => context.colorScheme.onSurfaceVariant,
        BlastStatus.error => context.colorScheme.error,
      };
}
