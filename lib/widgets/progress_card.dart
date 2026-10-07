import 'package:flutter/material.dart';

class ProgressCard extends StatelessWidget {
  final int completed;
  final int total;
  const ProgressCard({super.key, required this.completed, required this.total});

  @override
  Widget build(BuildContext context) {
    final double progress = total == 0 ? 0.0 : completed / total;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${(progress * 100).round()}% הושלם', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 10),
            LinearProgressIndicator(value: progress, minHeight: 10, borderRadius: BorderRadius.circular(8)),
            const SizedBox(height: 8),
            Text('$completed מתוך $total פרקים'),
          ],
        ),
      ),
    );
  }
}