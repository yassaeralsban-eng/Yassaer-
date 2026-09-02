import 'package:flutter/material.dart';

import '../../domain/entities/report.dart';
import '../theme/app_theme.dart';
import '../widgets/status_pill.dart';

/// Report details screen (UX/UI spec - Screen 4).
class ReportDetailsScreen extends StatelessWidget {
  const ReportDetailsScreen({super.key, required this.report});

  final Report report;

  @override
  Widget build(BuildContext context) {
    final matched = report.status == ReportStatus.matched;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'تفاصيل البلاغ',
            style: TextStyle(fontWeight: FontWeight.w900),
          ),
          actions: [
            IconButton(
              onPressed: () => _reportDialog(context),
              tooltip: 'إبلاغ',
              icon: const Icon(Icons.flag_outlined),
            ),
          ],
        ),
        body: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 30),
          children: [
            Container(
              height: 200,
              decoration: BoxDecoration(
                color: _tintFor(report.categoryId),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Stack(
                children: [
                  Center(
                    child: Icon(
                      _iconFor(report.categoryId),
                      color: _colorFor(report.categoryId),
                      size: 84,
                    ),
                  ),
                  Positioned(
                    right: 14,
                    top: 14,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: .86),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        report.reportType == ReportType.lost
                            ? 'بلاغ مفقود'
                            : 'بلاغ معثور عليه',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            Row(
              children: [
                StatusPill(status: report.status),
                const Spacer(),
                Text(
                  'رقم البلاغ: ${report.id}',
                  style: const TextStyle(color: kTextMuted, fontSize: 12),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Text(
              report.title,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 10),
            Text(
              report.description,
              style: const TextStyle(
                fontSize: 14,
                height: 1.65,
                color: Color(0xFF475467),
              ),
            ),
            const SizedBox(height: 20),
            _InfoRow(
              icon: Icons.category_outlined,
              title: 'التصنيف',
              value: _categoryLabel(report.categoryId),
            ),
            _InfoRow(
              icon: Icons.location_on_outlined,
              title: 'الموقع التقريبي',
              value: report.approximateLocation,
            ),
            _InfoRow(
              icon: Icons.event_outlined,
              title: report.reportType == ReportType.lost
                  ? 'تاريخ الفقد'
                  : 'تاريخ العثور',
              value:
                  '${report.eventDate.day}/${report.eventDate.month}/${report.eventDate.year}',
            ),
            const SizedBox(height: 16),
            const _PrivacyNote(),
            if (matched) ...[
              const SizedBox(height: 18),
              const _MatchExplanation(),
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const _VerificationScreen(),
                  ),
                ),
                icon: const Icon(Icons.verified_user_outlined),
                label: const Text('بدء طلب الاستعادة'),
              ),
              const SizedBox(height: 8),
              const Text(
                'سيُطلب منك إثبات معلومات لا تظهر للعامة.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12, color: kTextSecondary),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _reportDialog(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        padding: const EdgeInsets.fromLTRB(20, 14, 20, 26),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 42,
                  height: 4,
                  decoration: BoxDecoration(
                    color: kBorder,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'الإبلاغ عن هذا البلاغ',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 12),
              ...['معلومات مضللة', 'ادعاء ملكية مشبوه', 'محتوى غير مناسب'].map(
                (reason) => ListTile(
                  leading: const Icon(Icons.flag_outlined),
                  title: Text(reason),
                  onTap: () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('شكرًا، تم إرسال البلاغ للمراجعة.'),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.title,
    required this.value,
  });

  final IconData icon;
  final String title;
  final String value;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 9),
    child: Row(
      children: [
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: const Color(0xFFF2F7F7),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, size: 20, color: kPrimaryDark),
        ),
        const SizedBox(width: 11),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 11, color: kTextSecondary),
            ),
            const SizedBox(height: 2),
            Text(value, style: const TextStyle(fontWeight: FontWeight.w800)),
          ],
        ),
      ],
    ),
  );
}

class _PrivacyNote extends StatelessWidget {
  const _PrivacyNote();

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(13),
    decoration: BoxDecoration(
      color: const Color(0xFFF1F8F7),
      border: Border.all(color: const Color(0xFFCAEAE5)),
      borderRadius: BorderRadius.circular(15),
    ),
    child: const Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(Icons.lock_outline_rounded, color: kPrimaryDark, size: 20),
        SizedBox(width: 9),
        Expanded(
          child: Text(
            'خصوصيتك محفوظة: لا تُعرض تفاصيل التحقق أو بيانات التواصل للعامة.',
            style: TextStyle(
              fontSize: 12,
              color: Color(0xFF315953),
              height: 1.5,
            ),
          ),
        ),
      ],
    ),
  );
}

