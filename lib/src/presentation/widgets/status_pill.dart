import 'package:flutter/material.dart';

import '../../domain/entities/report.dart';
import '../theme/app_theme.dart';

/// Status pill widget showing report status with icon and color.
class StatusPill extends StatelessWidget {
  const StatusPill({super.key, required this.status});

  final ReportStatus status;

  @override
  Widget build(BuildContext context) {
    final style = switch (status) {
      ReportStatus.open => (
        'مفتوح',
        kPrimaryDark,
        const Color(0xFFE0F2F1),
        Icons.radio_button_checked_rounded,
      ),
      ReportStatus.matched => (
        'تطابق محتمل',
        const Color(0xFF9A5800),
        const Color(0xFFFFF3DB),
        Icons.auto_awesome_rounded,
      ),
      ReportStatus.claimed => (
        'تم المطالبة',
        const Color(0xFF684D00),
        const Color(0xFFFFF8D8),
        Icons.handshake_outlined,
      ),
      ReportStatus.verifying => (
        'قيد التحقق',
        const Color(0xFF684D00),
        const Color(0xFFFFF8D8),
        Icons.verified_user_outlined,
      ),
      ReportStatus.approved => (
        'تمت الموافقة',
        const Color(0xFF087D39),
        const Color(0xFFDDF5E6),
        Icons.check_circle_outline_rounded,
      ),
      ReportStatus.rejected => (
        'مرفوض',
        kError,
        const Color(0xFFFDE8E8),
        Icons.cancel_outlined,
      ),
      ReportStatus.review => (
        'قيد المراجعة',
        kWarning,
        const Color(0xFFFFF3DB),
        Icons.rate_review_outlined,
      ),
      ReportStatus.handoverPending => (
        'بانتظار التسليم',
        const Color(0xFF087D39),
        const Color(0xFFDDF5E6),
        Icons.local_shipping_outlined,
      ),
      ReportStatus.recovered => (
        'تم الاستلام',
        const Color(0xFF087D39),
        const Color(0xFFDDF5E6),
        Icons.handshake_outlined,
      ),
      ReportStatus.closed => (
        'مغلق',
        kTextSecondary,
        const Color(0xFFF2F4F7),
        Icons.lock_outline_rounded,
      ),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: style.$3,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(style.$4, size: 11, color: style.$2),
          const SizedBox(width: 4),
          Text(
            style.$1,
            style: TextStyle(
              color: style.$2,
              fontSize: 10,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}
