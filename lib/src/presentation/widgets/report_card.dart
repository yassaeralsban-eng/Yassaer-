import 'package:flutter/material.dart';

import '../../domain/entities/report.dart';
import '../theme/app_theme.dart';
import 'status_pill.dart';

/// Report card widget for lists.
class ReportCard extends StatelessWidget {
  const ReportCard({super.key, required this.report, required this.onTap});

  final Report report;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Material(
    color: Colors.white,
    borderRadius: BorderRadius.circular(19),
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(19),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          border: Border.all(color: kBorder),
          borderRadius: BorderRadius.circular(19),
        ),
        child: Row(
          children: [
            _ReportArt(report: report, size: 74),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      StatusPill(status: report.status),
                      const Spacer(),
                      Text(
                        _formatDate(report.eventDate),
                        style: const TextStyle(fontSize: 11, color: kTextMuted),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    report.title,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Row(
                    children: [
                      const Icon(
                        Icons.location_on_outlined,
                        size: 14,
                        color: kTextSecondary,
                      ),
                      const SizedBox(width: 3),
                      Expanded(
                        child: Text(
                          report.approximateLocation,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 12,
                            color: kTextSecondary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 4),
            const Icon(Icons.chevron_left_rounded, color: kTextMuted),
          ],
        ),
      ),
    ),
  );
}

class _ReportArt extends StatelessWidget {
  const _ReportArt({required this.report, this.size = 100});

  final Report report;
  final double size;

  @override
  Widget build(BuildContext context) => Container(
    width: size,
    height: size,
    decoration: BoxDecoration(
      color: _tintFor(report.categoryId),
      borderRadius: BorderRadius.circular(size * .26),
    ),
    child: Icon(
      _iconFor(report.categoryId),
      size: size * .43,
      color: _colorFor(report.categoryId),
    ),
  );
}

IconData _iconFor(String category) => switch (category) {
  'electronics' => Icons.phone_android_rounded,
  'documents' => Icons.account_balance_wallet_rounded,
  'keys' => Icons.key_rounded,
  'bags' => Icons.work_outline_rounded,
  _ => Icons.inventory_2_outlined,
};

Color _colorFor(String category) => switch (category) {
  'electronics' => const Color(0xFF374151),
  'documents' => const Color(0xFF8B5E3C),
  'keys' => const Color(0xFF667085),
  _ => kPrimaryDark,
};

Color _tintFor(String category) => switch (category) {
  'electronics' => const Color(0xFFE5E7EB),
  'documents' => const Color(0xFFF7E4D1),
  'keys' => const Color(0xFFE4E7EC),
  _ => const Color(0xFFE0F2F1),
};

String _formatDate(DateTime date) {
  final now = DateTime.now();
  final diff = now.difference(date);

  if (diff.inMinutes < 1) return 'الآن';
  if (diff.inHours < 1) return 'منذ ${diff.inMinutes} دقيقة';
  if (diff.inDays < 1) return 'منذ ${diff.inHours} ساعة';
  if (diff.inDays < 7) return 'منذ ${diff.inDays} يوم';
  return '${date.day}/${date.month}/${date.year}';
}
