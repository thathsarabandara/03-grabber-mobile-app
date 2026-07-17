import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import '../../../core/network/api_client.dart';
import '../../robots/services/robot_service.dart';
import '../../../widgets/premium_widgets.dart';
import '../services/ble_service.dart';

class ManualControlScreen extends StatefulWidget {
  final String? robotId;
  const ManualControlScreen({super.key, this.robotId});

  @override
  State<ManualControlScreen> createState() => _ManualControlScreenState();
}

class _ManualControlScreenState extends State<ManualControlScreen> with TickerProviderStateMixin {
  late AnimationController _animController;
  bool _showJointPanel = false;
  
  final BleService _bleService = BleService();
  final RobotService _robotService = RobotService();

  // Robot mapping & status
  String? _robotDbId;
  String? _robotStrId;
  String _robotStatus = 'OFFLINE';
  WebSocket? _webSocket;
  double _velocity = 50.0;
  DateTime? _lastInternetSendTime;

  // Joystick Offsets
  Offset _leftJoyOffset = Offset.zero;
  Offset _rightJoyOffset = Offset.zero;
  Timer? _joystickTimer;
  bool _isProcessingJoystick = false;

  // Joint Values (Aligned with Firmware Config.h)
  double _j1 = 90; // Base: min 1, max 180
  double _j2 = 100; // Shoulder: min 50, max 150
  double _j3 = 60; // Elbow: min 20, max 100
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

    _fetchAndSelectRobot();

    if (_activeNetwork == 'BLE') {
      _bleService.connect();
    }

