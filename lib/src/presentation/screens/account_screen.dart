import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../application/providers.dart';
import '../theme/app_theme.dart';

/// Account screen (UX/UI spec - Screen 1 tab).
class AccountScreen extends ConsumerWidget {
  const AccountScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);

    const settings = [
      (Icons.person_outline_rounded, 'الملف الشخصي', 'الاسم ورقم الجوال'),
      (
        Icons.notifications_none_rounded,
        'الإشعارات',
        'التطابقات وتحديثات الطلبات',
      ),
      (
        Icons.shield_outlined,
        'الخصوصية والأمان',
        'البيانات الحساسة وصلاحيات الحساب',
      ),
      (
        Icons.help_outline_rounded,
        'المساعدة والدعم',
        'الأسئلة الشائعة والتواصل',
      ),
    ];

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
      children: [
        const Text(
          'حسابي',
          style: TextStyle(fontSize: 26, fontWeight: FontWeight.w900),
        ),
        const SizedBox(height: 22),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: kBorder),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 28,
                backgroundColor: const Color(0xFFE0F2F1),
                child: Text(
                  user?.displayName.isNotEmpty == true
                      ? user!.displayName[0]
                      : 'م',
                  style: const TextStyle(
                    fontSize: 23,
                    fontWeight: FontWeight.w900,
                    color: kPrimaryDark,
                  ),
                ),
              ),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user?.displayName ?? 'زائر',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      user == null ? 'سجّل الدخول للمتابعة' : 'عضو في لقيت',
                      style: const TextStyle(
                        fontSize: 12,
                        color: kTextSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_left_rounded, color: kTextMuted),
            ],
          ),
        ),
        const SizedBox(height: 18),
        Material(
          color: Colors.white,
          shape: RoundedRectangleBorder(
            side: const BorderSide(color: kBorder),
            borderRadius: BorderRadius.circular(20),
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            children: settings
                .map(
                  (item) => ListTile(
                    onTap: () {},
                    leading: Icon(item.$1, color: kPrimaryDark),
                    title: Text(
                      item.$2,
                      style: const TextStyle(fontWeight: FontWeight.w800),
                    ),
                    subtitle: Text(
                      item.$3,
                      style: const TextStyle(fontSize: 11),
                    ),
                    trailing: const Icon(Icons.chevron_left_rounded),
                  ),
                )
                .toList(),
          ),
        ),
        const SizedBox(height: 18),
        const _PrivacyCard(),
        if (user != null) ...[
          const SizedBox(height: 18),
          OutlinedButton(
            onPressed: () async {
              await ref.read(authRepositoryProvider).signOut();
            },
            style: OutlinedButton.styleFrom(
              foregroundColor: kError,
              side: const BorderSide(color: kError),
            ),
            child: const Text('تسجيل الخروج'),
          ),
        ],
      ],
    );
  }
}

class _PrivacyCard extends StatelessWidget {
  const _PrivacyCard();

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
