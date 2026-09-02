import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../application/providers.dart';
import '../../domain/entities/report.dart';
import '../../domain/entities/private_verification.dart';
import '../theme/app_theme.dart';

/// Report creation form (UX/UI spec - Screen 2).
class ReportFormScreen extends ConsumerStatefulWidget {
  const ReportFormScreen({super.key, required this.type});

  final ReportType type;

  @override
  ConsumerState<ReportFormScreen> createState() => _ReportFormScreenState();
}

class _ReportFormScreenState extends ConsumerState<ReportFormScreen> {
  final _form = GlobalKey<FormState>();
  final _title = TextEditingController();
  final _description = TextEditingController();
  final _secretAttribute = TextEditingController();
  final _verificationQuestion = TextEditingController();
  final _verificationAnswer = TextEditingController();

  int _step = 0;
  String _category = 'electronics';
  String _location = 'السوق القديم، عتق';
  DateTime _date = DateTime.now();
  bool _saving = false;

  @override
  void dispose() {
    _title.dispose();
    _description.dispose();
    _secretAttribute.dispose();
    _verificationQuestion.dispose();
    _verificationAnswer.dispose();
    super.dispose();
  }

  void _next() {
    if (_step == 1 && !(_form.currentState?.validate() ?? false)) return;
    if (_step < 2) {
      setState(() => _step++);
    } else {
      _publish();
    }
  }

  Future<void> _publish() async {
    // The Form only lives on step 1; validation was already performed when
    // navigating from step 1 to step 2, so we don't re-validate here.
    setState(() => _saving = true);

    final user = ref.read(currentUserProvider);
    if (user == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('يجب تسجيل الدخول لإنشاء بلاغ'),
            backgroundColor: kError,
          ),
        );
      }
      setState(() => _saving = false);
      return;
    }

    final now = DateTime.now();
    final report = Report(
      id: '${widget.type == ReportType.lost ? 'L' : 'F'}-${now.millisecondsSinceEpoch}',
      ownerId: user.id,
      reportType: widget.type,
      categoryId: _category,
      title: _title.text.trim(),
      description: _description.text.trim(),
      approximateLocation: _location,
      eventDate: _date,
      status: ReportStatus.open,
      createdAt: now,
      updatedAt: now,
    );

    final privateVerification = PrivateVerification(
      reportId: report.id,
      secretAttributes: {
        if (_secretAttribute.text.trim().isNotEmpty)
          'secret': _secretAttribute.text.trim(),
      },
      verificationQuestions: [
        if (_verificationQuestion.text.trim().isNotEmpty)
          _verificationQuestion.text.trim(),
      ],
      verificationAnswers: [
        if (_verificationAnswer.text.trim().isNotEmpty)
          _verificationAnswer.text.trim(),
      ],
      createdAt: now,
    );

    try {
      await ref
          .read(createReportProvider)
          .call(report: report, privateVerification: privateVerification);
      if (mounted) {
        Navigator.pop(context, report);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('فشل نشر البلاغ: $e'),
            backgroundColor: kError,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final lost = widget.type == ReportType.lost;
    final labels = [
      'التصنيف',
      lost ? 'معلومات الغرض' : 'تفاصيل العثور',
      'الموقع والتاريخ',
    ];

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            lost ? 'بلاغ مفقود جديد' : 'بلاغ معثور عليه',
            style: const TextStyle(fontWeight: FontWeight.w900),
          ),
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _FormProgress(step: _step, label: labels[_step]),
                const SizedBox(height: 26),
                Expanded(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 220),
                    child: _content(lost),
                  ),
                ),
                Row(
                  children: [
                    if (_step > 0)
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => setState(() => _step--),
                          child: const Text('السابق'),
                        ),
                      ),
                    if (_step > 0) const SizedBox(width: 10),
                    Expanded(
                      child: FilledButton(
                        onPressed: _saving ? null : _next,
                        child: _saving
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : Text(_step == 2 ? 'نشر البلاغ' : 'متابعة'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _content(bool lost) => switch (_step) {
    0 => _CategoryStep(
      selected: _category,
      onSelected: (value) => setState(() => _category = value),
    ),
    1 => Form(
      key: _form,
      child: SingleChildScrollView(
        key: const ValueKey('details'),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              lost ? 'صف الغرض المفقود' : 'صف الغرض الذي عثرت عليه',
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 7),
            const Text(
              'أضف معلومات عامة فقط، وتجنب كتابة علامات الملكية الخاصة.',
              style: TextStyle(color: kTextSecondary, height: 1.5),
            ),
            const SizedBox(height: 24),
            TextFormField(
              controller: _title,
              validator: (v) => v == null || v.trim().length < 3
                  ? 'اكتب اسمًا واضحًا للغرض'
                  : null,
              decoration: const InputDecoration(
                labelText: 'اسم الغرض',
                hintText: 'مثال: هاتف سامسونج أسود',
              ),
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _description,
              minLines: 4,
              maxLines: 5,
              validator: (v) => v == null || v.trim().length < 10
                  ? 'الوصف يجب ألا يقل عن 10 أحرف'
                  : null,
              decoration: const InputDecoration(
                labelText: 'وصف عام',
                hintText: 'اللون، الحالة، وأي وصف لا يكشف بيانات خاصة',
              ),
            ),
            const SizedBox(height: 15),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFF7F9FA),
                borderRadius: BorderRadius.circular(15),
              ),
              child: const Row(
                children: [
                  Icon(Icons.add_photo_alternate_outlined, color: kPrimaryDark),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'إضافة صورة (اختياري في هذه النسخة)',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  Icon(Icons.chevron_left_rounded),
                ],
              ),
            ),
            const SizedBox(height: 20),
            const _PrivacyNote(),
            const SizedBox(height: 20),
            const Text(
              'بيانات التحقق السرية (لن تظهر للعامة)',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 6),
            const Text(
              'هذه المعلومات تساعد في إثبات الملكية عند طلب الاستعادة.',
              style: TextStyle(fontSize: 12, color: kTextSecondary),
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _secretAttribute,
              decoration: const InputDecoration(
                labelText: 'علامة مميزة (سرية)',
                hintText: 'مثال: رقم تسلسلي، خدش محدد',
              ),
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _verificationQuestion,
              decoration: const InputDecoration(
                labelText: 'سؤال تحقق',
                hintText: 'مثال: ما الرقم المطبوع على الغرض؟',
              ),
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _verificationAnswer,
              decoration: const InputDecoration(
                labelText: 'إجابة التحقق',
                hintText: 'لن تظهر هذه الإجابة للعامة',
              ),
            ),
          ],
        ),
      ),
    ),
    _ => _LocationStep(
      location: _location,
      date: _date,
      onLocation: (value) => setState(() => _location = value),
      onDate: (value) => setState(() => _date = value),
    ),
  };
}

