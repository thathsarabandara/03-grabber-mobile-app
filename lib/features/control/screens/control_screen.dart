import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../widgets/custom_button.dart';

class ControlScreen extends StatefulWidget {
  const ControlScreen({super.key});

  @override
  State<ControlScreen> createState() => _ControlScreenState();
}

class _ControlScreenState extends State<ControlScreen> {
  double _baseAngle = 90;
  double _shoulderAngle = 45;
  double _elbowAngle = 135;
  double _gripperAngle = 0;

  bool _joystickMode = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Live Control'),
        actions: [
          IconButton(
            icon: Icon(_joystickMode ? LucideIcons.sliders : LucideIcons.gamepad2),
            onPressed: () {
              setState(() {
                _joystickMode = !_joystickMode;
              });
            },
          ),
          IconButton(
            icon: const Icon(LucideIcons.mic),
            onPressed: () => context.push('/ai-control'),
          ),
        ],
      ),
      body: Column(
        children: [
          // Live Visualization Placeholder
          Container(
            height: 250,
            width: double.infinity,
            color: theme.colorScheme.surface,
            child: Stack(
              children: [
                Center(
                  child: Icon(
                    LucideIcons.camera,
                    size: 64,
                    color: theme.colorScheme.onSurfaceVariant.withOpacity(0.3),
                  ),
                ),
                Positioned(
                  top: 16,
                  left: 16,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.black54,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Row(
                      children: [
                        Icon(LucideIcons.radio, size: 16, color: AppTheme.success),
                        SizedBox(width: 8),
                        Text('LIVE', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Action Buttons
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildActionButton(context, LucideIcons.home, 'Home', () {}),
                _buildActionButton(context, LucideIcons.save, 'Save Pose', () {}),
                _buildActionButton(context, LucideIcons.play, 'Replay', () {}),
                _buildActionButton(context, LucideIcons.alertOctagon, 'E-Stop', () {}, isDanger: true),
              ],
            ),
          ),
          const Divider(),
          // Controls
          Expanded(
            child: _joystickMode ? _buildJoystickMode(theme) : _buildSliderMode(theme),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(BuildContext context, IconData icon, String label, VoidCallback onPressed, {bool isDanger = false}) {
    final color = isDanger ? AppTheme.danger : Theme.of(context).colorScheme.primary;
    return Column(
      children: [
        IconButton(
          onPressed: onPressed,
          icon: Icon(icon, color: color),
          style: IconButton.styleFrom(
            backgroundColor: color.withOpacity(0.1),
            padding: const EdgeInsets.all(12),
          ),
        ),
        const SizedBox(height: 4),
        Text(label, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: color, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildSliderMode(ThemeData theme) {
    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        _buildJointSlider('Base', _baseAngle, 0, 180, (v) => setState(() => _baseAngle = v)),
        _buildJointSlider('Shoulder', _shoulderAngle, 0, 180, (v) => setState(() => _shoulderAngle = v)),
        _buildJointSlider('Elbow', _elbowAngle, 0, 180, (v) => setState(() => _elbowAngle = v)),
        _buildJointSlider('Gripper', _gripperAngle, 0, 100, (v) => setState(() => _gripperAngle = v)),
      ],
    );
  }

  Widget _buildJointSlider(String name, double value, double min, double max, ValueChanged<double> onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
            Text('${value.toInt()}°', style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.primaryBlue)),
          ],
        ),
        Slider(
          value: value,
          min: min,
          max: max,
          onChanged: onChanged,
        ),
      ],
    );
  }

  Widget _buildJoystickMode(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 200,
            height: 200,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: theme.colorScheme.surface,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  spreadRadius: 5,
                )
              ],
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                const Icon(LucideIcons.arrowUp, size: 24, color: AppTheme.textSecondaryLight),
                const Positioned(bottom: 16, child: Icon(LucideIcons.arrowDown, size: 24, color: AppTheme.textSecondaryLight)),
                const Positioned(left: 16, child: Icon(LucideIcons.arrowLeft, size: 24, color: AppTheme.textSecondaryLight)),
                const Positioned(right: 16, child: Icon(LucideIcons.arrowRight, size: 24, color: AppTheme.textSecondaryLight)),
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppTheme.primaryBlue,
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.primaryBlue.withOpacity(0.5),
                        blurRadius: 10,
                        spreadRadius: 2,
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          Text('Virtual Joystick Mode', style: theme.textTheme.titleMedium),
          const SizedBox(height: 8),
          const Text('Drag to control Base and Shoulder'),
        ],
      ),
    );
  }
}
