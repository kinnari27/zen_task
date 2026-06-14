import 'package:flutter/material.dart';
import '../models/focus_session.dart';

class FocusStatsBar extends StatelessWidget {
  final List<FocusSession> sessions;

  const FocusStatsBar({
    super.key,
    required this.sessions,
  });

  Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'mind':
        return const Color(0xFF6366F1); // Indigo
      case 'work':
        return const Color(0xFF00F5D4); // Mint
      case 'health':
        return const Color(0xFFF72585); // Pink
      case 'personal':
      default:
        return const Color(0xFF4EA8DE); // Soft Blue
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Calculate total minutes focused today
    int totalSeconds = 0;
    final Map<String, int> categorySeconds = {
      'Mind': 0,
      'Work': 0,
      'Health': 0,
      'Personal': 0,
    };

    for (var session in sessions) {
      totalSeconds += session.durationSeconds;
      final cat = session.category;
      if (categorySeconds.containsKey(cat)) {
        categorySeconds[cat] = categorySeconds[cat]! + session.durationSeconds;
      } else {
        categorySeconds[cat] = session.durationSeconds;
      }
    }

    final int totalMinutes = (totalSeconds / 60).round();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: theme.colorScheme.primary.withValues(alpha: 0.1),
          width: 1.2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Focus Balance',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              Text(
                '${totalMinutes}m focused',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.secondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Horizontal Segmented Progress Bar
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: SizedBox(
              height: 12,
              child: Row(
                children: [
                  if (totalSeconds == 0)
                    Expanded(
                      child: Container(color: Colors.white10),
                    )
                  else
                    ...categorySeconds.entries.map((entry) {
                      final seconds = entry.value;
                      if (seconds == 0) return const SizedBox.shrink();
                      final int pct = (seconds / totalSeconds * 100).round();
                      if (pct <= 0) return const SizedBox.shrink();
                      return Expanded(
                        flex: pct,
                        child: Container(
                          color: _getCategoryColor(entry.key),
                        ),
                      );
                    }),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          // Category Indicators List
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: categorySeconds.entries.map((entry) {
              final String cat = entry.key;
              final int mins = (entry.value / 60).round();
              final double pct = totalSeconds == 0 ? 0.0 : (entry.value / totalSeconds);
              final color = _getCategoryColor(cat);

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        cat,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.white60,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${mins}m (${(pct * 100).toInt()}%)',
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
