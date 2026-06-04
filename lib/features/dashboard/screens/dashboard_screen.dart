import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../widgets/status_card.dart';
import '../../../widgets/glass_card.dart';
import '../../../widgets/pattern_background.dart';
import '../../../core/theme/app_theme.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text('Dashboard'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {},
          ),
        ],
      ),
      body: PatternBackground(
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(top: 100, left: 16.0, right: 16.0, bottom: 24.0), // top padding to account for transparent appbar
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Hero Section - Robot Status
              GlassCard(
                color: AppTheme.primaryBlue.withValues(alpha: 0.9),
                border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
                padding: const EdgeInsets.all(24.0),
                child: Row(
                  children: [
                    const Icon(Icons.memory_outlined, size: 48, color: Colors.white),
                    const SizedBox(width: 20),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Grabber Alpha',
                            style: theme.textTheme.titleLarge?.copyWith(color: Colors.white, fontSize: 22),
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              Container(
                                width: 10,
                                height: 10,
                                decoration: const BoxDecoration(
                                  color: AppTheme.success,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 8),
                              const Text('Online & Ready', style: TextStyle(color: Colors.white70, fontWeight: FontWeight.w500)),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              
              // Statistics Grid
              Text('Overview', style: theme.textTheme.titleLarge),
              const SizedBox(height: 16),
              GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                children: const [
                  StatusCard(
                    title: 'Connected Robots',
                    value: '3',
                    icon: Icons.hub_outlined,
                    color: AppTheme.primaryBlue,
                  ),
                  StatusCard(
                    title: 'Tasks Completed',
                    value: '128',
                    icon: Icons.check_circle_outline,
                    color: AppTheme.success,
                  ),
                  StatusCard(
                    title: 'Camera Recordings',
                    value: '45',
                    icon: Icons.videocam_outlined,
                    color: AppTheme.warning,
                  ),
                  StatusCard(
                    title: 'System Health',
                    value: '98%',
                    icon: Icons.monitor_heart_outlined,
                    color: AppTheme.secondaryBlue,
                  ),
                ],
              ),
              
              const SizedBox(height: 32),
              // Charts Section
              Text('Robot Activity', style: theme.textTheme.titleLarge),
              const SizedBox(height: 16),
              SizedBox(
                height: 220,
                child: GlassCard(
                  padding: const EdgeInsets.all(20.0),
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
                          barWidth: 4,
                          isStrokeCapRound: true,
                          dotData: const FlDotData(show: false),
                          belowBarData: BarAreaData(
                            show: true,
                            color: AppTheme.primaryBlue.withValues(alpha: 0.15),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 32),
              Text('Recent Activity', style: theme.textTheme.titleLarge),
              const SizedBox(height: 16),
              // Recent Activity Feed
              ListView.builder(
                shrinkWrap: true,
                padding: EdgeInsets.zero,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: 3,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12.0),
                    child: GlassCard(
                      padding: const EdgeInsets.all(4.0),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: AppTheme.success.withValues(alpha: 0.1),
                          child: const Icon(Icons.check, color: AppTheme.success),
                        ),
                        title: Text('Task Completed', style: theme.textTheme.titleMedium),
                        subtitle: const Text('Pick and place operation finished successfully.'),
                        trailing: Text('2m ago', style: TextStyle(color: theme.textTheme.bodySmall?.color)),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
