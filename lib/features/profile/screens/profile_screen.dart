import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../../../widgets/premium_widgets.dart';
import '../../auth/providers/auth_provider.dart';
import '../../../core/services/biometric_service.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  String _theme = 'System';
  String _language = 'English';
  bool _biometricsEnabled = false;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(vsync: this, duration: const Duration(milliseconds: 1000));
    _animController.forward();
    _loadBiometricPreference();
  }

  Future<void> _loadBiometricPreference() async {
    final enabled = await ref.read(authProvider.notifier).isBiometricsEnabled();
    setState(() {
      _biometricsEnabled = enabled;
    });
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    try {
      final XFile? image = await picker.pickImage(source: ImageSource.gallery);
      if (image != null && mounted) {
        final success = await ref.read(authProvider.notifier).uploadProfileImage(image.path);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(success ? 'Profile picture updated!' : 'Failed to update profile picture'),
              backgroundColor: success ? Colors.green : Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Error picking image'), backgroundColor: Colors.red));
      }
    }
  }

  void _showThemeDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Select Theme', style: TextStyle(fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: ['System', 'Light', 'Dark'].map((theme) => ListTile(
            title: Text(theme),
            trailing: _theme == theme ? const Icon(Icons.check, color: Color(0xFF155EEF)) : null,
            onTap: () {
              setState(() => _theme = theme);
              context.pop();
            },
          )).toList(),
        ),
      ),
    );
  }

  void _showLanguageDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Select Language', style: TextStyle(fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: ['English', 'Spanish', 'French', 'German'].map((lang) => ListTile(
            title: Text(lang),
            trailing: _language == lang ? const Icon(Icons.check, color: Color(0xFF155EEF)) : null,
            onTap: () {
              setState(() => _language = lang);
              context.pop();
            },
          )).toList(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final user = authState.user;
    
    // Fallback info if user is null for some reason
    final firstName = user?['first_name'] ?? 'John';
    final lastName = user?['last_name'] ?? 'Doe';
    final fullName = '$firstName $lastName';
    final role = user?['role'] ?? 'Chief Operator';
    final profileImageUrl = user?['profile_image'];

    // Define API base URL for image construction
    const baseUrl = 'http://192.168.1.100:8000';
    final fullImageUrl = profileImageUrl != null ? '$baseUrl$profileImageUrl' : null;

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
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'Profile',
                        style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.w900, letterSpacing: -1.0),
                      ),
                    ],
                  ),
                ),
                
                Expanded(
                  child: SingleChildScrollView(
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Container(
                          width: double.infinity,
                          margin: const EdgeInsets.only(top: 50),
                          decoration: const BoxDecoration(
                            color: Color(0xFFF8FAFC),
                            borderRadius: BorderRadius.only(topLeft: Radius.circular(40), topRight: Radius.circular(40)),
                            boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 30, offset: Offset(0, -10))],
                          ),
                          child: Column(
                            children: [
                              const SizedBox(height: 140),
                              _buildSection('Account', 0.2, [
                                _buildListTile(Icons.person_outline_rounded, 'Edit Profile', const Color(0xFF155EEF), onTap: () {
                                  context.push('/edit-profile');
                                }),
                                _buildListTile(Icons.lock_outline_rounded, 'Security', const Color(0xFFF59E0B), onTap: () {
                                  context.push('/change-password');
                                }),
                                _buildListTile(Icons.devices_rounded, 'Active Sessions', const Color(0xFFEC4899), onTap: () {
                                  context.push('/sessions');
                                }),
                              ]),
                              _buildSection('Fleet Settings', 0.3, [
                                _buildListTile(Icons.precision_manufacturing_outlined, 'Manage Robots', const Color(0xFF10B981), onTap: () {
                                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Manage Robots task initiated')));
                                }),
                                _buildListTile(Icons.add_circle_outline_rounded, 'Pair New Device', const Color(0xFF8B5CF6), onTap: () {
                                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Pairing New Device process started')));
                                }),
                              ]),
                              _buildSection('App Preferences', 0.4, [
                                _buildListTile(Icons.dark_mode_outlined, 'Theme', const Color(0xFF64748B), trailing: _theme, onTap: _showThemeDialog),
                                _buildListTile(Icons.language_rounded, 'Language', const Color(0xFF64748B), trailing: _language, onTap: _showLanguageDialog),
                                _buildBiometricTile(context),
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
                                      onPressed: () {
                                        ref.read(authProvider.notifier).logout();
                                        context.go('/welcome');
                                      },
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
                              const SizedBox(height: 120),
                            ],
                          ),
                        ),
                        Positioned(
                          top: 0,
                          left: 0,
                          right: 0,
                          child: SlideFade(
                            animation: _animController,
                            delay: 0.1,
                            child: Column(
                              children: [
                                Stack(
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
                                        child: fullImageUrl != null
                                            ? ClipOval(
                                                child: Image.network(
                                                  fullImageUrl,
                                                  width: 100,
                                                  height: 100,
                                                  fit: BoxFit.cover,
                                                  errorBuilder: (context, error, stackTrace) => 
                                                    const Icon(Icons.person_rounded, size: 50, color: Color(0xFF155EEF)),
                                                ),
                                              )
                                            : const Icon(Icons.person_rounded, size: 50, color: Color(0xFF155EEF)),
                                      ),
                                    ),
                                    Positioned(
                                      bottom: 0,
                                      right: 0,
                                      child: GestureDetector(
                                        onTap: _pickImage,
                                        child: Container(
                                          padding: const EdgeInsets.all(8),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFF155EEF),
                                            shape: BoxShape.circle,
                                            border: Border.all(color: Colors.white, width: 2),
                                          ),
                                          child: const Icon(Icons.camera_alt_rounded, color: Colors.white, size: 16),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                Text(fullName, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 28, color: Color(0xFF1D2939), letterSpacing: -0.5)),
                                const SizedBox(height: 4),
                                Text(role, style: const TextStyle(color: Color(0xFF155EEF), fontWeight: FontWeight.w700, fontSize: 14)),
                              ],
                            ),
                          ),
                        ),
                      ],
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
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: Material(
                  type: MaterialType.transparency,
                  child: Column(children: children),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBiometricTile(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: const Color(0xFF155EEF).withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(Icons.fingerprint_rounded, color: Color(0xFF155EEF), size: 22),
      ),
      title: const Text('Biometric Login', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16, color: Color(0xFF1D2939))),
      trailing: Switch.adaptive(
        value: _biometricsEnabled,
        activeColor: const Color(0xFF155EEF),
        onChanged: (value) async {
          if (value) {
            final isSupported = await BiometricService.isBiometricSupported();
            final hasEnrolled = await BiometricService.hasEnrolledBiometrics();
            if (!isSupported || !hasEnrolled) {
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Biometrics not supported or setup on this device.')),
                );
              }
              return;
            }

            final authenticated = await BiometricService.authenticate(
              localizedReason: 'Confirm biometrics to enable quick login',
            );
            if (authenticated) {
              await ref.read(authProvider.notifier).setBiometricsEnabled(true);
              setState(() {
                _biometricsEnabled = true;
              });
            } else {
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Verification failed. Biometric login not enabled.')),
                );
              }
            }
          } else {
            await ref.read(authProvider.notifier).setBiometricsEnabled(false);
            setState(() {
              _biometricsEnabled = false;
            });
          }
        },
      ),
    );
  }

  Widget _buildListTile(IconData icon, String title, Color iconColor, {String? trailing, VoidCallback? onTap}) {
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
      onTap: onTap ?? () {},
    );
  }
}
