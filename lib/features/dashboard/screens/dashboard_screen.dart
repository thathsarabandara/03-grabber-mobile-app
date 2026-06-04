import 'package:flutter/material.dart';
import '../../../widgets/status_card.dart';
import '../../../widgets/premium_widgets.dart';

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
                              'Smart Home Robot Platform',
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
                          _buildHeaderIcon(Icons.notifications_none_rounded, hasBadge: true),
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

  Widget _buildHeaderIcon(IconData icon, {bool hasBadge = false}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          IconButton(icon: Icon(icon, color: Colors.white), onPressed: () {}),
          if (hasBadge)
            Positioned(
              top: 10, right: 10,
              child: Container(width: 8, height: 8, decoration: const BoxDecoration(color: Color(0xFFEF4444), shape: BoxShape.circle)),
            ),
        ],
      ),
    );
  }

  Widget _buildRobotStatusSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Robot Status', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF1D2939))),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(child: _buildEssentialCard('Status', Icons.check_circle_rounded, 'Online', 'Connected', Colors.green)),
            const SizedBox(width: 16),
            Expanded(child: _buildEssentialCard('Power', Icons.battery_charging_full_rounded, '82%', 'Discharging', Colors.teal)),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(child: _buildEssentialCard('Signal', Icons.signal_cellular_alt_rounded, 'Strong', 'Low Latency', Colors.blue)),
            const SizedBox(width: 16),
            Expanded(child: _buildEssentialCard('Mode', Icons.explore_rounded, 'Patrol', 'Active', Colors.purple)),
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
            Expanded(child: _buildEssentialCard('Battery', Icons.battery_charging_full_rounded, '82%', 'Charging: No', Colors.green)),
            const SizedBox(width: 16),
            Expanded(child: _buildEssentialCard('Connection', Icons.wifi_rounded, 'Online', 'Latency: 32ms', Colors.blue)),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(child: _buildEssentialCard('AI Engine', Icons.psychology_rounded, 'Running', 'Confidence: High', Colors.purple)),
            const SizedBox(width: 16),
            Expanded(child: _buildEssentialCard('Security', Icons.shield_rounded, 'Normal', '0 Active Alerts', Colors.orange)),
          ],
        ),
      ],
    );
  }

  Widget _buildEssentialCard(String title, IconData icon, String value, String subtitle, Color color) {
    return BouncingCard(
      onTap: () {},
      child: Container(
        height: 120,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [BoxShadow(color: color.withValues(alpha: 0.3), blurRadius: 20, offset: const Offset(0, 10))],
        ),
        child: Stack(
          children: [
            Positioned(
              right: -20,
              bottom: -20,
              child: Icon(icon, size: 100, color: Colors.white.withValues(alpha: 0.2)),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), shape: BoxShape.circle),
                        child: Icon(icon, size: 16, color: Colors.white),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white), overflow: TextOverflow.ellipsis),
                      ),
                    ],
                  ),
                  const Spacer(),
                  Text(value, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
                  Text(subtitle, style: TextStyle(fontSize: 12, color: Colors.white.withValues(alpha: 0.8))),
                ],
              ),
            ),
          ],
        ),
      ),
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
            Expanded(child: _buildEssentialCard('Temperature', Icons.thermostat, '28°C', 'Core T1', Colors.orange)),
            const SizedBox(width: 16),
            Expanded(child: _buildEssentialCard('Distance', Icons.straighten, '120 cm', 'Front Sonar', Colors.indigo)),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(child: _buildEssentialCard('Speed', Icons.speed, '0.2 m/s', 'Motors', Colors.cyan)),
            const SizedBox(width: 16),
            Expanded(child: _buildEssentialCard('Power Draw', Icons.electrical_services, '1.8A', 'Total', Colors.redAccent)),
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
