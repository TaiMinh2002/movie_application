import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../error/errors.dart';
import '../extensions/context_ext.dart';

class AppErrorView extends StatelessWidget {
  const AppErrorView({super.key, required this.error, this.onRetry});

  final Object error;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final (icon, message) = switch (error) {
      NetworkFailure() => (Symbols.wifi_off_rounded, l10n.errorNetwork),
      ServerFailure() => (Symbols.cloud_off_rounded, l10n.errorServer),
      _ => (Symbols.error_rounded, l10n.errorUnknown),
    };
    return _MessageView(
      icon: icon,
      message: message,
      action: onRetry == null
          ? null
          : FilledButton(onPressed: onRetry, child: Text(l10n.retry)),
    );
  }
}

class EmptyView extends StatelessWidget {
  const EmptyView({
    super.key,
    this.message,
    this.icon = Symbols.inbox_rounded,
    this.hint,
    this.actionLabel,
    this.onAction,
  });

  final String? message;
  final IconData icon;

  /// Secondary line under [message], in textMuted.
  final String? hint;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) => _MessageView(
    icon: icon,
    message: message ?? context.l10n.emptyDefault,
    hint: hint,
    action: actionLabel == null
        ? null
        : FilledButton(onPressed: onAction, child: Text(actionLabel!)),
  );
}

class _MessageView extends StatelessWidget {
  const _MessageView({
    required this.icon,
    required this.message,
    this.hint,
    this.action,
  });

  final IconData icon;
  final String message;
  final String? hint;
  final Widget? action;

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 64, weight: 300, color: context.colors.textMuted),
          const SizedBox(height: 12),
          Text(
            message,
            textAlign: TextAlign.center,
            style: context.textTheme.bodyLarge,
          ),
          if (hint != null) ...[
            const SizedBox(height: 4),
            Text(
              hint!,
              textAlign: TextAlign.center,
              style: context.textTheme.bodyMedium?.copyWith(
                color: context.colors.textMuted,
              ),
            ),
          ],
          if (action != null) ...[const SizedBox(height: 20), action!],
        ],
      ),
    ),
  );
}
