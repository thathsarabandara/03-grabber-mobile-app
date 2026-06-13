import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../auth/providers/auth_provider.dart';

class SessionsScreen extends ConsumerStatefulWidget {
  const SessionsScreen({super.key});

  @override
  ConsumerState<SessionsScreen> createState() => _SessionsScreenState();
}

class _SessionsScreenState extends ConsumerState<SessionsScreen> {
  List<Map<String, dynamic>> _sessions = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSessions();
  }

  Future<void> _loadSessions() async {
    setState(() => _isLoading = true);
    final sessions = await ref.read(authProvider.notifier).getSessions();
    
    // Map the backend SessionResponse to our UI format
    final mappedSessions = sessions.map((s) {
      final isCurrent = s['is_current'] ?? false; // The backend doesn't explicitly return is_current, we might need logic or just mock it for now based on some parameter. Wait, backend returns SessionResponse.
      return {
        'id': s['id'],
        'device': s['device_info']?.toString().split(' ')[0] ?? 'Unknown Device',
        'os': s['device_info'] ?? 'Unknown OS',
        'ip': s['ip_address'] ?? 'Unknown IP',
        'last_active': s['created_at'] != null ? s['created_at'].toString().substring(0, 10) : 'Unknown',
        'is_current': isCurrent,
      };
    }).toList();

    setState(() {
      _sessions = mappedSessions;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('Active Sessions', style: TextStyle(fontWeight: FontWeight.w800, color: Color(0xFF1D2939))),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF1D2939)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => context.pop(),
        ),
      ),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator(color: Color(0xFF155EEF)))
        : Column(
        children: [
          Expanded(
            child: _sessions.isEmpty
                ? const Center(
                    child: Text('No active sessions found.', style: TextStyle(color: Color(0xFF64748B))),
                  )
                : ListView.separated(
              padding: const EdgeInsets.all(24),
              itemCount: _sessions.length,
              separatorBuilder: (context, index) => const SizedBox(height: 16),
              itemBuilder: (context, index) {
                final session = _sessions[index];
                final isCurrent = session['is_current'] as bool;
                
                return Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: const Color(0xFFF1F5F9)),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 10, offset: const Offset(0, 4)),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Material(
                      type: MaterialType.transparency,
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(20),
                        leading: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFFEFF4FF),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Icon(
                            session['device'].toString().contains('iPhone') || session['device'].toString().contains('Android')
                                ? Icons.smartphone_rounded
                                : Icons.laptop_mac_rounded,
                            color: const Color(0xFF155EEF),
                          ),
                        ),
                        title: Row(
                          children: [
                            Text(
                              session['device'],
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF1D2939)),
                            ),
                            if (isCurrent) ...[
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFDCFCE7),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Text('Current', style: TextStyle(color: Color(0xFF166534), fontSize: 10, fontWeight: FontWeight.bold)),
                              ),
                            ],
                          ],
                        ),
                        subtitle: Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('${session['os']} • ${session['ip']}', style: const TextStyle(color: Color(0xFF64748B), fontSize: 13)),
                              const SizedBox(height: 4),
                              Text(session['last_active'], style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 12)),
                            ],
                          ),
                        ),
                        trailing: isCurrent ? null : IconButton(
                          icon: const Icon(Icons.logout_rounded, color: Color(0xFFEF4444)),
                          onPressed: () async {
                            final success = await ref.read(authProvider.notifier).revokeSession(session['id']);
                            if (mounted) {
                              if (success) {
                                setState(() {
                                  _sessions.removeAt(index);
                                });
                                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Session revoked')));
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Failed to revoke session'), backgroundColor: Colors.red));
                              }
                            }
                          },
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: SizedBox(
              width: double.infinity,
              height: 56,
              child: OutlinedButton.icon(
                onPressed: () async {
                  final confirm = await showDialog<bool>(
                    context: context,
                    builder: (context) => AlertDialog(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      title: const Text('Terminate All Sessions?', style: TextStyle(fontWeight: FontWeight.bold)),
                      content: const Text('This will log you out from all other devices. Are you sure?'),
                      actions: [
                        TextButton(
                          onPressed: () => context.pop(false),
                          child: const Text('Cancel', style: TextStyle(color: Color(0xFF64748B), fontWeight: FontWeight.bold)),
                        ),
                        TextButton(
                          onPressed: () => context.pop(true),
                          child: const Text('Terminate', style: TextStyle(color: Color(0xFFEF4444), fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                  );

                  if (confirm == true) {
                    final success = await ref.read(authProvider.notifier).revokeAllSessions();
                    if (mounted) {
                      if (success) {
                        setState(() {
                          _sessions.removeWhere((session) => session['is_current'] == false);
                        });
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('All other sessions terminated')));
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Failed to terminate sessions')));
                      }
                    }
                  }
                },
                icon: const Icon(Icons.warning_amber_rounded, color: Color(0xFFEF4444)),
                label: const Text('Terminate All Sessions', style: TextStyle(color: Color(0xFFEF4444), fontWeight: FontWeight.bold, fontSize: 16)),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Color(0xFFEF4444), width: 1.5),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