class _FormProgress extends StatelessWidget {
  const _FormProgress({required this.step, required this.label});

  final int step;
  final String label;

  @override
  Widget build(BuildContext context) => Column(
    children: [
      Row(
        children: List.generate(
          3,
          (index) => Expanded(
            child: Container(
              margin: EdgeInsets.only(left: index == 2 ? 0 : 6),
              height: 5,
              decoration: BoxDecoration(
                color: index <= step ? kPrimary : kBorder,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ),
      ),
      const SizedBox(height: 10),
      Row(
        children: [
          Text(
            'الخطوة ${step + 1} من 3',
            style: const TextStyle(
              fontSize: 12,
              color: kPrimaryDark,
              fontWeight: FontWeight.w900,
            ),
          ),
          const Spacer(),
          Text(
            label,
            style: const TextStyle(fontSize: 12, color: kTextSecondary),
          ),
        ],
      ),
    ],
  );
}

class _CategoryStep extends StatelessWidget {
  const _CategoryStep({required this.selected, required this.onSelected});

  final String selected;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    const items = [
      (Icons.phone_android_rounded, 'electronics', 'إلكترونيات'),
      (Icons.account_balance_wallet_rounded, 'documents', 'وثائق'),
      (Icons.key_rounded, 'keys', 'مفاتيح'),
      (Icons.work_outline_rounded, 'bags', 'حقائب'),
      (Icons.watch_outlined, 'accessories', 'إكسسوارات'),
      (Icons.inventory_2_outlined, 'other', 'أخرى'),
    ];

    return SingleChildScrollView(
      key: const ValueKey('category'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'ما نوع الغرض؟',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 7),
          const Text(
            'اختيار التصنيف يساعدنا في العثور على تطابقات أدق.',
            style: TextStyle(color: kTextSecondary, height: 1.5),
          ),
          const SizedBox(height: 25),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 1.55,
            children: items.map((item) {
              final active = selected == item.$2;
              return Material(
                color: active ? const Color(0xFFEAF8F6) : Colors.white,
                borderRadius: BorderRadius.circular(18),
                child: InkWell(
                  onTap: () => onSelected(item.$2),
                  borderRadius: BorderRadius.circular(18),
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: active ? kPrimary : kBorder,
                        width: active ? 1.5 : 1,
                      ),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          item.$1,
                          color: active ? kPrimaryDark : kTextSecondary,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          item.$3,
                          style: TextStyle(
                            fontWeight: FontWeight.w800,
                            color: active ? kPrimaryDark : null,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

class _LocationStep extends StatelessWidget {
  const _LocationStep({
    required this.location,
    required this.date,
    required this.onLocation,
    required this.onDate,
  });

  final String location;
  final DateTime date;
  final ValueChanged<String> onLocation;
  final ValueChanged<DateTime> onDate;

  @override
  Widget build(BuildContext context) => SingleChildScrollView(
    key: const ValueKey('location'),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'أين ومتى؟',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900),
        ),
        const SizedBox(height: 7),
        const Text(
          'نستخدم الموقع التقريبي فقط لحماية خصوصيتك.',
          style: TextStyle(color: kTextSecondary),
        ),
        const SizedBox(height: 25),
        DropdownButtonFormField<String>(
          initialValue: location,
          decoration: const InputDecoration(
            labelText: 'الموقع التقريبي',
            prefixIcon: Icon(Icons.location_on_outlined),
          ),
          items:
              const [
                    'السوق القديم، عتق',
                    'حي الخزان، عتق',
                    'شارع الجامعة، عتق',
                    'مركز المدينة، عتق',
                  ]
                  .map(
                    (item) => DropdownMenuItem(value: item, child: Text(item)),
                  )
                  .toList(),
          onChanged: (value) {
            if (value != null) onLocation(value);
          },
        ),
        const SizedBox(height: 14),
        InkWell(
          onTap: () async {
            final selected = await showDatePicker(
              context: context,
              firstDate: DateTime(2024),
              lastDate: DateTime.now(),
              initialDate: date,
            );
            if (selected != null) onDate(selected);
          },
          borderRadius: BorderRadius.circular(15),
          child: InputDecorator(
            decoration: const InputDecoration(
              labelText: 'التاريخ',
              prefixIcon: Icon(Icons.event_outlined),
            ),
            child: Text('${date.day}/${date.month}/${date.year}'),
          ),
        ),
        const SizedBox(height: 18),
        const _PrivacyNote(),
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
