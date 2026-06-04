import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../widgets/status_card.dart';
import '../../../core/theme/app_theme.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(LucideIcons.bell),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hero Section - Robot Status
            Card(
              color: AppTheme.primaryBlue,
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Row(
                  children: [
                    const Icon(LucideIcons.cpu, size: 48, color: Colors.white),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Grabber Alpha',
                            style: theme.textTheme.titleLarge?.copyWith(color: Colors.white),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Container(
                                width: 8,
                                height: 8,
                                decoration: const BoxDecoration(
                                  color: AppTheme.success,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 8),
                              const Text('Online & Ready', style: TextStyle(color: Colors.white70)),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            
            // Statistics Grid
            Text('Overview', style: theme.textTheme.titleLarge),
            const SizedBox(height: 12),
            GridView.count(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              children: const [
                StatusCard(
                  title: 'Connected Robots',
                  value: '3',
                  icon: LucideIcons.network,
                  color: AppTheme.primaryBlue,
                ),
                StatusCard(
                  title: 'Tasks Completed',
                  value: '128',
                  icon: LucideIcons.checkCircle2,
                  color: AppTheme.success,
                ),
                StatusCard(
                  title: 'Camera Recordings',
                  value: '45',
                  icon: LucideIcons.video,
                  color: AppTheme.warning,
                ),
                StatusCard(
                  title: 'System Health',
                  value: '98%',
                  icon: LucideIcons.activity,
                  color: AppTheme.secondaryBlue,
                ),
              ],
            ),
            
            const SizedBox(height: 24),
            // Charts Section
            Text('Robot Activity', style: theme.textTheme.titleLarge),
            const SizedBox(height: 12),
            SizedBox(
              height: 200,
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: LineChart(
                    LineChartData(
                      gridData: const FlGridData(show: false),
                      titlesData: const FlTitlesData(show: false),
                      borderData: FlBorderData(show: false),
                      lineBarsData: [
                        LineChartBarData(
                          spots: const [
                            FlSpot(0, 3),
                            FlSpot(1, 1),
                            FlSpot(2, 4),
                            FlSpot(3, 2),
                            FlSpot(4, 5),
                            FlSpot(5, 3),
                            FlSpot(6, 4),
                          ],
                          isCurved: true,
                          color: AppTheme.primaryBlue,
                          barWidth: 3,
                          isStrokeCapRound: true,
                          dotData: const FlDotData(show: false),
                          belowBarData: BarAreaData(
                            show: true,
                            color: AppTheme.primaryBlue.withOpacity(0.1),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text('Recent Activity', style: theme.textTheme.titleLarge),
            const SizedBox(height: 12),
            // Recent Activity Feed
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: 3,
              itemBuilder: (context, index) {
                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: AppTheme.success.withOpacity(0.1),
                      child: const Icon(LucideIcons.check, color: AppTheme.success),
                    ),
                    title: const Text('Task Completed'),
                    subtitle: const Text('Pick and place operation finished successfully.'),
                    trailing: Text('2m ago', style: TextStyle(color: theme.colorScheme.onSurfaceVariant)),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
