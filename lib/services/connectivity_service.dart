import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';

class ConnectivityService extends ChangeNotifier {
  static final ConnectivityService _instance = ConnectivityService._internal();
  factory ConnectivityService() => _instance;
  ConnectivityService._internal();

  bool _isOnline = true;
  bool _isInitialized = false;
  Timer? _connectivityTimer;

  bool get isOnline => _isOnline;
  bool get isOffline => !_isOnline;
  bool get isInitialized => _isInitialized;

  Future<void> initialize() async {
    if (_isInitialized) return;

    await _checkConnectivity();
    _startPeriodicCheck();
    _isInitialized = true;
  }

  void _startPeriodicCheck() {
    _connectivityTimer?.cancel();
    _connectivityTimer = Timer.periodic(
      const Duration(seconds: 10),
      (_) => _checkConnectivity(),
    );
  }

  Future<void> _checkConnectivity() async {
    bool wasOnline = _isOnline;
    
    try {
      // Pokušaj da se povezeš sa Google DNS serverom
      final result = await InternetAddress.lookup('google.com')
          .timeout(const Duration(seconds: 5));
      
      _isOnline = result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } catch (e) {
      _isOnline = false;
    }

    // Obavesti listenere samo ako se status promenio
    if (wasOnline != _isOnline) {
      notifyListeners();
      if (kDebugMode) {
        print('Connectivity changed: ${_isOnline ? 'Online' : 'Offline'}');
      }
    }
  }

  // Force check connectivity
  Future<bool> checkConnectivityNow() async {
    await _checkConnectivity();
    return _isOnline;
  }

  // Check specific host connectivity
  Future<bool> canReachHost(String host, {int port = 443}) async {
    try {
      final socket = await Socket.connect(host, port)
          .timeout(const Duration(seconds: 5));
      socket.destroy();
      return true;
    } catch (e) {
      return false;
    }
  }

  // Check Firebase connectivity specifically
  Future<bool> canReachFirebase() async {
    return await canReachHost('firebase.googleapis.com');
  }

  // Get connection quality (basic implementation)
  Future<ConnectionQuality> getConnectionQuality() async {
    if (!_isOnline) return ConnectionQuality.none;

    try {
      final stopwatch = Stopwatch()..start();
      
      final result = await InternetAddress.lookup('google.com')
          .timeout(const Duration(seconds: 3));
      
      stopwatch.stop();
      
      if (result.isEmpty) return ConnectionQuality.none;
      
      final responseTime = stopwatch.elapsedMilliseconds;
      
      if (responseTime < 500) return ConnectionQuality.good;
      if (responseTime < 1500) return ConnectionQuality.medium;
      return ConnectionQuality.poor;
      
    } catch (e) {
      return ConnectionQuality.none;
    }
  }

  // Dispose resources
  @override
  void dispose() {
    _connectivityTimer?.cancel();
    super.dispose();
  }
}

enum ConnectionQuality {
  none,    // Nema konekcije
  poor,    // Spora konekcija (>1.5s)
  medium,  // Srednja konekcija (0.5-1.5s)
  good,    // Brza konekcija (<0.5s)
}

// Helper extension
extension ConnectionQualityExtension on ConnectionQuality {
  String get displayName {
    switch (this) {
      case ConnectionQuality.none:
        return 'Nema konekcije';
      case ConnectionQuality.poor:
        return 'Spora konekcija';
      case ConnectionQuality.medium:
        return 'Srednja konekcija';
      case ConnectionQuality.good:
        return 'Brza konekcija';
    }
  }

  bool get canSync => this != ConnectionQuality.none;
  bool get canUpload => this == ConnectionQuality.good || this == ConnectionQuality.medium;
}