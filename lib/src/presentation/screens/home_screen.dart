import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../application/providers.dart';
import '../../domain/entities/report.dart';
import '../theme/app_theme.dart';
import '../widgets/report_card.dart';

/// Home screen (UX/UI spec - Screen 1).
class HomeScreen extends ConsumerWidget {
  const HomeScreen({
    super.key,
    required this.onLost,
    required this.onFound,
    required this.onDetails,
    required this.onSearch,
  });

  final VoidCallback onLost;
  final VoidCallback onFound;
  final ValueChanged<Report> onDetails;
  final VoidCallback onSearch;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reports = ref.watch(publicReportsProvider);

    return CustomScrollView(
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
          sliver: SliverToBoxAdapter(
            child: Column(
              children: [
                const _BrandBar(),
                const SizedBox(height: 22),
                _Hero(onSearch: onSearch),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: _ActionCard(
                        title: 'أبلغ عن مفقود',
                        subtitle: 'ساعدنا في البحث عنه',
                        icon: Icons.search_off_rounded,
                        color: const Color(0xFFE8752A),
                        onTap: onLost,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _ActionCard(
                        title: 'أبلغ عن معثور',
                        subtitle: 'ساعد صاحبه في الوصول إليه',
                        icon: Icons.volunteer_activism_outlined,
                        color: kPrimary,
                        onTap: onFound,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                const _SectionTitle(title: 'أحدث البلاغات', action: 'استكشف'),
                const SizedBox(height: 11),
              ],
            ),
          ),
        ),
        reports.when(
          data: (items) => SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
            sliver: items.isEmpty
                ? const SliverToBoxAdapter(child: _EmptyReports())
                : SliverList.separated(
                    itemCount: items.length,
                    separatorBuilder: (_, index) => const SizedBox(height: 12),
                    itemBuilder: (_, index) => ReportCard(
                      report: items[index],
                      onTap: () => onDetails(items[index]),
                    ),
                  ),
          ),
          loading: () => const SliverToBoxAdapter(
            child: Center(
              child: Padding(
                padding: EdgeInsets.all(40),
                child: CircularProgressIndicator(),
              ),
            ),
          ),
          error: (e, _) =>
              SliverToBoxAdapter(child: _ErrorState(message: '$e')),
        ),
      ],
    );
  }
}

class _BrandBar extends StatelessWidget {
  const _BrandBar();

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: kPrimary,
          borderRadius: BorderRadius.circular(14),
        ),
        child: const Icon(Icons.travel_explore_rounded, color: Colors.white),
      ),
      const SizedBox(width: 10),
      const Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'لَقِيَت',
              style: TextStyle(
                fontSize: 21,
                fontWeight: FontWeight.w900,
                color: kPrimaryDark,
              ),
            ),
            Text(
              'نساعدك في استعادة ما يهمك',
              style: TextStyle(fontSize: 12, color: kTextSecondary),
            ),
          ],
        ),
      ),
      IconButton(
        onPressed: () => Navigator.of(
          context,
        ).push(MaterialPageRoute(builder: (_) => const _NotificationsScreen())),
        tooltip: 'الإشعارات',
        icon: const Badge(
          smallSize: 9,
          backgroundColor: kWarning,
          child: Icon(Icons.notifications_none_rounded),
        ),
      ),
    ],
  );
}

class _Hero extends StatelessWidget {
  const _Hero({required this.onSearch});

  final VoidCallback onSearch;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(24),
      gradient: const LinearGradient(
        begin: Alignment.topRight,
        end: Alignment.bottomLeft,
        colors: [kPrimaryDark, kPrimary],
      ),
      boxShadow: const [
        BoxShadow(
          color: Color(0x33006B62),
          blurRadius: 20,
          offset: Offset(0, 9),
        ),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: .17),
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Text(
            'مدينة عتق، شبوة',
            style: TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        const SizedBox(height: 13),
        const Text(
          'كل ما تفقدة او تعثر عنه\nفي مكان واحد.',
          style: TextStyle(
            color: Colors.white,
            fontSize: 25,
            height: 1.24,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'ابحث في البلاغات أو أبلغ بسرعة وبخصوصية.',
          style: TextStyle(
            color: Colors.white.withValues(alpha: .88),
            fontSize: 13,
          ),
        ),
        const SizedBox(height: 18),
        Material(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          child: InkWell(
            onTap: onSearch,
            borderRadius: BorderRadius.circular(14),
            child: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 14, vertical: 13),
              child: Row(
                children: [
                  Icon(Icons.search_rounded, color: kPrimaryDark),
                  SizedBox(width: 10),
                  Text(
                    'ابحث عن غرض أو بلاغ',
                    style: TextStyle(
                      color: Color(0xFF53616A),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    ),
  );
}

class _ActionCard extends StatelessWidget {
  const _ActionCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Material(
    color: Colors.white,
    borderRadius: BorderRadius.circular(20),
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: kBorder),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: color.withValues(alpha: .12),
                borderRadius: BorderRadius.circular(13),
              ),
              child: Icon(icon, color: color),
            ),
            const SizedBox(height: 15),
            Text(
              title,
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 5),
            Text(
              subtitle,
              style: const TextStyle(
                color: kTextSecondary,
                height: 1.4,
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title, required this.action});

  final String title;
  final String action;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Text(
        title,
        style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w900),
      ),
      const Spacer(),
      Text(
        action,
        style: const TextStyle(
          fontSize: 13,
          color: kPrimaryDark,
          fontWeight: FontWeight.w800,
        ),
      ),
    ],
  );
}

class _EmptyReports extends StatelessWidget {
  const _EmptyReports();

  @override
  Widget build(BuildContext context) => const Padding(
    padding: EdgeInsets.symmetric(vertical: 40),
    child: Column(
      children: [
        Icon(Icons.inbox_outlined, size: 54, color: kTextMuted),
        SizedBox(height: 13),
        Text(
          'لا توجد بلاغات بعد',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
        ),
        SizedBox(height: 6),
        Text(
          'كن أول من ينشر بلاغاً في عتق.',
          style: TextStyle(color: kTextSecondary),
        ),
      ],
    ),
  );
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.all(40),
    child: Column(
      children: [
        const Icon(Icons.error_outline, size: 54, color: kError),
        const SizedBox(height: 13),
        const Text(
          'حدث خطأ في تحميل البلاغات',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
        ),
        const SizedBox(height: 6),
        Text(
          message,
          textAlign: TextAlign.center,
          style: const TextStyle(color: kTextSecondary),
        ),
      ],
    ),
  );
}

class _NotificationsScreen extends StatelessWidget {
  const _NotificationsScreen();

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text(
        'الإشعارات',
        style: TextStyle(fontWeight: FontWeight.w900),
      ),
    ),
    body: const Center(child: Text('لا توجد إشعارات حالياً')),
  );
}