    // Process joystick inputs at 20Hz (every 50ms)
    _joystickTimer = Timer.periodic(const Duration(milliseconds: 50), (_) => _processJoystickInput());
  }

  Future<void> _fetchAndSelectRobot() async {
    try {
      final robots = await _robotService.getRobots();
      if (mounted) {
        setState(() {
          final match = robots.firstWhere(
            (r) => r['id'] == widget.robotId || r['robot_id'] == widget.robotId,
            orElse: () => robots.isNotEmpty ? robots.first : null,
          );

          if (match != null) {
            _robotDbId = match['id'];
            _robotStrId = match['robot_id'];
            _robotStatus = match['status'] ?? 'OFFLINE';
          }
        });
        
        if (_activeNetwork == 'NET') {
          _connectWebSocket();
        }
      }
    } catch (e) {
      print("Error fetching robot in ManualControl: $e");
    }
  }

  void _connectWebSocket() {
    _webSocket?.close();
    _webSocket = null;
    
    final wsUrl = ApiClient.baseUrl.replaceFirst('http', 'ws') + '/robots/ws';
    print("[WS] Connecting to: $wsUrl");
    
    WebSocket.connect(wsUrl).then((ws) {
      if (!mounted) {
        ws.close();
        return;
      }
      
      _webSocket = ws;
      print("[WS] Connected to gateway.");
      
      ws.listen(
        (data) {
          try {
            final message = jsonDecode(data);
            print("[WS Message]: $message");
            if (message['robotId'] == _robotStrId && mounted) {
              setState(() {
                _robotStatus = message['status'] ?? 'OFFLINE';
              });
            }
          } catch (e) {
            print("[WS] JSON parse error: $e");
          }
        },
        onError: (err) {
          print("[WS] Error: $err");
          _reconnectWebSocket();
        },
        onDone: () {
          print("[WS] Connection closed.");
          _reconnectWebSocket();
        },
      );
    }).catchError((err) {
      print("[WS] Connection failed: $err");
      _reconnectWebSocket();
    });
  }

  void _reconnectWebSocket() {
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted && _activeNetwork == 'NET') {
        _connectWebSocket();
      }
    });
  }

  @override
  void dispose() {
    _webSocket?.close();
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
    double maxChange = (_velocity / 100.0) * 4.0; // up to 4 degrees per tick at 100% velocity

    // Right Joystick: Base (dx) & Shoulder (dy)
    if (_rightJoyOffset != Offset.zero) {
      double dx = _rightJoyOffset.dx / 40.0; // range: -1 to +1
      double dy = _rightJoyOffset.dy / 40.0; // range: -1 to +1

      double newJ1 = (_j1 + (dx * maxChange)).clamp(1.0, 180.0);
      double newJ2 = (_j2 - (dy * maxChange)).clamp(50.0, 150.0); // Invert so Up = Forward

      if ((newJ1 - _j1).abs() > 0.1) { _j1 = newJ1; sendJ1 = true; }
      if ((newJ2 - _j2).abs() > 0.1) { _j2 = newJ2; sendJ2 = true; }
    }

    // Left Joystick: Grip (dx) & Elbow (dy)
    if (_leftJoyOffset != Offset.zero) {
      double dx = _leftJoyOffset.dx / 40.0; // range: -1 to +1
      double dy = _leftJoyOffset.dy / 40.0; // range: -1 to +1
      
      double newJ4 = (_j4 + (dx * maxChange)).clamp(70.0, 100.0); // Left/Right for Grip
      double newJ3 = (_j3 - (dy * maxChange)).clamp(20.0, 100.0); // Invert so Up = Forward
      
      if ((newJ3 - _j3).abs() > 0.1) { _j3 = newJ3; sendJ3 = true; }
      if ((newJ4 - _j4).abs() > 0.1) { _j4 = newJ4; sendJ4 = true; }
    }

    if (sendJ1 || sendJ2 || sendJ3 || sendJ4) {
      setState(() {});
      if (_activeNetwork == 'BLE') {
        await _bleService.sendAllJointsCommand(_j1, _j2, _j3, _j4);
      } else if (_activeNetwork == 'NET') {
        _sendInternetJointsThrottled(sendJ1, sendJ2, sendJ3, sendJ4);
      }
    }
    _isProcessingJoystick = false;
  }

  void _sendInternetJointsThrottled(bool sendJ1, bool sendJ2, bool sendJ3, bool sendJ4) {
    final now = DateTime.now();
    if (_lastInternetSendTime == null || now.difference(_lastInternetSendTime!) >= const Duration(milliseconds: 150)) {
      _lastInternetSendTime = now;
      
      final dbId = _robotDbId;
      if (dbId == null) return;

      if (sendJ1) _robotService.sendMoveJointCommand(dbId, 'j1', _j1).catchError((_) {});
      if (sendJ2) _robotService.sendMoveJointCommand(dbId, 'j2', _j2).catchError((_) {});
      if (sendJ3) _robotService.sendMoveJointCommand(dbId, 'j3', _j3).catchError((_) {});
      if (sendJ4) _robotService.sendMoveJointCommand(dbId, 'j4', _j4).catchError((_) {});
    }
  }

  Future<void> _sendJointMoveCommand(String jointName, int servoIdx, double val) async {
    if (_activeNetwork == 'BLE') {
      await _bleService.sendJointCommand(servoIdx, val);
    } else if (_activeNetwork == 'NET') {
      final dbId = _robotDbId;
      if (dbId != null) {
        try {
          await _robotService.sendMoveJointCommand(dbId, jointName, val);
        } catch (e) {
          print("Error moving joint: $e");
        }
      }
    }
  }

  Future<void> _handleHome() async {
    if (_activeNetwork == 'BLE') {
      setState(() {
        _j1 = 90;
        _j2 = 100;
        _j3 = 60;
        _j4 = 90;
      });
      await _bleService.sendAllJointsCommand(90, 100, 60, 90);
    } else if (_activeNetwork == 'NET') {
      final dbId = _robotDbId;
      if (dbId != null) {
        try {
          await _robotService.sendHomeCommand(dbId);
          setState(() {
            _j1 = 90;
            _j2 = 100;
            _j3 = 60;
            _j4 = 90;
          });
        } catch (e) {
          print("Error homing robot: $e");
        }
      }
    }
  }

  Future<void> _handleEmergencyStop() async {
    if (_activeNetwork == 'BLE') {
      setState(() {
        _robotStatus = 'EMERGENCY_STOP';
      });
    } else if (_activeNetwork == 'NET') {
      final dbId = _robotDbId;
      if (dbId != null) {
        try {
          await _robotService.sendEmergencyStopCommand(dbId);
        } catch (e) {
          print("Error triggering E-Stop: $e");
        }
      }
    }
  }

  Future<void> _handleClearEstop() async {
    if (_activeNetwork == 'BLE') {
      setState(() {
        _robotStatus = 'IDLE';
      });
    } else if (_activeNetwork == 'NET') {
      final dbId = _robotDbId;
      if (dbId != null) {
        try {
          await _robotService.sendClearEmergencyStopCommand(dbId);
        } catch (e) {
          print("Error clearing E-Stop: $e");
        }
      }
    }
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
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Text(
                                  'Live HUD',
                                  style: TextStyle(color: Color(0xFF1D2939), fontSize: 22, fontWeight: FontWeight.w900, letterSpacing: -0.5),
                                ),
                                Row(
                                  children: [
                                    Container(
                                      width: 8, height: 8,
                                      decoration: BoxDecoration(
                                        color: _robotStatus.toLowerCase() == 'emergency_stop' ? Colors.red :
                                               _robotStatus.toLowerCase() == 'moving' ? Colors.blue :
                                               _robotStatus.toLowerCase() == 'idle' ? Colors.green :
                                               _robotStatus.toLowerCase() == 'offline' ? Colors.grey : Colors.orange,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      'Status: ${_robotStatus.toUpperCase()}',
                                      style: TextStyle(
                                        color: _robotStatus.toLowerCase() == 'emergency_stop' ? Colors.red.shade700 :
                                               _robotStatus.toLowerCase() == 'moving' ? Colors.blue.shade700 :
                                               _robotStatus.toLowerCase() == 'idle' ? Colors.green.shade700 : Colors.grey.shade600,
                                        fontSize: 10,
                                        fontWeight: FontWeight.w900,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
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
                        _buildActionButton(Icons.home_rounded, const Color(0xFF155EEF), _handleHome),
                        const SizedBox(width: 16),
                        _buildActionButton(Icons.lock_open_rounded, const Color(0xFF64748B), _handleClearEstop),
                        const SizedBox(width: 16),
                        _buildActionButton(Icons.warning_rounded, const Color(0xFFEF4444), _handleEmergencyStop),
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
          child: SingleChildScrollView(
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
                _buildSlider('Base', _j1, 1, 180, (v) {
                  setState(() => _j1 = v);
                  _sendJointMoveCommand('j1', 0, v);
                }),
                const SizedBox(height: 16),
                _buildSlider('Shoulder', _j2, 50, 150, (v) {
                  setState(() => _j2 = v);
                  _sendJointMoveCommand('j2', 1, v);
                }),
                const SizedBox(height: 16),
                _buildSlider('Elbow', _j3, 20, 100, (v) {
                  setState(() => _j3 = v);
                  _sendJointMoveCommand('j3', 2, v);
                }),
                const SizedBox(height: 16),
                _buildSlider('Wrist', _j4, 70, 100, (v) {
                  setState(() => _j4 = v);
                  _sendJointMoveCommand('j4', 3, v);
                }),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Gripper', style: TextStyle(color: Color(0xFF64748B), fontSize: 14, fontWeight: FontWeight.w800)),
                    Row(
                      children: [
                        _buildGripperButton('OPEN', Icons.radio_button_unchecked, _j4 <= 75),
                        const SizedBox(width: 8),
                        _buildGripperButton('CLOSE', Icons.radio_button_checked, _j4 > 75),
                      ],
                    )
                  ],
                ),
                const SizedBox(height: 24),
                const Divider(color: Color(0xFFE2E8F0)),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Velocity Scale', style: TextStyle(color: Color(0xFF1D2939), fontSize: 14, fontWeight: FontWeight.w700)),
                    Text('${_velocity.toInt()}%', style: const TextStyle(color: Color(0xFF155EEF), fontSize: 12, fontWeight: FontWeight.w900)),
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
                  child: Slider(
                    value: _velocity,
                    min: 10,
                    max: 100,
                    divisions: 9,
                    onChanged: (v) {
                      setState(() => _velocity = v);
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGripperButton(String label, IconData icon, bool active) {
    return GestureDetector(
      onTap: () {
        if (label == 'OPEN') {
          setState(() => _j4 = 70);
          _sendJointMoveCommand('j4', 3, 70);
        } else if (label == 'CLOSE') {
          setState(() => _j4 = 100);
          _sendJointMoveCommand('j4', 3, 100);
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

  Widget _buildSlider(String label, double value, double min, double max, ValueChanged<double> onChanged) {
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
          child: Slider(value: value, min: min, max: max, onChanged: onChanged),
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
            setState(() {
              _activeNetwork = 'BLE';
              _robotStatus = 'OFFLINE';
            });
            _webSocket?.close();
            _webSocket = null;
            _bleService.connect();
          }),
          _buildToggleOption('NET', Icons.wifi_rounded, _activeNetwork == 'NET', () {
            setState(() {
              _activeNetwork = 'NET';
            });
            _bleService.disconnect();
            _connectWebSocket();
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
