import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import '../../../widgets/premium_widgets.dart';
import '../services/ble_service.dart';

class ManualControlScreen extends StatefulWidget {
  const ManualControlScreen({super.key});

  @override
  State<ManualControlScreen> createState() => _ManualControlScreenState();
}

class _ManualControlScreenState extends State<ManualControlScreen> with TickerProviderStateMixin {
  late AnimationController _animController;
  bool _showJointPanel = false;
  
  final BleService _bleService = BleService();

  // Joystick Offsets
  Offset _leftJoyOffset = Offset.zero;
  Offset _rightJoyOffset = Offset.zero;
  Timer? _joystickTimer;
  bool _isProcessingJoystick = false;

  // Joint Values (Aligned with Firmware Config.h)
  double _j1 = 90; // Base: min 1, max 180
  double _j2 = 90; // Shoulder: min 40, max 120
  double _j3 = 50; // Elbow: min 20, max 80
  double _j4 = 90; // Gripper: min 70, max 100

  // Control Modes
  String _activeMode = 'MANUAL';
  String _activeNetwork = 'BLE';

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(vsync: this, duration: const Duration(milliseconds: 1000));
    _animController.forward();
    
    // Enforce Landscape Mode for Teleoperation HUD
    WidgetsBinding.instance.addPostFrameCallback((_) {
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.landscapeRight,
        DeviceOrientation.landscapeLeft,
      ]);
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    });

    if (_activeNetwork == 'BLE') {
      _bleService.connect();
    }

    // Process joystick inputs at 20Hz (every 50ms)
    _joystickTimer = Timer.periodic(const Duration(milliseconds: 50), (_) => _processJoystickInput());
  }

  @override
  void dispose() {
    _joystickTimer?.cancel();
    _animController.dispose();
    // Restore default orientations
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  Future<void> _processJoystickInput() async {
    if (_isProcessingJoystick) return;
    _isProcessingJoystick = true;

    bool sendJ1 = false, sendJ2 = false, sendJ3 = false, sendJ4 = false;

    // Right Joystick: Base (dx) & Shoulder (dy)
    if (_rightJoyOffset != Offset.zero) {
      double dx = _rightJoyOffset.dx / 40.0; // range: -1 to +1
      double dy = _rightJoyOffset.dy / 40.0; // range: -1 to +1

      double newJ1 = (_j1 + (dx * 2.0)).clamp(1.0, 180.0);
      double newJ2 = (_j2 - (dy * 2.0)).clamp(40.0, 120.0); // Invert so Up = Forward

      if ((newJ1 - _j1).abs() > 0.1) { _j1 = newJ1; sendJ1 = true; }
      if ((newJ2 - _j2).abs() > 0.1) { _j2 = newJ2; sendJ2 = true; }
    }

    // Left Joystick: Grip (dx) & Elbow (dy)
    if (_leftJoyOffset != Offset.zero) {
      double dx = _leftJoyOffset.dx / 40.0; // range: -1 to +1
      double dy = _leftJoyOffset.dy / 40.0; // range: -1 to +1
      
      double newJ4 = (_j4 + (dx * 2.0)).clamp(70.0, 100.0); // Left/Right for Grip
      double newJ3 = (_j3 - (dy * 2.0)).clamp(20.0, 80.0); // Invert so Up = Forward
      
      if ((newJ3 - _j3).abs() > 0.1) { _j3 = newJ3; sendJ3 = true; }
      if ((newJ4 - _j4).abs() > 0.1) { _j4 = newJ4; sendJ4 = true; }
    }

    if (sendJ1 || sendJ2 || sendJ3 || sendJ4) {
      setState(() {});
      await _bleService.sendAllJointsCommand(_j1, _j2, _j3, _j4);
    }
    _isProcessingJoystick = false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Stack(
        children: [
          // 1. Full-screen Camera Background Layer
          _buildCameraLayer(),

          // 2. Control UI Overlay (App Consistent Design)
          SafeArea(
            child: Stack(
              children: [
                // Top Bar - Matches Media/Profile Header Style
                Positioned(
                  top: 16, left: 24, right: 24,
                  child: SlideFade(
                    animation: _animController,
                    delay: 0.1,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            _buildHeaderIconButton(Icons.arrow_back_ios_new_rounded, () => context.pop()),
                            const SizedBox(width: 16),
                            const Text(
                              'Live HUD',
                              style: TextStyle(color: Color(0xFF1D2939), fontSize: 24, fontWeight: FontWeight.w900, letterSpacing: -0.5),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            _buildNetworkToggle(),
                            const SizedBox(width: 12),
                            _buildModeToggle(),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                
                // Left Joystick (Elbow / Grip)
                Positioned(
                  left: 40, bottom: 32,
                  child: SlideFade(
                    animation: _animController,
                    delay: 0.3,
                    child: _buildJoystick('ELBOW / GRIP', Icons.precision_manufacturing_rounded, _leftJoyOffset, 
                      (offset) => setState(() => _leftJoyOffset = offset),
                      () => setState(() => _leftJoyOffset = Offset.zero)
                    ),
                  ),
                ),
                
                // Right Joystick (Base / Shoulder)
                Positioned(
                  right: 40, bottom: 32,
                  child: SlideFade(
                    animation: _animController,
                    delay: 0.3,
                    child: _buildJoystick('BASE / SHOULDER', Icons.control_camera_rounded, _rightJoyOffset,
                      (offset) => setState(() => _rightJoyOffset = offset),
                      () => setState(() => _rightJoyOffset = Offset.zero)
                    ),
                  ),
                ),
                
                // Bottom Center: Action Bar (App Consistent Action Buttons)
                Positioned(
                  bottom: 24, left: 0, right: 0,
                  child: SlideFade(
                    animation: _animController,
                    delay: 0.4,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildActionButton(Icons.videocam_rounded, const Color(0xFF155EEF), () {}),
                        const SizedBox(width: 16),
                        _buildActionButton(Icons.auto_awesome_rounded, const Color(0xFF8B5CF6), () {}),
                        const SizedBox(width: 16),
                        _buildActionButton(Icons.warning_rounded, const Color(0xFFEF4444), () {}),
                        const SizedBox(width: 16),
                        _buildActionButton(
                          _showJointPanel ? Icons.close_rounded : Icons.tune_rounded, 
                          const Color(0xFF10B981),
                          () => setState(() => _showJointPanel = !_showJointPanel),
                        ),
                      ],
                    ),
                  ),
                ),

                // Joint Controls Overlay Panel (Toggled)
                if (_showJointPanel)
                  Positioned(
                    top: 80, right: 24, bottom: 24,
                    child: SlideFade(
                      animation: _animController,
                      delay: 0.0, // Instant when toggled
                      child: _buildJointPanel(),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCameraLayer() {
    return Positioned.fill(
      child: Stack(
        fit: StackFit.expand,
        children: [
          Container(
            color: const Color(0xFFF1F5F9), 
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.videocam_off_rounded, color: const Color(0xFF94A3B8).withValues(alpha: 0.5), size: 100),
                  const SizedBox(height: 16),
                  const Text(
                    'CAMERA FEED OFFLINE', 
                    style: TextStyle(color: Color(0xFF94A3B8), fontWeight: FontWeight.w800, letterSpacing: 2.0, fontSize: 16)
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderIconButton(IconData icon, VoidCallback onTap) {
    return BouncingCard(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 4))],
          border: Border.all(color: const Color(0xFFF1F5F9)),
        ),
        child: Icon(icon, color: const Color(0xFF1D2939), size: 22),
      ),
    );
  }

  Widget _buildActionButton(IconData icon, Color primaryColor, VoidCallback onTap) {
    return BouncingCard(
      onTap: onTap,
      child: Container(
        height: 56, width: 56,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [BoxShadow(color: primaryColor.withValues(alpha: 0.2), blurRadius: 15, offset: const Offset(0, 8))],
          border: Border.all(color: primaryColor.withValues(alpha: 0.1)),
        ),
        child: Icon(icon, color: primaryColor, size: 26), 
      ),
    );
  }

  Widget _buildJoystick(String label, IconData icon, Offset offset, ValueChanged<Offset> onChanged, VoidCallback onEnd) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: const Color(0xFF64748B), size: 16),
            const SizedBox(width: 8),
            Text(label, style: const TextStyle(color: Color(0xFF475467), fontSize: 13, fontWeight: FontWeight.w800, letterSpacing: 1.0)),
          ],
        ),
        const SizedBox(height: 16),
        GestureDetector(
          onPanUpdate: (details) {
            Offset newOffset = offset + details.delta;
            if (newOffset.distance > 40) {
              newOffset = Offset.fromDirection(newOffset.direction, 40);
            }
            onChanged(newOffset);
          },
          onPanEnd: (_) => onEnd(),
          child: Container(
            width: 150, height: 150,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withValues(alpha: 0.5),
              border: Border.all(color: Colors.white, width: 3),
              boxShadow: [
                BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 20, offset: const Offset(0, 10)),
              ]
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Transform.translate(
                  offset: offset,
                  child: Container(
                    width: 70, height: 70,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(color: const Color(0xFF155EEF).withValues(alpha: 0.2), blurRadius: 15, offset: const Offset(0, 8)),
                      ],
                      border: Border.all(color: const Color(0xFFF1F5F9), width: 2),
                    ),
                    child: const Center(
                      child: Icon(Icons.drag_indicator_rounded, color: Color(0xFF155EEF), size: 28),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildJointPanel() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(32),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: Container(
          width: 280,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.85), // Glassy white consistent with Dashboard
            borderRadius: BorderRadius.circular(32),
            border: Border.all(color: Colors.white, width: 2),
            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 30, offset: const Offset(0, 10))],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Row(
                children: [
                  Icon(Icons.precision_manufacturing_rounded, color: Color(0xFF155EEF), size: 24),
                  SizedBox(width: 8),
                  Text('Joint Controls', style: TextStyle(color: Color(0xFF1D2939), fontSize: 18, fontWeight: FontWeight.w900, letterSpacing: -0.5)),
                ],
              ),
              const SizedBox(height: 24),
              _buildSlider('Base', _j1, (v) { setState(() => _j1 = v); _bleService.sendJointCommand(0, v); }),
              const SizedBox(height: 16),
              _buildSlider('Shoulder', _j2, (v) { setState(() => _j2 = v); _bleService.sendJointCommand(1, v); }),
              const SizedBox(height: 16),
              _buildSlider('Elbow', _j3, (v) { setState(() => _j3 = v); _bleService.sendJointCommand(2, v); }),
              const SizedBox(height: 16),
              _buildSlider('Wrist', _j4, (v) { setState(() => _j4 = v); }), // Firmware doesn't support wrist yet
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Gripper', style: TextStyle(color: Color(0xFF64748B), fontSize: 14, fontWeight: FontWeight.w800)),
                  Row(
                    children: [
                      _buildGripperButton('OPEN', Icons.radio_button_unchecked, false),
                      const SizedBox(width: 8),
                      _buildGripperButton('CLOSE', Icons.radio_button_checked, true),
                    ],
                  )
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGripperButton(String label, IconData icon, bool active) {
    return GestureDetector(
      onTap: () {
        if (label == 'OPEN') {
          _bleService.sendJointCommand(3, 70); // Min Angle
        } else if (label == 'CLOSE') {
          _bleService.sendJointCommand(3, 100); // Max Angle
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: active ? const Color(0xFF155EEF) : const Color(0xFFEEF2F6),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Icon(icon, color: active ? Colors.white : const Color(0xFF64748B), size: 16),
          const SizedBox(width: 4),
          Text(label, style: TextStyle(color: active ? Colors.white : const Color(0xFF64748B), fontSize: 12, fontWeight: FontWeight.bold)),
        ],
      ),
    ),
    );
  }

  Widget _buildSlider(String label, double value, ValueChanged<double> onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(color: Color(0xFF1D2939), fontSize: 14, fontWeight: FontWeight.w700)),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
              decoration: BoxDecoration(color: const Color(0xFFEFF4FF), borderRadius: BorderRadius.circular(10)),
              child: Text('${value.toInt()}°', style: const TextStyle(color: Color(0xFF155EEF), fontSize: 12, fontWeight: FontWeight.w900)),
            ),
          ],
        ),
        const SizedBox(height: 8),
        SliderTheme(
          data: SliderThemeData(
            trackHeight: 6,
            activeTrackColor: const Color(0xFF155EEF),
            inactiveTrackColor: const Color(0xFFEEF2F6),
            thumbColor: Colors.white,
            overlayColor: const Color(0xFF155EEF).withValues(alpha: 0.1),
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 10),
            overlayShape: const RoundSliderOverlayShape(overlayRadius: 20),
          ),
          child: Slider(value: value, min: 0, max: 180, onChanged: onChanged),
        ),
      ],
    );
  }

  Widget _buildNetworkToggle() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 4))],
        border: Border.all(color: const Color(0xFFF1F5F9)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildToggleOption('BLE', Icons.bluetooth_rounded, _activeNetwork == 'BLE', () {
            setState(() => _activeNetwork = 'BLE');
            _bleService.connect();
          }),
          _buildToggleOption('NET', Icons.wifi_rounded, _activeNetwork == 'NET', () {
            setState(() => _activeNetwork = 'NET');
            _bleService.disconnect();
          }),
        ],
      ),
    );
  }

  Widget _buildModeToggle() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 4))],
        border: Border.all(color: const Color(0xFFF1F5F9)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildToggleOption('MANUAL', Icons.sports_esports_rounded, _activeMode == 'MANUAL', () => setState(() => _activeMode = 'MANUAL')),
          _buildToggleOption('ASSIST', Icons.smart_toy_rounded, _activeMode == 'ASSISTED', () => setState(() => _activeMode = 'ASSISTED')),
          _buildToggleOption('AUTO', Icons.route_rounded, _activeMode == 'AUTO', () => setState(() => _activeMode = 'AUTO')),
        ],
      ),
    );
  }

  Widget _buildToggleOption(String label, IconData icon, bool isActive, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? const Color(0xFF155EEF).withValues(alpha: 0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(icon, color: isActive ? const Color(0xFF155EEF) : const Color(0xFF64748B), size: 16),
            if (isActive) ...[
              const SizedBox(width: 6),
              Text(label, style: const TextStyle(color: Color(0xFF155EEF), fontSize: 13, fontWeight: FontWeight.w900, letterSpacing: -0.2)),
            ]
          ],
        ),
      ),
    );
  }
}
