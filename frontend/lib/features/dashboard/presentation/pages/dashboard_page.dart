import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Oto Yedek Parça Yönetimi'),
      ),
      body: GridView.count(
        padding: const EdgeInsets.all(24),
        crossAxisCount: 2,
        mainAxisSpacing: 24,
        crossAxisSpacing: 24,
        children: [
          _buildDashboardCard(
            context,
            'Yeni Parça Ekle',
            Icons.add_circle_outline,
            Colors.blue,
            () => context.go('/add-part'),
          ),
          _buildDashboardCard(
            context,
            'Stok Durumu',
            Icons.inventory,
            Colors.orange,
            () => context.go('/stock'),
          ),
          _buildDashboardCard(
            context,
            'Satışlar',
            Icons.point_of_sale,
            Colors.green,
            () {}, // TODO: Satış sayfasına yönlendir
          ),
          _buildDashboardCard(
            context,
            'Raporlar',
            Icons.bar_chart,
            Colors.purple,
            () {}, // TODO: Rapor sayfasına yönlendir
          ),
        ],
      ),
    );
  }

  Widget _buildDashboardCard(
    BuildContext context,
    String title,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return Card(
      elevation: 4,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 48,
              color: color,
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: Theme.of(context).textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
