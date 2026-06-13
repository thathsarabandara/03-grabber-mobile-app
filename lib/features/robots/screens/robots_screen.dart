import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../../widgets/premium_widgets.dart';
import '../../control/services/ble_service.dart';
import '../services/robot_service.dart';

class RobotsScreen extends StatefulWidget {
  const RobotsScreen({super.key});

  @override
  State<RobotsScreen> createState() => _RobotsScreenState();
}

class _RobotsScreenState extends State<RobotsScreen> with TickerProviderStateMixin {
  late AnimationController _animController;
  late TabController _tabController;
  List<ScanResult> _scanResults = [];
  bool _isScanning = false;
  Set<String> _connectingDevices = {};
  StreamSubscription<BluetoothAdapterState>? _adapterStateSubscription;
  BluetoothAdapterState _adapterState = BluetoothAdapterState.unknown;
  
  final RobotService _robotService = RobotService();
  List<dynamic> _cloudRobots = [];
  bool _isLoadingCloud = true;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(vsync: this, duration: const Duration(milliseconds: 1000));
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(_onTabChanged);
    _adapterStateSubscription = FlutterBluePlus.adapterState.listen((state) {
      if (mounted) setState(() => _adapterState = state);
    });
    _fetchCloudRobots();
    _animController.forward();
  }

  Future<void> _fetchCloudRobots() async {
    setState(() => _isLoadingCloud = true);
    try {
      final robots = await _robotService.getRobots();
      if (mounted) {
        setState(() {
          _cloudRobots = robots;
          _isLoadingCloud = false;
        });
      }
    } catch (e) {
      print("Error fetching cloud robots: $e");
      if (mounted) setState(() => _isLoadingCloud = false);
    }
  }

  void _onTabChanged() {
    if (_tabController.indexIsChanging) return;

    if (_tabController.index == 0) {
      _fetchCloudRobots();
    } else if (_tabController.index == 1) {
      _checkPermissionsAndScan();
    } else {
      FlutterBluePlus.stopScan();
      setState(() {
        _isScanning = false;
      });
    }
  }

  Future<void> _checkPermissionsAndScan() async {
    // 1. Check if Bluetooth is supported
    if (await FlutterBluePlus.isSupported == false) {
      print("Bluetooth not supported");
      return;
    }

    // 2. Request Android to turn on Bluetooth if it's off
    if (FlutterBluePlus.adapterStateNow != BluetoothAdapterState.on) {
      try {
        await FlutterBluePlus.turnOn();
      } catch (e) {
        print("Bluetooth could not be turned on: $e");
      }
    }

    // 3. Setup UI State
    setState(() {
      _isScanning = true;
      _scanResults.clear();
    });

    // 4. Listen to scan results
    FlutterBluePlus.scanResults.listen((results) {
      if (mounted) {
        setState(() {
          _scanResults = results;
        });
      }
    });

    // 5. Start scan (automatically handles Android permissions)
    try {
      await FlutterBluePlus.startScan(timeout: const Duration(seconds: 15));
    } catch (e) {
      print("Error starting scan: $e");
    } finally {
      if (mounted) {
        setState(() {
          _isScanning = false;
        });
      }
    }
  }

  Future<void> _connectToDevice(BluetoothDevice device) async {
    setState(() => _connectingDevices.add(device.remoteId.str));
    
    bool success = await BleService().connectToDevice(device);
    
    if (mounted) {
      setState(() => _connectingDevices.remove(device.remoteId.str));
      if (success) {
        context.go('/manual-control');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Failed to connect to device. Ensure it is in pairing mode.'),
          backgroundColor: Color(0xFFEF4444),
        ));
      }
    }
  }

  @override
  void dispose() {
    _adapterStateSubscription?.cancel();
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
                          onPressed: () {
                            if (_tabController.index == 0) {
                              _showAddCloudRobotDialog();
                            }
                          },
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
    if (_isLoadingCloud) {
      return const Center(child: CircularProgressIndicator(color: Color(0xFF155EEF)));
    }

    if (_cloudRobots.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.cloud_off_rounded, size: 64, color: const Color(0xFF94A3B8).withValues(alpha: 0.5)),
            const SizedBox(height: 16),
            const Text('No Internet Robots', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Color(0xFF1D2939))),
            const SizedBox(height: 8),
            const Text('You have not registered any cloud-connected robots yet.\nTap the + button above to pair one.', textAlign: TextAlign.center, style: TextStyle(fontSize: 13, color: Color(0xFF64748B))),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(24, 32, 24, 120),
      itemCount: _cloudRobots.length,
      itemBuilder: (context, index) {
        final robot = _cloudRobots[index];
        final isOnline = robot['status']?.toString().toLowerCase() == 'online' || robot['status']?.toString().toLowerCase() == 'active';
        final lastSeen = robot['last_seen'] != null ? DateTime.parse(robot['last_seen']).toLocal().toString().split('.')[0] : 'Never';
        
        return SlideFade(
          animation: _animController,
          delay: 0.2 + (index * 0.1),
          child: _buildRobotCard(
            id: robot['id'],
            name: robot['name'] ?? 'Robot Asset ${robot['robot_id']}',
            isOnline: isOnline,
            battery: 'N/A', // Assuming backend doesn't have battery yet
            signal: robot['firmware_version'] ?? 'FW: 1.0',
            lastActive: lastSeen,
            type: 'Cloud Connected',
            onDetails: () => _showRobotDetailsBottomSheet(robot),
          ),
        );
      },
    );
  }

  Future<void> _showAddCloudRobotDialog() async {
    final robotIdController = TextEditingController();
    final serialKeyController = TextEditingController();
    bool isPairing = false;
    String? errorText;

    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.transparent,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          title: const Text('Pair Cloud Robot', style: TextStyle(fontWeight: FontWeight.w900, color: Color(0xFF1D2939))),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (errorText != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12.0),
                  child: Text(errorText!, style: const TextStyle(color: Colors.red, fontSize: 12)),
                ),
              TextField(
                controller: robotIdController,
                style: const TextStyle(color: Color(0xFF1D2939), fontWeight: FontWeight.w600),
                decoration: InputDecoration(
                  labelText: 'Robot ID',
                  labelStyle: const TextStyle(color: Color(0xFF64748B)),
                  filled: true,
                  fillColor: const Color(0xFFF8FAFC),
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF155EEF), width: 2)),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: serialKeyController,
                style: const TextStyle(color: Color(0xFF1D2939), fontWeight: FontWeight.w600),
                decoration: InputDecoration(
                  labelText: 'Serial Key',
                  labelStyle: const TextStyle(color: Color(0xFF64748B)),
                  filled: true,
                  fillColor: const Color(0xFFF8FAFC),
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF155EEF), width: 2)),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel', style: TextStyle(color: Color(0xFF64748B), fontWeight: FontWeight.bold)),
            ),
            ElevatedButton(
              onPressed: isPairing
                  ? null
                  : () async {
                      if (robotIdController.text.isEmpty || serialKeyController.text.isEmpty) {
                        setDialogState(() => errorText = "Please fill in all fields");
                        return;
                      }
                      setDialogState(() {
                        isPairing = true;
                        errorText = null;
                      });
                      try {
                        await _robotService.pairRobot(robotIdController.text, serialKeyController.text);
                        Navigator.pop(context);
                        _fetchCloudRobots();
                      } catch (e) {
                        setDialogState(() {
                          isPairing = false;
                          errorText = e.toString();
                        });
                      }
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF155EEF),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: isPairing ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) : const Text('Pair'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBleTab() {
    if (_adapterState == BluetoothAdapterState.off) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.bluetooth_disabled_rounded, size: 64, color: Color(0xFFEF4444)),
            const SizedBox(height: 16),
            const Text('Bluetooth is Off', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Color(0xFF1D2939))),
            const SizedBox(height: 8),
            const Text('Please turn on Bluetooth to discover and connect to local robots.', textAlign: TextAlign.center, style: TextStyle(fontSize: 13, color: Color(0xFF64748B))),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => FlutterBluePlus.turnOn(),
              icon: const Icon(Icons.bluetooth_rounded),
              label: const Text('Turn On Bluetooth'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF155EEF),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
            )
          ],
        ),
      );
    }

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
                    child: _isScanning 
                      ? const CircularProgressIndicator(color: Color(0xFF155EEF))
                      : const Icon(Icons.bluetooth_searching_rounded, size: 40, color: Color(0xFF155EEF)),
                  ),
                  const SizedBox(height: 16),
                  Text(_isScanning ? 'Scanning for Robots...' : 'Scan Complete', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Color(0xFF1D2939))),
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
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Discovered Devices', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Color(0xFF1D2939))),
              if (!_isScanning)
                TextButton.icon(
                  onPressed: _checkPermissionsAndScan,
                  icon: const Icon(Icons.refresh_rounded, size: 18, color: Color(0xFF155EEF)),
                  label: const Text('Rescan', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF155EEF))),
                  style: TextButton.styleFrom(
                    backgroundColor: const Color(0xFF155EEF).withValues(alpha: 0.1),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        ..._scanResults.map((result) {
          String deviceName = result.device.platformName;
          if (deviceName.isEmpty) deviceName = result.advertisementData.advName;
          if (deviceName.isEmpty) deviceName = 'Unknown Device';

          return SlideFade(
            animation: _animController,
            delay: 0.4,
            child: _buildBleDeviceCard(
              result.device,
              deviceName, 
              'RSSI: ${result.rssi} dBm  •  ${result.device.remoteId.str}'
            ),
          );
        }),
        if (_scanResults.isEmpty && !_isScanning)
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Center(child: Text('No local devices found.', style: TextStyle(color: Color(0xFF94A3B8)))),
          ),
      ],
    );
  }

  Widget _buildBleDeviceCard(BluetoothDevice device, String name, String signal) {
    bool isConnecting = _connectingDevices.contains(device.remoteId.str);

    return BouncingCard(
      onTap: () { if (!isConnecting) _connectToDevice(device); },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFF1F5F9), width: 1.5),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 10, offset: const Offset(0, 4))],
        ),
        child: Row(
          children: [
            Container(
              width: 10, height: 10,
              decoration: const BoxDecoration(
                color: Color(0xFF155EEF),
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Color(0xFF1D2939), letterSpacing: -0.5)),
                  const SizedBox(height: 2),
                  Text(signal, style: const TextStyle(fontSize: 12, color: Color(0xFF64748B), fontWeight: FontWeight.w500)),
                ],
              ),
            ),
            if (isConnecting)
              const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF155EEF)))
            else
              IconButton(
                icon: const Icon(Icons.link_rounded, color: Color(0xFF155EEF)),
                style: IconButton.styleFrom(backgroundColor: const Color(0xFFEFF4FF)),
                onPressed: () => _connectToDevice(device),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildRobotCard({required String id, required String name, required bool isOnline, required String battery, required String signal, required String lastActive, required String type, required VoidCallback onDetails}) {
    return BouncingCard(
      onTap: () { if (isOnline) context.go('/control'); },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFF1F5F9), width: 1.5),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 10, offset: const Offset(0, 4))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 10, height: 10,
                  decoration: BoxDecoration(
                    color: isOnline ? const Color(0xFF10B981) : const Color(0xFF94A3B8),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Color(0xFF1D2939), letterSpacing: -0.5)),
                      const SizedBox(height: 2),
                      Text(type, style: const TextStyle(fontSize: 12, color: Color(0xFF64748B), fontWeight: FontWeight.w500)),
                    ],
                  ),
                ),
                if (isOnline)
                  IconButton(
                    icon: const Icon(Icons.gamepad_rounded, color: Color(0xFF155EEF)),
                    style: IconButton.styleFrom(backgroundColor: const Color(0xFFEFF4FF)),
                    onPressed: () => context.go('/control'),
                  ),
                IconButton(
                  icon: const Icon(Icons.settings_rounded, color: Color(0xFF64748B)),
                  onPressed: onDetails,
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline_rounded, color: Color(0xFFEF4444)),
                  onPressed: () => _confirmUnpairRobot(id),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                _buildMinimalStat(Icons.history_rounded, lastActive),
                const SizedBox(width: 16),
                _buildMinimalStat(Icons.wifi_rounded, signal),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmUnpairRobot(String id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text('Unpair Robot'),
        content: const Text('Are you sure you want to remove this robot from your account?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel', style: TextStyle(color: Colors.grey))),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Unpair', style: TextStyle(color: Colors.red))),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await _robotService.unpairRobot(id);
        _fetchCloudRobots();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to unpair: $e'), backgroundColor: Colors.red));
      }
    }
  }

  void _showRobotDetailsBottomSheet(Map<String, dynamic> robot) {
    final nameController = TextEditingController(text: robot['name'] ?? 'Robot Asset ${robot['robot_id']}');
    bool isSaving = false;
    final isOnline = robot['status']?.toString().toLowerCase() == 'online' || robot['status']?.toString().toLowerCase() == 'active';
    final lastSeen = robot['last_seen'] != null ? DateTime.parse(robot['last_seen']).toLocal().toString().split('.')[0] : 'Never';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Container(
          padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(width: 40, height: 4, decoration: BoxDecoration(color: const Color(0xFFE2E8F0), borderRadius: BorderRadius.circular(2))),
                ),
                const SizedBox(height: 24),
                const Text('Robot Details', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: Color(0xFF1D2939))),
                const SizedBox(height: 24),
                
                // Editable Name
                const Text('ROBOT NAME', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: Color(0xFF94A3B8), letterSpacing: 1.0)),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: nameController,
                        style: const TextStyle(color: Color(0xFF1D2939), fontWeight: FontWeight.bold),
                        decoration: InputDecoration(
                          prefixIcon: const Icon(Icons.edit_rounded, color: Color(0xFF94A3B8), size: 18),
                          filled: true,
                          fillColor: const Color(0xFFF8FAFC),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton(
                      onPressed: isSaving ? null : () async {
                        if (nameController.text.trim().isEmpty || nameController.text == robot['name']) return;
                        setModalState(() => isSaving = true);
                        try {
                          await _robotService.updateRobot(robot['id'], nameController.text.trim());
                          Navigator.pop(context);
                          _fetchCloudRobots();
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to update: $e'), backgroundColor: Colors.red));
                          setModalState(() => isSaving = false);
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF155EEF),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      child: isSaving ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) : const Text('Save'),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Read Only Details
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: const Color(0xFFF1F5F9)),
                  ),
                  child: Column(
                    children: [
                      _buildDetailRow('ROBOT ID', robot['robot_id']),
                      const Divider(color: Color(0xFFE2E8F0), height: 24),
                      _buildDetailRow('FIRMWARE', robot['firmware_version'] ?? 'Unknown'),
                      const Divider(color: Color(0xFFE2E8F0), height: 24),
                      _buildDetailRow('MODEL', robot['model'] ?? 'Unknown'),
                      const Divider(color: Color(0xFFE2E8F0), height: 24),
                      _buildDetailRow('STATUS', robot['status'] ?? 'Offline', valueColor: isOnline ? const Color(0xFF10B981) : const Color(0xFF64748B)),
                      const Divider(color: Color(0xFFE2E8F0), height: 24),
                      _buildDetailRow('LAST SEEN', lastSeen),
                    ],
                  ),
                ),
                const SizedBox(height: 50), // Increased bottom padding to avoid shell
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {Color? valueColor}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: Color(0xFF94A3B8), letterSpacing: 1.0)),
        Text(value, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: valueColor ?? const Color(0xFF1D2939), fontFamily: 'monospace')),
      ],
    );
  }

  Widget _buildMinimalStat(IconData icon, String value) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: const Color(0xFF94A3B8)),
        const SizedBox(width: 4),
        Text(value, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF64748B))),
      ],
    );
  }
}
