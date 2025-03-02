import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'core/di/injection.dart';
import 'core/theme/app_theme.dart';
import 'features/dashboard/presentation/pages/dashboard_page.dart';
import 'features/inventory/presentation/pages/add_part_page.dart';
import 'features/inventory/presentation/pages/stock_page.dart';
import 'features/vehicles/presentation/pages/makes_page.dart';
import 'package:google_fonts/google_fonts.dart';

void main() async {
  // Environment değişkenlerini yükle
  await dotenv.load(fileName: ".env");

  // Bağımlılıkları ayarla
  await setupDependencies();

  runApp(const AutoPartsApp());
}

class AutoPartsApp extends StatelessWidget {
  const AutoPartsApp({super.key});

  @override
  Widget build(BuildContext context) {
    final router = GoRouter(
      initialLocation: '/',
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => const DashboardPage(),
        ),
        GoRoute(
          path: '/makes',
          builder: (context, state) => const MakesPage(),
        ),
        GoRoute(
          path: '/add-part',
          builder: (context, state) => const AddPartPage(),
        ),
        GoRoute(
          path: '/stock',
          builder: (context, state) => const StockPage(),
        ),
      ],
    );

    return MaterialApp.router(
      title: 'Oto Yedek Parça Yönetimi',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
        textTheme: GoogleFonts.robotoTextTheme(
          Theme.of(context).textTheme,
        ).copyWith(
          bodyMedium: TextStyle(
            fontFamily: 'Roboto',
            fontSize: 14,
            fontWeight: FontWeight.w400,
          ),
          bodyLarge: TextStyle(
            fontFamily: 'Roboto',
            fontSize: 16,
            fontWeight: FontWeight.w400,
          ),
        ),
        fontFamily: 'Roboto',
      ),
      darkTheme: AppTheme.darkTheme,
      routerConfig: router,
    );
  }
}
