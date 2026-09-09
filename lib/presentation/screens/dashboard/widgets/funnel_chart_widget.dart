import 'package:flutter/material.dart';

class FunnelStage {
  final String label;
  final int value;
  final Color color;

  FunnelStage(this.label, this.value, this.color);
}

class FunnelChartWidget extends StatelessWidget {
  final List<FunnelStage> stages;

  const FunnelChartWidget({super.key, required this.stages});

  @override
  Widget build(BuildContext context) {
    if (stages.isEmpty) return const SizedBox();

    final maxValue = stages.first.value;
    if (maxValue == 0) {
      return const Center(
        child: Text('Noch nicht genügend Daten für den Funnel.'),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final maxWidth = constraints.maxWidth > 600
            ? 500.0
            : constraints.maxWidth * 0.9;

        return Column(
          children: stages.asMap().entries.map((entry) {
            final index = entry.key;
            final stage = entry.value;

            double percentage = stage.value / maxValue;
            if (percentage < 0.25 && stage.value > 0) percentage = 0.25;
            if (stage.value == 0) percentage = 0.0;

            final width = maxWidth * percentage;

            final prevValue = index > 0 ? stages[index - 1].value : null;
            final conversionRate = (prevValue != null && prevValue > 0)
                ? (stage.value / prevValue * 100).toStringAsFixed(1)
                : null;

            return Column(
              children: [
                if (index > 0)
                  Container(
                    height: 20,
                    width: 2,
                    color: Theme.of(context).colorScheme.outlineVariant,
                  ),
                if (index > 0 && conversionRate != null)
                  Transform.translate(
                    offset: const Offset(0, -10),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: Theme.of(context)
                            .colorScheme
                            .surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Theme.of(context).colorScheme.outlineVariant,
                        ),
                      ),
                      child: Text(
                        '$conversionRate%',
                        style: TextStyle(
                          fontSize: 11,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                if (index > 0 && conversionRate != null)
                  Transform.translate(
                    offset: const Offset(0, -10),
                    child: Container(
                      height: 10,
                      width: 2,
                      color: Theme.of(context).colorScheme.outlineVariant,
                    ),
                  ),

                AnimatedContainer(
                  duration: const Duration(milliseconds: 600),
                  curve: Curves.easeOutCubic,
                  width: width > 0 ? width : 120,
                  height: 48,
                  decoration: BoxDecoration(
                    color: width > 0
                        ? stage.color
                        : Colors.grey.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: width > 0
                        ? [
                            BoxShadow(
                              color: stage.color.withValues(alpha: 0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ]
                        : [],
                  ),
                  alignment: Alignment.center,
                  child: width > 0
                      ? Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              '${stage.value}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Flexible(
                              child: Text(
                                stage.label,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w500,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        )
                      : Text(
                          '0 ${stage.label}',
                          style: TextStyle(
                            color: Theme.of(context)
                                .colorScheme
                                .onSurfaceVariant,
                          ),
                        ),
                ),
              ],
            );
          }).toList(),
        );
      },
    );
  }
}
