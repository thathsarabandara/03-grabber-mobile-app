import 'dart:convert';
import 'dart:io';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class BleService {
  static final BleService _instance = BleService._internal();
  factory BleService() => _instance;
  BleService._internal();

  static const String deviceName = "Grabber_BLE";
  static const String serviceUuid = "4fafc201-1fb5-459e-8fcc-c5c9c331914b";
  static const String characteristicUuid = "beb5483e-36e1-4688-b7f5-ea07361b26a8";

  BluetoothDevice? _device;
  BluetoothCharacteristic? _controlCharacteristic;
  bool isConnected = false;

  Future<bool> connectToDevice(BluetoothDevice device) async {
    try {
      _device = device;
      
      // Always try to disconnect first to clear any stale Android caching
      try {
        await _device!.disconnect();
      } catch (_) {}

      // Connect with a longer timeout and autoConnect false for faster direct connections
      await _device!.connect(autoConnect: false, timeout: const Duration(seconds: 15));
      
      // Request larger MTU to prevent packet truncation for multi-joint strings
      try {
        if (Platform.isAndroid) {
          await _device!.requestMtu(256);
        }
      } catch (_) {}

      isConnected = true;
      
      await _discoverServices();
      
      // Validate that we found the specific Grabber characteristic
      if (_controlCharacteristic == null) {
        print("Grabber characteristic not found on this device.");
        await _device!.disconnect();
        isConnected = false;
        return false;
      }
      
      return true;
    } catch (e) {
      print("Error connecting directly: $e");
      isConnected = false;
      return false;
    }
  }

  Future<void> connect() async {
    try {
      // Start scanning
      await FlutterBluePlus.startScan(timeout: const Duration(seconds: 4));

      // Listen to scan results
      FlutterBluePlus.scanResults.listen((results) async {
        for (ScanResult r in results) {
          if (r.device.platformName == deviceName) {
            await FlutterBluePlus.stopScan();
            _device = r.device;
            await _device!.connect();
            isConnected = true;
            await _discoverServices();
            break;
          }
        }
      });
    } catch (e) {
      print("Error connecting to BLE: $e");
    }
  }

  Future<void> _discoverServices() async {
    if (_device == null) return;
    
    List<BluetoothService> services = await _device!.discoverServices();
    for (BluetoothService service in services) {
      if (service.uuid.toString() == serviceUuid) {
        for (BluetoothCharacteristic c in service.characteristics) {
          if (c.uuid.toString() == characteristicUuid) {
            _controlCharacteristic = c;
            break;
          }
        }
      }
    }
  }

  Future<void> disconnect() async {
    if (_device != null) {
      await _device!.disconnect();
      isConnected = false;
      _device = null;
      _controlCharacteristic = null;
    }
  }

  Future<void> sendJointCommand(int servoIndex, double targetAngle) async {
    if (!isConnected || _controlCharacteristic == null) return;

    // Protocol: J:<servoIndex>:<targetAngle>\n
    String command = "J:$servoIndex:${targetAngle.toStringAsFixed(1)}\n";
    List<int> bytes = utf8.encode(command);
    
    try {
      await _controlCharacteristic!.write(bytes, withoutResponse: true);
    } catch (e) {
      print("Error writing characteristic: $e");
    }
  }

  Future<void> sendAllJointsCommand(double j1, double j2, double j3, double j4) async {
    if (!isConnected || _controlCharacteristic == null) return;

    // Protocol: A:<j1>:<j2>:<j3>:<j4>\n (using integers to save bytes and fit in standard BLE MTU)
    String command = "A:${j1.toInt()}:${j2.toInt()}:${j3.toInt()}:${j4.toInt()}\n";
    List<int> bytes = utf8.encode(command);
    
    try {
      await _controlCharacteristic!.write(bytes, withoutResponse: true);
    } catch (e) {
      print("Error writing all joints: $e");
    }
  }
}
