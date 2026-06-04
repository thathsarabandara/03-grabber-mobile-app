import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../widgets/premium_widgets.dart';

class RobotsScreen extends StatefulWidget {
  const RobotsScreen({super.key});

  @override
  State<RobotsScreen> createState() => _RobotsScreenState();
}

class _RobotsScreenState extends State<RobotsScreen> with TickerProviderStateMixin {
  late AnimationController _animController;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(vsync: this, duration: const Duration(milliseconds: 1000));
    _tabController = TabController(length: 2, vsync: this);
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Stack(
        children: [
          Positioned(
            top: 0, left: 0, right: 0, height: 350,
            child: CustomPaint(painter: HeaderWavePainter()),
          ),
          
          SafeArea(
            bottom: false,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'My Robots',
                        style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.w900, letterSpacing: -1.0),
                      ),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
                        ),
                        child: IconButton(
                          icon: const Icon(Icons.add_rounded, color: Colors.white),
                          onPressed: () {},
                        ),
                      ),
                    ],
                  ),
                ),
                SlideFade(
                  animation: _animController,
                  delay: 0.1,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 24, right: 24, bottom: 24),
                    child: Container(
                      height: 50,
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
                      ),
                      child: TabBar(
                        controller: _tabController,
                        indicator: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 4))],
                        ),
                        dividerColor: Colors.transparent,
                        labelColor: const Color(0xFF155EEF),
                        unselectedLabelColor: Colors.white,
                        labelStyle: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14),
                        unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                        tabs: const [
                          Tab(child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.public_rounded, size: 20), SizedBox(width: 8), Text('Internet')])),
                          Tab(child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.bluetooth_rounded, size: 20), SizedBox(width: 8), Text('Local BLE')])),
                        ],
                      ),
                    ),
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
                      child: TabBarView(
                        controller: _tabController,
                        children: [
                          _buildInternetTab(),
                          _buildBleTab(),
                        ],
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

  Widget _buildInternetTab() {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(24, 32, 24, 120),
      itemCount: 2,
      itemBuilder: (context, index) {
        final isOnline = index == 0;
        return SlideFade(
          animation: _animController,
          delay: 0.2 + (index * 0.1),
          child: _buildRobotCard(
            name: index == 0 ? 'Grabber Alpha' : 'Grabber Beta',
            isOnline: isOnline,
            battery: isOnline ? '87%' : '12%',
            signal: isOnline ? 'Strong' : 'None',
            lastActive: isOnline ? 'Active Now' : '2 days ago',
            type: 'Cloud Connected',
          ),
        );
      },
    );
  }

  Widget _buildBleTab() {
    return ListView(
      padding: const EdgeInsets.fromLTRB(24, 32, 24, 120),
      children: [
        SlideFade(
          animation: _animController,
          delay: 0.2,
          child: BouncingCard(
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: const Color(0xFFEFF4FF),
                borderRadius: BorderRadius.circular(28),
                border: Border.all(color: const Color(0xFF155EEF).withValues(alpha: 0.2)),
              ),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle, boxShadow: [BoxShadow(color: const Color(0xFF155EEF).withValues(alpha: 0.1), blurRadius: 20)]),
                    child: const Icon(Icons.bluetooth_searching_rounded, size: 40, color: Color(0xFF155EEF)),
                  ),
                  const SizedBox(height: 16),
                  const Text('Scanning for Robots...', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Color(0xFF1D2939))),
                  const SizedBox(height: 8),
                  const Text('Ensure your robot is powered on and in pairing mode.', textAlign: TextAlign.center, style: TextStyle(fontSize: 13, color: Color(0xFF64748B))),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 32),
        SlideFade(
          animation: _animController,
          delay: 0.3,
          child: const Text('Discovered Devices', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Color(0xFF1D2939))),
        ),
        const SizedBox(height: 16),
        SlideFade(
          animation: _animController,
          delay: 0.4,
          child: _buildBleDeviceCard('REX-47 LOCAL', 'RSSI: -45 dBm'),
        ),
        SlideFade(
          animation: _animController,
          delay: 0.5,
          child: _buildBleDeviceCard('GRABBER-V2', 'RSSI: -68 dBm'),
        ),
      ],
    );
  }

  Widget _buildBleDeviceCard(String name, String signal) {
    return BouncingCard(
      onTap: () {},
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 10, offset: const Offset(0, 4))],
          border: Border.all(color: const Color(0xFFF1F5F9)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(16)),
              child: const Icon(Icons.bluetooth_rounded, color: Color(0xFF64748B)),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: Color(0xFF1D2939))),
                  const SizedBox(height: 4),
                  Text(signal, style: const TextStyle(fontSize: 12, color: Color(0xFF94A3B8))),
                ],
              ),
            ),
            _buildActionButton('Connect', Icons.link_rounded, const Color(0xFF155EEF), Colors.white, () {}, hasBorder: false, isSmall: true),
          ],
        ),
      ),
    );
  }

  Widget _buildRobotCard({required String name, required bool isOnline, required String battery, required String signal, required String lastActive, required String type}) {
    return BouncingCard(
      onTap: () {},
      child: Container(
        margin: const EdgeInsets.only(bottom: 24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(28),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 20, offset: const Offset(0, 10))],
          border: Border.all(color: const Color(0xFFF1F5F9), width: 1.5),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          children: [
            // Top Image/Status Area
            Container(
              height: 140,
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: isOnline 
                      ? [const Color(0xFFEFF4FF), const Color(0xFFE0E7FF)] 
                      : [const Color(0xFFF1F5F9), const Color(0xFFE2E8F0)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Stack(
                children: [
                  Positioned(
                    right: -20, bottom: -20,
                    child: Icon(Icons.precision_manufacturing_rounded, size: 120, color: (isOnline ? const Color(0xFF155EEF) : const Color(0xFF64748B)).withValues(alpha: 0.1)),
                  ),
                  Center(
                    child: Icon(Icons.smart_toy_rounded, size: 64, color: isOnline ? const Color(0xFF155EEF) : const Color(0xFF94A3B8)),
                  ),
                  Positioned(
                    top: 16, right: 16,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 8, offset: const Offset(0, 2))],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 8, height: 8,
                            decoration: BoxDecoration(color: isOnline ? const Color(0xFF10B981) : const Color(0xFF94A3B8), shape: BoxShape.circle),
                          ),
                          const SizedBox(width: 6),
                          Text(isOnline ? 'ONLINE' : 'OFFLINE', style: TextStyle(color: isOnline ? const Color(0xFF10B981) : const Color(0xFF64748B), fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 0.5)),
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 16, left: 16,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(color: const Color(0xFF1D2939).withValues(alpha: 0.6), borderRadius: BorderRadius.circular(12)),
                      child: Text(type, style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ),
            
            // Bottom Info Area
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: Color(0xFF1D2939), letterSpacing: -0.5)),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildStat(Icons.battery_charging_full_rounded, battery),
                      _buildStat(Icons.wifi_rounded, signal),
                      _buildStat(Icons.history_rounded, lastActive),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: _buildActionButton(
                          'Control',
                          Icons.gamepad_rounded,
                          isOnline ? const Color(0xFF155EEF) : const Color(0xFFF1F5F9),
                          isOnline ? Colors.white : const Color(0xFF94A3B8),
                          () { if (isOnline) context.go('/control'); }
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildActionButton(
                          'Details',
                          Icons.settings_rounded,
                          Colors.white,
                          const Color(0xFF64748B),
                          () {},
                          hasBorder: true,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStat(IconData icon, String value) {
    return Row(
      children: [
        Icon(icon, size: 16, color: const Color(0xFF94A3B8)),
        const SizedBox(width: 6),
        Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF475467))),
      ],
    );
  }

  Widget _buildActionButton(String label, IconData icon, Color bgColor, Color textColor, VoidCallback onTap, {bool hasBorder = false, bool isSmall = false}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: isSmall ? 8 : 14, horizontal: isSmall ? 16 : 0),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(16),
          border: hasBorder ? Border.all(color: const Color(0xFFE2E8F0)) : null,
          boxShadow: bgColor != Colors.white && bgColor != const Color(0xFFF1F5F9) 
              ? [BoxShadow(color: bgColor.withValues(alpha: 0.3), blurRadius: 12, offset: const Offset(0, 4))] 
              : [],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: textColor, size: isSmall ? 14 : 18),
            const SizedBox(width: 8),
            Text(label, style: TextStyle(color: textColor, fontSize: isSmall ? 12 : 14, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}
