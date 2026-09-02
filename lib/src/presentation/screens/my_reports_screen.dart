import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../application/providers.dart';
import '../../domain/entities/report.dart';
import '../theme/app_theme.dart';
import '../widgets/report_card.dart';

/// My Reports screen (UX/UI spec - Screen 1 tab).
class MyReportsScreen extends ConsumerWidget {
  const MyReportsScreen({
    super.key,
    required this.onDetails,
    required this.onCreate,
  });

  final ValueChanged<Report> onDetails;
  final VoidCallback onCreate;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reports = ref.watch(myReportsProvider);
    final matches = ref.watch(myMatchesProvider);
    final requests = ref.watch(myRequestsProvider);

    return DefaultTabController(
      length: 3,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 0),
            child: Row(
              children: [
                const Expanded(
                  child: Text(
                    'بلاغاتي',
                    style: TextStyle(fontSize: 26, fontWeight: FontWeight.w900),
                  ),
                ),
                IconButton(
                  onPressed: onCreate,
                  tooltip: 'إنشاء بلاغ',
                  icon: const Icon(
                    Icons.add_circle_outline_rounded,
                    color: kPrimary,
                  ),
                ),
              ],
            ),
          ),
          const TabBar(
            labelColor: kPrimaryDark,
            indicatorColor: kPrimary,
            tabs: [
              Tab(text: 'بلاغاتي'),
              Tab(text: 'التطابقات'),
              Tab(text: 'الطلبات'),
            ],
          ),
          Expanded(
            child: TabBarView(
              children: [
                reports.when(
                  data: (items) => items.isEmpty
                      ? const _EmptyState(
                          icon: Icons.folder_open_outlined,
                          title: 'لا توجد بلاغات بعد',
                          subtitle: 'أنشئ بلاغك الأول لتبدأ رحلة الاستعادة.',
                        )
                      : ListView.separated(
                          padding: const EdgeInsets.all(20),
                          itemCount: items.length,
                          separatorBuilder: (_, index) =>
                              const SizedBox(height: 12),
                          itemBuilder: (_, i) => ReportCard(
                            report: items[i],
                            onTap: () => onDetails(items[i]),
                          ),
                        ),
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (e, _) => Center(
                    child: Text(
                      'حدث خطأ: $e',
                      style: const TextStyle(color: kError),
                    ),
                  ),
                ),
                matches.when(
                  data: (items) => items.isEmpty
                      ? const _EmptyState(
                          icon: Icons.auto_awesome_outlined,
                          title: 'لا توجد تطابقات',
                          subtitle:
                              'ستظهر هنا التطابقات المحتملة عندما يجد النظام بلاغاً مشابهاً.',
                        )
                      : ListView.separated(
                          padding: const EdgeInsets.all(20),
                          itemCount: items.length,
                          separatorBuilder: (_, index) =>
                              const SizedBox(height: 12),
                          itemBuilder: (_, i) =>
                              _MatchCard(score: items[i].score, onTap: () {}),
                        ),
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (e, _) => Center(
                    child: Text(
                      'حدث خطأ: $e',
                      style: const TextStyle(color: kError),
                    ),
                  ),
                ),
                requests.when(
                  data: (items) => items.isEmpty
                      ? const _EmptyState(
                          icon: Icons.assignment_turned_in_outlined,
                          title: 'لا توجد طلبات استعادة',
                          subtitle: 'ستظهر هنا طلباتك بعد بدء مسار التحقق.',
                        )
                      : ListView.separated(
                          padding: const EdgeInsets.all(20),
                          itemCount: items.length,
                          separatorBuilder: (_, index) =>
                              const SizedBox(height: 12),
                          itemBuilder: (_, i) => _RequestCard(
                            status: items[i].status.label,
                            onTap: () {},
                          ),
                        ),
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (e, _) => Center(
                    child: Text(
                      'حدث خطأ: $e',
                      style: const TextStyle(color: kError),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MatchCard extends StatelessWidget {
  const _MatchCard({required this.score, required this.onTap});

  final double score;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Material(
    color: const Color(0xFFEAF8F6),
    borderRadius: BorderRadius.circular(20),
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: kPrimary,
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(Icons.link_rounded, color: Colors.white),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'تطابق محتمل جديد',
                    style: TextStyle(fontWeight: FontWeight.w900),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'قد يطابق هاتفًا عثرت عليه بلاغك.',
                    style: TextStyle(fontSize: 12, color: Color(0xFF496461)),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Text(
                    '${(score * 100).round()}%',
                    style: const TextStyle(
                      fontWeight: FontWeight.w900,
                      color: kPrimaryDark,
                    ),
                  ),
                  const Text(
                    'توافق',
                    style: TextStyle(fontSize: 10, color: kTextSecondary),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

class _RequestCard extends StatelessWidget {
  const _RequestCard({required this.status, required this.onTap});

  final String status;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Material(
    color: Colors.white,
    borderRadius: BorderRadius.circular(19),
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(19),
      child: Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          border: Border.all(color: kBorder),
          borderRadius: BorderRadius.circular(19),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: const Color(0xFFEAF8F6),
                borderRadius: BorderRadius.circular(13),
              ),
              child: const Icon(
                Icons.assignment_turned_in_outlined,
                color: kPrimaryDark,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'طلب استعادة',
                    style: TextStyle(fontWeight: FontWeight.w900),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    status,
                    style: const TextStyle(fontSize: 12, color: kTextSecondary),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_left_rounded, color: kTextMuted),
          ],
        ),
      ),
    ),
  );
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(38),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: kTextMuted, size: 54),
          const SizedBox(height: 13),
          Text(
            title,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 6),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: const TextStyle(color: kTextSecondary),
          ),
        ],
      ),
    ),
  );
}