class _MatchExplanation extends StatelessWidget {
  const _MatchExplanation();

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: const Color(0xFFFFF8EA),
      border: Border.all(color: const Color(0xFFF8DDA1)),
      borderRadius: BorderRadius.circular(18),
    ),
    child: const Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(Icons.auto_awesome_rounded, color: kWarning),
        SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'تطابق محتمل بنسبة ٨٧٪',
                style: TextStyle(fontWeight: FontWeight.w900),
              ),
              SizedBox(height: 5),
              Text(
                'التشابه في التصنيف والموقع والوقت يساعد في ترتيب النتيجة، لكنه لا يثبت الملكية.',
                style: TextStyle(
                  fontSize: 12,
                  color: Color(0xFF775C21),
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

class _VerificationScreen extends StatefulWidget {
  const _VerificationScreen();

  @override
  State<_VerificationScreen> createState() => _VerificationScreenState();
}

class _VerificationScreenState extends State<_VerificationScreen> {
  final _form = GlobalKey<FormState>();
  bool _sending = false;

  String? _required(String? value) =>
      value == null || value.trim().isEmpty ? 'هذا الحقل مطلوب' : null;

  void _send() async {
    if (!(_form.currentState?.validate() ?? false)) return;
    setState(() => _sending = true);
    await Future<void>.delayed(const Duration(milliseconds: 650));
    if (!mounted) return;
    setState(() => _sending = false);
    await showDialog<void>(
      context: context,
      builder: (_) => AlertDialog(
        icon: const Icon(
          Icons.mark_email_read_outlined,
          color: kPrimary,
          size: 34,
        ),
        title: const Text('أُرسل طلب التحقق'),
        content: const Text(
          'ستتم مراجعة إجاباتك دون مشاركتها مع أي طرف آخر. سنبلغك بالنتيجة.',
        ),
        actions: [
          FilledButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('حسنًا'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) => Directionality(
    textDirection: TextDirection.rtl,
    child: Scaffold(
      appBar: AppBar(
        title: const Text(
          'التحقق من الملكية',
          style: TextStyle(fontWeight: FontWeight.w900),
        ),
      ),
      body: SafeArea(
        child: Form(
          key: _form,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
            children: [
              Container(
                padding: const EdgeInsets.all(17),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF8EA),
                  border: Border.all(color: const Color(0xFFF8DDA1)),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.verified_user_outlined,
                      color: kWarning,
                      size: 28,
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'الطلب قيد التحقق',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          SizedBox(height: 5),
                          Text(
                            'التطابق المحتمل لا يثبت الملكية. إجاباتك الخاصة تساعدنا على المراجعة العادلة.',
                            style: TextStyle(
                              fontSize: 12,
                              color: Color(0xFF775C21),
                              height: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 23),
              const Text(
                'أجب بمعلومات يعرفها المالك فقط',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 14),
              TextFormField(
                validator: _required,
                decoration: const InputDecoration(
                  labelText: 'ما العلامة أو التفاصيل المميزة للغرض؟',
                  hintText: 'لن تظهر إجابتك للعامة',
                ),
              ),
              const SizedBox(height: 14),
              TextFormField(
                validator: _required,
                decoration: const InputDecoration(
                  labelText: 'أين تعتقد أنك فقدته تقريبًا؟',
                ),
              ),
              const SizedBox(height: 14),
              TextFormField(
                validator: _required,
                decoration: const InputDecoration(
                  labelText: 'اذكر تفاصيل إضافية تساعد على التحقق',
                ),
              ),
              const SizedBox(height: 20),
              const _PrivacyNote(),
              const SizedBox(height: 20),
              FilledButton(
                onPressed: _sending ? null : _send,
                child: _sending
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Text('إرسال للتحقق'),
              ),
              const SizedBox(height: 9),
              const Text(
                'قد تتحول بعض الحالات إلى مراجعة بشرية لحماية الجميع.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12, color: kTextSecondary),
              ),
            ],
          ),
        ),
      ),
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

String _categoryLabel(String id) => switch (id) {
  'electronics' => 'إلكترونيات',
  'documents' => 'وثائق',
  'keys' => 'مفاتيح',
  'bags' => 'حقائب',
  _ => 'أخرى',
};
