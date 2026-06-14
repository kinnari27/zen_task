import 'package:flutter/material.dart';

class ProgressCard extends StatelessWidget {
  final int completedCount;
  final int totalCount;

  const ProgressCard({
    super.key,
    required this.completedCount,
    required this.totalCount,
  });

  @override
  Widget build(BuildContext context) {
    final double progress = totalCount == 0 ? 0.0 : completedCount / totalCount;
    final int percentage = (progress * 100).toInt();
    
    // Theme references
    final theme = Theme.of(context);

    // Dynamic quote selection based on completion progress
    String quote;
    String subQuote;
    if (totalCount == 0) {
      quote = 'Your canvas is empty';
      subQuote = 'Add a mindful task to begin your day.';
    } else if (progress == 0.0) {
      quote = 'Ready to begin?';
      subQuote = 'A single mindful step changes everything.';
    } else if (progress < 0.5) {
      quote = 'Finding your rhythm';
      subQuote = 'One task at a time. Keep breathing.';
    } else if (progress < 1.0) {
      quote = 'Over halfway there!';
      subQuote = 'Your focus is yielding beautiful results.';
    } else {
      quote = 'Complete harmony 🧘';
      subQuote = 'All tasks completed. Take a moment to rest.';
    }

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            theme.colorScheme.primary.withValues(alpha: 0.15),
            theme.colorScheme.secondary.withValues(alpha: 0.08),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: theme.colorScheme.primary.withValues(alpha: 0.2),
          width: 1.5,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    quote,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    subQuote,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.white.withValues(alpha: 0.7),
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '$completedCount of $totalCount tasks done',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.secondary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 80,
                  height: 80,
                  child: CircularProgressIndicator(
                    value: progress,
                    backgroundColor: Colors.white.withValues(alpha: 0.05),
                    color: theme.colorScheme.secondary,
                    strokeWidth: 8,
                    strokeCap: StrokeCap.round,
                  ),
                ),
                Text(
                  '$percentage%',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
