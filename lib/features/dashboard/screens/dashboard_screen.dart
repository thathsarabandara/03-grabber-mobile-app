import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../widgets/status_card.dart';
import '../../../widgets/premium_widgets.dart';
import 'package:go_router/go_router.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animController;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(vsync: this, duration: const Duration(milliseconds: 1400));
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Stack(
        children: [
          Positioned(
            top: 0, left: 0, right: 0, height: 420,
            child: CustomPaint(painter: HeaderWavePainter()),
          ),
          
          SafeArea(
            bottom: false,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Flexible(
                                  child: Text(
                                    'Good Evening, Thathsara',
                                    style: TextStyle(color: Colors.white.withValues(alpha: 0.8), fontSize: 14, fontWeight: FontWeight.w600, letterSpacing: 0.5),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                const Icon(Icons.waving_hand_rounded, color: Colors.amber, size: 16),
                              ],
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              'Smart Robot Arm',
                              style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w900, letterSpacing: -0.5, height: 1.2),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                const Icon(Icons.circle, color: Color(0xFF10B981), size: 10),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: Text('Robot Online • Last sync 5 sec ago', style: TextStyle(color: Colors.white.withValues(alpha: 0.9), fontSize: 13), overflow: TextOverflow.ellipsis),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _buildHeaderIcon(
                            Icons.notifications_none_rounded, 
                            hasBadge: true, 
                            onTap: () => _showNotificationPanel(context),
                          ),
                          const SizedBox(width: 8),
                          _buildHeaderIcon(Icons.settings_rounded),
                          const SizedBox(width: 8),
                          CircleAvatar(
                            radius: 18,
                            backgroundColor: Colors.white.withValues(alpha: 0.2),
                            child: const Icon(Icons.person, color: Colors.white, size: 20),
                          ),
                        ],
                      )
                    ],
                  ),
                ),                
                Expanded(
                  child: Container(
                    width: double.infinity,
                    decoration: const BoxDecoration(
                      color: Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.only(topLeft: Radius.circular(40), topRight: Radius.circular(40)),
                      boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 30, offset: Offset(0, -10))],
                    ),
                    child: ClipRRect(
                      borderRadius: const BorderRadius.only(topLeft: Radius.circular(40), topRight: Radius.circular(40)),
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.only(top: 32, bottom: 60),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 24),
                              child: SlideFade(
                                animation: _animController,
                                delay: 0.1,
                                child: _buildRobotStatusSection(),
                              ),
                            ),
                            const SizedBox(height: 32),
                            
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 24),
                              child: SlideFade(
                                animation: _animController,
                                delay: 0.2,
                                child: _buildEssentialStatusCards(),
                              ),
                            ),
                            const SizedBox(height: 32),

                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 24),
                              child: SlideFade(
                                animation: _animController,
                                delay: 0.3,
                                child: _buildMiniTelemetry(),
                              ),
                            ),
                            const SizedBox(height: 32),

                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 24),
                              child: SlideFade(
                                animation: _animController,
                                delay: 0.4,
                                child: _buildActiveAlertCard(),
                              ),
                            ),
                            const SizedBox(height: 32),

                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 24),
                              child: SlideFade(
                                animation: _animController,
                                delay: 0.5,
                                child: _buildQuickNavigationGrid(),
                              ),
                            ),
                            const SizedBox(height: 32),

                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 24),
                              child: SlideFade(
                                animation: _animController,
                                delay: 0.6,
                                child: _buildAiInsightCard(),
                              ),
                            ),
                          ],
                        ),
                      ),
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

  Widget _buildHeaderIcon(IconData icon, {bool hasBadge = false, VoidCallback? onTap}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          IconButton(icon: Icon(icon, color: Colors.white), onPressed: onTap ?? () {}),
          if (hasBadge)
            Positioned(
              top: 10, right: 10,
              child: Container(width: 8, height: 8, decoration: const BoxDecoration(color: Color(0xFFEF4444), shape: BoxShape.circle)),
            ),
        ],
      ),
    );
  }

  void _showNotificationPanel(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: const BoxDecoration(
          color: Color(0xFFF8FAFC),
          borderRadius: BorderRadius.only(topLeft: Radius.circular(30), topRight: Radius.circular(30)),
        ),
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.only(top: 12, bottom: 24),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Notifications', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF1D2939))),
                  TextButton(
                    onPressed: () {},
                    child: const Text('Mark all as read', style: TextStyle(color: Color(0xFF155EEF), fontWeight: FontWeight.w600)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                children: [
                  _buildNotificationItem(context, 'Movement Detected', 'Robot detected movement in Sector A.', Icons.warning_rounded, Colors.orange, '2 min ago'),
                  _buildNotificationItem(context, 'Battery Low', 'Robot power is at 15%. Returning to dock.', Icons.battery_alert_rounded, Colors.red, '15 min ago'),
                  _buildNotificationItem(context, 'System Update', 'Firmware v2.4.1 is successfully installed.', Icons.system_update_rounded, Colors.blue, '2 hours ago'),
                  _buildNotificationItem(context, 'Patrol Completed', 'Routine patrol finished with 0 anomalies.', Icons.check_circle_rounded, Colors.green, '5 hours ago'),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationItem(BuildContext context, String title, String message, IconData icon, Color color, String time) {
    return GestureDetector(
      onTap: () {
        context.pop(); // Close the bottom sheet first
        context.go('/notification-details', extra: {
          'title': title,
          'message': message,
          'icon': icon,
          'color': color,
          'time': time,
        });
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 10, offset: const Offset(0, 4))],
        ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(child: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF1D2939)), overflow: TextOverflow.ellipsis)),
                    const SizedBox(width: 8),
                    Text(time, style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
                  ],
                ),
                const SizedBox(height: 4),
                Text(message, style: TextStyle(fontSize: 14, color: Colors.grey.shade600, height: 1.3)),
              ],
            ),
          ),
        ],
      ),
    ));
  }

  Widget _buildRobotStatusSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Robot Status', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF1D2939))),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(child: EssentialStatusCard(title: 'Status', icon: Icons.check_circle_rounded, value: 'Online', subtitle: 'Connected', color: Colors.green)),
            const SizedBox(width: 16),
            Expanded(child: EssentialStatusCard(title: 'Power', icon: Icons.battery_charging_full_rounded, value: '82%', subtitle: 'Discharging', color: Colors.teal)),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(child: EssentialStatusCard(title: 'Signal', icon: Icons.signal_cellular_alt_rounded, value: 'Strong', subtitle: 'Low Latency', color: Colors.blue)),
            const SizedBox(width: 16),
            Expanded(child: EssentialStatusCard(title: 'Mode', icon: Icons.explore_rounded, value: 'Patrol', subtitle: 'Active', color: Colors.purple)),
          ],
        ),
        const SizedBox(height: 16),
        BouncingCard(
          onTap: () {},
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFFF1F5F9))),
            child: Row(
              children: [
                const Icon(Icons.history_rounded, size: 20, color: Color(0xFF64748B)),
                const SizedBox(width: 12),
                Expanded(
                  child: Text('Last Activity: Detected movement 2 min ago', style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEssentialStatusCards() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Essential Status', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1D2939))),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(child: EssentialStatusCard(title: 'Battery', icon: Icons.battery_charging_full_rounded, value: '82%', subtitle: 'Charging: No', color: Colors.green)),
            const SizedBox(width: 16),
            Expanded(child: EssentialStatusCard(title: 'Connection', icon: Icons.wifi_rounded, value: 'Online', subtitle: 'Latency: 32ms', color: Colors.blue)),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(child: EssentialStatusCard(title: 'AI Engine', icon: Icons.psychology_rounded, value: 'Running', subtitle: 'Confidence: High', color: Colors.purple)),
            const SizedBox(width: 16),
            Expanded(child: EssentialStatusCard(title: 'Security', icon: Icons.shield_rounded, value: 'Normal', subtitle: '0 Active Alerts', color: Colors.orange)),
          ],
        ),
      ],
    );
  }



  Widget _buildActiveAlertCard() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('System Alerts', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1D2939))),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 15, offset: const Offset(0, 5))],
            border: Border.all(color: const Color(0xFFF1F5F9)),
          ),
          child: Column(
            children: [
              _buildAlertTableRow(Icons.brightness_low_rounded, 'Low Light Detected', 'Camera 1', 'Just now', Colors.orange),
              const Divider(height: 1, color: Color(0xFFF1F5F9)),
              _buildAlertTableRow(Icons.gas_meter_rounded, 'Gas Level Elevated', 'Sensor A', '2 min ago', Colors.red),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAlertTableRow(IconData icon, String title, String source, String time, Color color) {
    return BouncingCard(
      onTap: () {},
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF1D2939))),
                  const SizedBox(height: 4),
                  Wrap(
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Text(source, style: const TextStyle(fontSize: 12, color: Color(0xFF64748B))),
                      const SizedBox(width: 8),
                      const Icon(Icons.circle, size: 4, color: Color(0xFFCBD5E1)),
                      const SizedBox(width: 8),
                      Text(time, style: const TextStyle(fontSize: 12, color: Color(0xFF94A3B8))),
                    ],
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: Color(0xFFCBD5E1), size: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildMiniTelemetry() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Telemetry', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1D2939))),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(child: EssentialStatusCard(title: 'Temperature', icon: Icons.thermostat, value: '28°C', subtitle: 'Core T1', color: Colors.orange)),
            const SizedBox(width: 16),
            Expanded(child: EssentialStatusCard(title: 'Distance', icon: Icons.straighten, value: '120 cm', subtitle: 'Front Sonar', color: Colors.indigo)),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(child: EssentialStatusCard(title: 'Speed', icon: Icons.speed, value: '0.2 m/s', subtitle: 'Motors', color: Colors.cyan)),
            const SizedBox(width: 16),
            Expanded(child: EssentialStatusCard(title: 'Power Draw', icon: Icons.electrical_services, value: '1.8A', subtitle: 'Total', color: Colors.redAccent)),
          ],
        ),
      ],
    );
  }

  Widget _buildAiInsightCard() {
    return BouncingCard(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: [Colors.purple.shade50, Colors.blue.shade50]),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.purple.shade100),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.auto_awesome, color: Colors.purple.shade400, size: 20),
                const SizedBox(width: 8),
                Text('AI Insight', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.purple.shade700)),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'You usually activate patrol mode at 10 PM. Would you like to automate it?',
              style: TextStyle(fontSize: 14, color: Colors.purple.shade900, height: 1.4),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purple.shade600,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Yes, Automate'),
                ),
                const SizedBox(width: 12),
                TextButton(
                  onPressed: () {},
                  style: TextButton.styleFrom(foregroundColor: Colors.purple.shade700),
                  child: const Text('Dismiss'),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _buildQuickNavigationGrid() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Quick Navigation', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1D2939))),
        const SizedBox(height: 16),
        GridView.count(
          crossAxisCount: 4,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          childAspectRatio: 0.8,
          children: [
            _buildSimpleNavIcon(Icons.gamepad_rounded, 'Control', Colors.blue),
            _buildSimpleNavIcon(Icons.videocam_rounded, 'Vision', Colors.green),
            _buildSimpleNavIcon(Icons.smart_toy_rounded, 'Assistant', Colors.purple),
            _buildSimpleNavIcon(Icons.auto_awesome_rounded, 'Automate', Colors.orange),
            _buildSimpleNavIcon(Icons.bar_chart_rounded, 'Analytics', Colors.teal),
            _buildSimpleNavIcon(Icons.event_note_rounded, 'Events', Colors.pink),
            _buildSimpleNavIcon(Icons.settings_rounded, 'Settings', Colors.grey.shade700),
            _buildSimpleNavIcon(Icons.precision_manufacturing_rounded, 'Robot', Colors.indigo),
          ],
        )
      ],
    );
  }

  Widget _buildSimpleNavIcon(IconData icon, String label, Color color) {
    return BouncingCard(
      onTap: () {},
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFF1F5F9)),
              boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 4, offset: const Offset(0, 2))],
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 8),
          Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF475467)), overflow: TextOverflow.ellipsis),
        ],
      ),
    );
  }
}
