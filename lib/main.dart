import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'src/application/providers.dart';
import 'src/data/demo_data.dart';
import 'src/domain/entities/report.dart';
import 'src/presentation/screens/account_screen.dart';
import 'src/presentation/screens/home_screen.dart';
import 'src/presentation/screens/my_reports_screen.dart';
import 'src/presentation/screens/report_details_screen.dart';
import 'src/presentation/screens/report_form_screen.dart';
import 'src/presentation/screens/search_screen.dart';
import 'src/presentation/theme/app_theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  if (kDemoMode) {
    // وضع العرض التجريبي: بيانات داخل الذاكرة، لا يتطلب Firebase.
    seedDemoData();
  }
  runApp(const ProviderScope(child: LaqitApp()));
}

/// Root application widget for Laqit (لقيط).
class LaqitApp extends StatefulWidget {
  const LaqitApp({super.key});

  @override
  State<LaqitApp> createState() => _LaqitAppState();
}

class _LaqitAppState extends State<LaqitApp> {
  final _navigatorKey = GlobalKey<NavigatorState>();
  final _scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();
  int _tab = 0;

  void _openForm(ReportType type) async {
    final report = await _navigatorKey.currentState!.push<Report>(
      MaterialPageRoute(builder: (_) => ReportFormScreen(type: type)),
    );
    if (report != null && mounted) {
      setState(() => _tab = 2);
      _scaffoldMessengerKey.currentState!.showSnackBar(
        const SnackBar(
          backgroundColor: kSuccess,
          content: Text('تم نشر البلاغ بنجاح. سنبلغك عند ظهور تطابق محتمل.'),
        ),
      );
    }
  }

  void _openDetails(Report report) => _navigatorKey.currentState!.push(
    MaterialPageRoute(builder: (_) => ReportDetailsScreen(report: report)),
  );

  @override
  Widget build(BuildContext context) {
    final pages = [
      HomeScreen(
        onLost: () => _openForm(ReportType.lost),
        onFound: () => _openForm(ReportType.found),
        onDetails: _openDetails,
        onSearch: () => setState(() => _tab = 1),
      ),
      SearchScreen(onDetails: _openDetails),
      MyReportsScreen(
        onDetails: _openDetails,
        onCreate: () => _openForm(ReportType.lost),
      ),
      const AccountScreen(),
    ];

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      navigatorKey: _navigatorKey,
      scaffoldMessengerKey: _scaffoldMessengerKey,
      title: 'لقيط',
      theme: buildAppTheme(),
      home: Directionality(
        textDirection: TextDirection.rtl,
        child: Scaffold(
          body: SafeArea(
            child: IndexedStack(index: _tab, children: pages),
          ),
          bottomNavigationBar: NavigationBar(
            selectedIndex: _tab,
            onDestinationSelected: (value) => setState(() => _tab = value),
            destinations: const [
              NavigationDestination(
                icon: Icon(Icons.home_outlined),
                selectedIcon: Icon(Icons.home_rounded),
                label: 'الرئيسية',
              ),
              NavigationDestination(
                icon: Icon(Icons.search_rounded),
                label: 'البحث',
              ),
              NavigationDestination(
                icon: Icon(Icons.folder_outlined),
                selectedIcon: Icon(Icons.folder_rounded),
                label: 'بلاغاتي',
              ),
              NavigationDestination(
                icon: Icon(Icons.person_outline_rounded),
                selectedIcon: Icon(Icons.person_rounded),
                label: 'حسابي',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
