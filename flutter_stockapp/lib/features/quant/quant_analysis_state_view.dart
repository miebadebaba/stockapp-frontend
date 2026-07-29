import 'package:flutter/material.dart';

import 'quant_analysis_status.dart';

class QuantAnalysisStateView extends StatelessWidget {
  const QuantAnalysisStateView({required this.status, this.onRetry, super.key});

  final QuantAnalysisStatus status;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    switch (status) {
      case QuantAnalysisStatus.loading:
        return const _LoadingView();

      case QuantAnalysisStatus.empty:
        return const _MessageView(
          icon: Icons.inbox_outlined,
          title: '暂无可分析数据',
          message: '当前股票的历史数据不足，请稍后重试或选择其他股票。',
        );

      case QuantAnalysisStatus.failure:
        return _MessageView(
          icon: Icons.error_outline,
          title: '分析失败',
          message: '数据暂时无法获取，请检查网络后重试。',
          onRetry: onRetry,
        );

      case QuantAnalysisStatus.idle:
      case QuantAnalysisStatus.success:
        return const SizedBox.shrink();
    }
  }
}

class _LoadingView extends StatelessWidget {
  const _LoadingView();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 40),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 28,
              height: 28,
              child: CircularProgressIndicator(strokeWidth: 3),
            ),
            SizedBox(height: 16),
            Text('正在获取行情并计算技术指标...'),
          ],
        ),
      ),
    );
  }
}

class _MessageView extends StatelessWidget {
  const _MessageView({
    required this.icon,
    required this.title,
    required this.message,
    this.onRetry,
  });

  final IconData icon;
  final String title;
  final String message;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 40, color: colorScheme.onSurfaceVariant),
            const SizedBox(height: 12),
            Text(
              title,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 20),
              FilledButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: const Text('重新尝试'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
