import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ConnectionProvider with ChangeNotifier {
  Socket? _socket;
  bool _isConnected = false;
  String _serverIP = '';
  static const String _ipKey = 'server_ip';
  bool _isConnecting = false;
  Timer? _connectionTimer;

  bool get isConnected => _isConnected;
  String get serverIP => _serverIP;
  bool get isConnecting => _isConnecting;

  ConnectionProvider() {
    _loadSavedIP();
  }

  Future<void> _loadSavedIP() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _serverIP = prefs.getString(_ipKey) ?? '';
      notifyListeners();
    } catch (e) {
      print('Error loading saved IP: $e');
    }
  }

  Future<void> connect(String ip) async {
    if (_isConnecting || _isConnected) return;

    _isConnecting = true;
    notifyListeners();

    try {
      // Close existing socket if any
      await disconnect();

      // Create new socket connection
      _socket =
          await Socket.connect(ip, 3000, timeout: const Duration(seconds: 5));

      // Set up connection handlers
      _socket!.listen(
        (data) {
          // Handle incoming data if needed
          print('Received: ${String.fromCharCodes(data)}');
        },
        onError: (error) {
          print('Socket error: $error');
          disconnect();
        },
        onDone: () {
          print('Socket connection closed');
          disconnect();
        },
      );

      _isConnected = true;
      _isConnecting = false;
      _serverIP = ip;
      _saveIP(ip);
      notifyListeners();

      // Set up connection timer
      _connectionTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (!_isConnected) {
          timer.cancel();
          return;
        }
        try {
          _socket?.add([0]); // Send keep-alive
        } catch (e) {
          print('Keep-alive error: $e');
          disconnect();
        }
      });
    } catch (e) {
      print('Connection error: $e');
      _isConnected = false;
      _isConnecting = false;
      notifyListeners();
    }
  }

  Future<void> _saveIP(String ip) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_ipKey, ip);
    } catch (e) {
      print('Error saving IP: $e');
    }
  }

  Future<void> disconnect() async {
    _isConnecting = false;
    _connectionTimer?.cancel();
    _connectionTimer = null;

    try {
      await _socket?.close();
    } catch (e) {
      print('Error closing socket: $e');
    }

    _socket = null;
    _isConnected = false;
    notifyListeners();
  }

  void sendCommand(String command) {
    if (_isConnected && _socket != null) {
      try {
        _socket!.write(command);
        print('Sent command: $command');
      } catch (e) {
        print('Error sending command: $e');
        disconnect();
      }
    }
  }

  @override
  void dispose() {
    disconnect();
    super.dispose();
  }
}
