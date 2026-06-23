import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../core/network/api_client.dart';

class TelemetryScreen extends StatefulWidget {
  const TelemetryScreen({super.key});

  @override
  State<TelemetryScreen> createState() => _TelemetryScreenState();
}

class _TelemetryScreenState extends State<TelemetryScreen> {
  WebSocketChannel? _channel;
  List<Map<String, dynamic>> _history = [];
  Map<String, dynamic>? _currentTelemetry;

  @override
  void initState() {
    super.initState();
    _connectWebSocket();
  }

  void _connectWebSocket() {
    final wsUrl = ApiClient.baseUrl.replaceFirst('http', 'ws').replaceFirst('/api/v1', '/telemetry/ws');
    try {
      _channel = WebSocketChannel.connect(Uri.parse(wsUrl));
      _channel!.stream.listen((message) {
        final data = jsonDecode(message);
        if (data['type'] == 'telemetry_update' || data['data'] != null) {
          final payload = data['data'] ?? data;
          
          if (!mounted) return;
          setState(() {
            _currentTelemetry = payload;
            
            _history.add({
              'time': DateTime.now().millisecondsSinceEpoch,
              'power': (payload['power']?['power'] ?? 0).toDouble(),
              'current': (payload['power']?['current'] ?? 0).toDouble(),
            });
            
            if (_history.length > 50) {
              _history.removeAt(0);
            }
          });
        }
      }, onError: (error) {
        debugPrint('WebSocket Error: $error');
      }, onDone: () {
        debugPrint('WebSocket Closed');
      });
    } catch (e) {
      debugPrint('Error connecting to WS: $e');
    }
  }

  @override
  void dispose() {
    _channel?.sink.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final batteryPercent = _currentTelemetry?['power']?['remainingCapacity'] ?? 0;
    final power = _currentTelemetry?['power']?['power'] ?? 0;
    final current = _currentTelemetry?['power']?['current'] ?? 0;
    final base = _currentTelemetry?['angles']?['base'] ?? 0;
    final shoulder = _currentTelemetry?['angles']?['shoulder'] ?? 0;
    final elbow = _currentTelemetry?['angles']?['elbow'] ?? 0;
    final grip = _currentTelemetry?['angles']?['grip'] ?? 0;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Live Telemetry', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: _buildStatCard('Battery', '${batteryPercent.toStringAsFixed(0)}%', Icons.battery_charging_full, Colors.green),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildStatCard('Power', '${power.toStringAsFixed(0)} mW', Icons.flash_on, Colors.purple),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildStatCard('Current', '${current.toStringAsFixed(0)} mA', Icons.electrical_services, Colors.blue),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildStatCard('Base Angle', '${base.toStringAsFixed(1)}°', Icons.rotate_right, Colors.orange),
                ),
              ],
            ),
            const SizedBox(height: 32),
            const Text('Power Dynamics (mW)', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            SizedBox(
              height: 250,
              child: _history.isEmpty 
                ? const Center(child: Text('Waiting for data...'))
                : LineChart(
                    LineChartData(
                      gridData: const FlGridData(show: false),
                      titlesData: const FlTitlesData(
                        bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      ),
                      borderData: FlBorderData(show: false),
                      lineBarsData: [
                        LineChartBarData(
                          spots: _history.asMap().entries.map((e) => FlSpot(e.key.toDouble(), e.value['power'])).toList(),
                          isCurved: true,
                          color: Colors.purple,
                          barWidth: 3,
                          dotData: const FlDotData(show: false),
                          belowBarData: BarAreaData(show: true, color: Colors.purple.withValues(alpha: 0.2)),
                        ),
                      ],
                    ),
                  ),
            ),
            const SizedBox(height: 32),
            const Text('Joint Kinematics', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            _buildJointBar('Base J1', base, Colors.blue),
            _buildJointBar('Shoulder J2', shoulder, Colors.purple),
            _buildJointBar('Elbow J3', elbow, Colors.green),
            _buildJointBar('Grip J4', grip, Colors.orange),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.bold, fontSize: 12)),
              Icon(icon, color: color, size: 20),
            ],
          ),
          const SizedBox(height: 12),
          Text(value, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildJointBar(String label, num value, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
              Text('${value.toStringAsFixed(1)}°', style: const TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: value / 180.0,
            backgroundColor: Colors.grey.shade200,
            color: color,
            minHeight: 8,
            borderRadius: BorderRadius.circular(4),
          )
        ],
      ),
    );
  }
}
