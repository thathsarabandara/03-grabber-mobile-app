import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../widgets/premium_widgets.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animController;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(vsync: this, duration: const Duration(milliseconds: 1000));
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
            top: 0, left: 0, right: 0, height: 350,
            child: CustomPaint(painter: HeaderWavePainter()),
          ),
          
          SafeArea(
            bottom: false,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 16, 24, 40),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Profile',
                        style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.w900, letterSpacing: -1.0),
                      ),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
                        ),
                        child: IconButton(
                          icon: const Icon(Icons.settings_rounded, color: Colors.white),
                          onPressed: () {},
                        ),
                      ),
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
                        padding: const EdgeInsets.only(bottom: 60),
                        child: Column(
                          children: [
                            // Avatar overlapping the top
                            Transform.translate(
                              offset: const Offset(0, -50),
                              child: SlideFade(
                                animation: _animController,
                                delay: 0.1,
                                child: Column(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(6),
                                      decoration: const BoxDecoration(
                                        color: Colors.white,
                                        shape: BoxShape.circle,
                                      ),
                                      child: Container(
                                        width: 100, height: 100,
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFEFF4FF),
                                          shape: BoxShape.circle,
                                          border: Border.all(color: const Color(0xFFEEF2F6), width: 1),
                                        ),
                                        child: const Icon(Icons.person_rounded, size: 50, color: Color(0xFF155EEF)),
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    const Text('John Doe', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 28, color: Color(0xFF1D2939), letterSpacing: -0.5)),
                                    const SizedBox(height: 4),
                                    const Text('Chief Operator', style: TextStyle(color: Color(0xFF155EEF), fontWeight: FontWeight.w700, fontSize: 14)),
                                  ],
                                ),
                              ),
                            ),
                            
                            // Transform shifted content up since we pushed the avatar up
                            Transform.translate(
                              offset: const Offset(0, -20),
                              child: Column(
                                children: [
                                  _buildSection('Account', 0.2, [
                                    _buildListTile(Icons.person_outline_rounded, 'Edit Profile', const Color(0xFF155EEF)),
                                    _buildListTile(Icons.lock_outline_rounded, 'Security', const Color(0xFFF59E0B)),
                                  ]),
                                  _buildSection('Fleet Settings', 0.3, [
                                    _buildListTile(Icons.precision_manufacturing_outlined, 'Manage Robots', const Color(0xFF10B981)),
                                    _buildListTile(Icons.add_circle_outline_rounded, 'Pair New Device', const Color(0xFF8B5CF6)),
                                  ]),
                                  _buildSection('App Preferences', 0.4, [
                                    _buildListTile(Icons.dark_mode_outlined, 'Theme', const Color(0xFF64748B), trailing: 'System'),
                                    _buildListTile(Icons.language_rounded, 'Language', const Color(0xFF64748B), trailing: 'English'),
                                  ]),
                                  
                                  const SizedBox(height: 24),
                                  SlideFade(
                                    animation: _animController,
                                    delay: 0.5,
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 24),
                                      child: SizedBox(
                                        width: double.infinity,
                                        height: 60,
                                        child: TextButton.icon(
                                          onPressed: () => context.go('/welcome'),
                                          icon: const Icon(Icons.logout_rounded, color: Color(0xFFEF4444)),
                                          label: const Text('Sign Out', style: TextStyle(color: Color(0xFFEF4444), fontWeight: FontWeight.w800, fontSize: 16)),
                                          style: TextButton.styleFrom(
                                            backgroundColor: const Color(0xFFFEF2F2),
                                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
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

  Widget _buildSection(String title, double delay, List<Widget> children) {
    return SlideFade(
      animation: _animController,
      delay: delay,
      child: Padding(
        padding: const EdgeInsets.only(left: 24, right: 24, bottom: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 8, bottom: 12),
              child: Text(
                title.toUpperCase(),
                style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 12, fontWeight: FontWeight.w800, letterSpacing: 1.5),
              ),
            ),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 10, offset: const Offset(0, 4))],
                border: Border.all(color: const Color(0xFFF1F5F9), width: 1.5),
              ),
              child: Column(children: children),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildListTile(IconData icon, String title, Color iconColor, {String? trailing}) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: iconColor.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: iconColor, size: 22),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16, color: Color(0xFF1D2939))),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (trailing != null) ...[
            Text(trailing, style: const TextStyle(color: Color(0xFF64748B), fontWeight: FontWeight.w600, fontSize: 14)),
            const SizedBox(width: 8),
          ],
          const Icon(Icons.arrow_forward_ios_rounded, size: 16, color: Color(0xFFCBD5E1)),
        ],
      ),
      onTap: () {},
    );
  }
}
