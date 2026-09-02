import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../application/providers.dart';
import '../../domain/entities/report.dart';
import '../theme/app_theme.dart';
import '../widgets/report_card.dart';

/// Search screen (UX/UI spec - Screen 3).
class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key, required this.onDetails});

  final ValueChanged<Report> onDetails;

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  String query = '';
  String type = 'الكل';
  String category = 'الكل';

  @override
  Widget build(BuildContext context) {
    final reports = ref.watch(publicReportsProvider);

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'البحث',
            style: TextStyle(fontSize: 26, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 5),
          const Text(
            'ابحث بالاسم، التصنيف، أو الموقع التقريبي',
            style: TextStyle(fontSize: 13, color: kTextSecondary),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: TextField(
                  onChanged: (value) => setState(() => query = value.trim()),
                  decoration: const InputDecoration(
                    hintText: 'مثال: هاتف، مفاتيح...',
                    prefixIcon: Icon(Icons.search_rounded),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Material(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
                child: InkWell(
                  onTap: _showFilters,
                  borderRadius: BorderRadius.circular(15),
                  child: Container(
                    width: 54,
                    height: 54,
                    decoration: BoxDecoration(
                      border: Border.all(color: kBorder),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Badge(
                      isLabelVisible: type != 'الكل' || category != 'الكل',
                      smallSize: 8,
                      backgroundColor: kWarning,
                      child: const Icon(Icons.tune_rounded),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          reports.when(
            data: (items) {
              final results = _filter(items);
              return Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          '${results.length} بلاغات',
                          style: const TextStyle(fontWeight: FontWeight.w900),
                        ),
                        const Spacer(),
                        const Icon(
                          Icons.sort_rounded,
                          size: 17,
                          color: kPrimaryDark,
                        ),
                        const SizedBox(width: 4),
                        const Text(
                          'الأحدث أولاً',
                          style: TextStyle(
                            fontSize: 12,
                            color: kPrimaryDark,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Expanded(
                      child: results.isEmpty
                          ? _EmptyState(
                              onClear: () => setState(() {
                                query = '';
                                type = 'الكل';
                                category = 'الكل';
                              }),
                            )
                          : ListView.separated(
                              padding: const EdgeInsets.only(bottom: 20),
                              itemCount: results.length,
                              separatorBuilder: (_, index) =>
                                  const SizedBox(height: 12),
                              itemBuilder: (_, index) => ReportCard(
                                report: results[index],
                                onTap: () => widget.onDetails(results[index]),
                              ),
                            ),
                    ),
                  ],
                ),
              );
            },
            loading: () => const Expanded(
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (e, _) => Expanded(
              child: Center(
                child: Text(
                  'حدث خطأ: $e',
                  style: const TextStyle(color: kError),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Report> _filter(List<Report> items) => items
      .where(
        (item) =>
            (query.isEmpty ||
                item.title.contains(query) ||
                item.categoryId.contains(query) ||
                item.approximateLocation.contains(query)) &&
            (type == 'الكل' ||
                (type == 'مفقود') == (item.reportType == ReportType.lost)) &&
            (category == 'الكل' || category == item.categoryId),
      )
      .toList();

  void _showFilters() async {
    final value = await showModalBottomSheet<(String, String)>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => _FilterSheet(type: type, category: category),
    );
    if (value != null) {
      setState(() {
        type = value.$1;
        category = value.$2;
      });
    }
  }
}

class _FilterSheet extends StatefulWidget {
  const _FilterSheet({required this.type, required this.category});

  final String type;
  final String category;

  @override
  State<_FilterSheet> createState() => _FilterSheetState();
}

class _FilterSheetState extends State<_FilterSheet> {
  late String type = widget.type;
  late String category = widget.category;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
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
                borderRadius: BorderRadius.circular(9),
              ),
            ),
          ),
          const SizedBox(height: 22),
          const Text(
            'تصفية النتائج',
            style: TextStyle(fontSize: 19, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 18),
          const Text(
            'نوع البلاغ',
            style: TextStyle(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 9),
          Wrap(
            spacing: 8,
            children: ['الكل', 'مفقود', 'معثور']
                .map(
                  (e) => ChoiceChip(
                    label: Text(e),
                    selected: type == e,
                    onSelected: (_) => setState(() => type = e),
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 18),
          const Text('التصنيف', style: TextStyle(fontWeight: FontWeight.w800)),
          const SizedBox(height: 9),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: const ['الكل', 'electronics', 'documents', 'keys', 'bags']
                .map(
                  (e) => ChoiceChip(
                    label: Text(_categoryLabel(e)),
                    selected: category == e,
                    onSelected: (_) => setState(() => category = e),
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 28),
          FilledButton(
            onPressed: () => Navigator.pop(context, (type, category)),
            child: const Text('عرض النتائج'),
          ),
        ],
      ),
    ),
  );
}

String _categoryLabel(String id) => switch (id) {
  'electronics' => 'إلكترونيات',
  'documents' => 'وثائق',
  'keys' => 'مفاتيح',
  'bags' => 'حقائب',
  _ => 'الكل',
};

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.onClear});

  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) => Center(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 82,
          height: 82,
          decoration: const BoxDecoration(
            color: Color(0xFFEAF8F6),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.search_off_rounded,
            size: 38,
            color: kPrimary,
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          'لا توجد نتائج مطابقة',
          style: TextStyle(fontSize: 17, fontWeight: FontWeight.w900),
        ),
        const SizedBox(height: 8),
        const Text(
          'جرّب كلمات بحث أخرى أو وسّع معايير التصفية.',
          textAlign: TextAlign.center,
          style: TextStyle(color: kTextSecondary),
        ),
        const SizedBox(height: 10),
        TextButton(onPressed: onClear, child: const Text('مسح التصفية')),
      ],
    ),
  );
}
