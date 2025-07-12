import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

class PerformanceUtils {
  static final Map<String, Stopwatch> _timers = {};
  static final List<String> _performanceLogs = [];

  /// Startuje merenje performansi za određenu operaciju
  static void startTimer(String operation) {
    _timers[operation] = Stopwatch()..start();
  }

  /// Završava merenje i loguje rezultat
  static void endTimer(String operation) {
    final timer = _timers[operation];
    if (timer != null) {
      timer.stop();
      final duration = timer.elapsedMilliseconds;
      
      if (kDebugMode) {
        print('Performance: $operation took ${duration}ms');
      }
      
      _performanceLogs.add('$operation: ${duration}ms');
      _timers.remove(operation);
      
      // Upozorenje za spore operacije (>1000ms)
      if (duration > 1000) {
        if (kDebugMode) {
          print('⚠️ SLOW OPERATION: $operation took ${duration}ms');
        }
      }
    }
  }

  /// Meri performanse async operacije
  static Future<T> measureAsync<T>(
    String operation,
    Future<T> Function() function,
  ) async {
    startTimer(operation);
    try {
      final result = await function();
      endTimer(operation);
      return result;
    } catch (e) {
      endTimer(operation);
      rethrow;
    }
  }

  /// Meri performanse sync operacije
  static T measureSync<T>(
    String operation,
    T Function() function,
  ) {
    startTimer(operation);
    try {
      final result = function();
      endTimer(operation);
      return result;
    } catch (e) {
      endTimer(operation);
      rethrow;
    }
  }

  /// Dobija sve performance logove
  static List<String> getPerformanceLogs() {
    return List.from(_performanceLogs);
  }

  /// Čisti performance logove
  static void clearLogs() {
    _performanceLogs.clear();
  }

  /// Dobija prosečno vreme za operaciju
  static double? getAverageTime(String operation) {
    final operationLogs = _performanceLogs
        .where((log) => log.startsWith('$operation:'))
        .toList();

    if (operationLogs.isEmpty) return null;

    final times = operationLogs.map((log) {
      final timeStr = log.split(':')[1].replaceAll('ms', '').trim();
      return double.tryParse(timeStr) ?? 0.0;
    }).toList();

    return times.reduce((a, b) => a + b) / times.length;
  }
}

/// Widget za merenje vremena renderovanja
class PerformanceTracker extends StatefulWidget {
  final Widget child;
  final String name;
  final VoidCallback? onRenderComplete;

  const PerformanceTracker({
    Key? key,
    required this.child,
    required this.name,
    this.onRenderComplete,
  }) : super(key: key);

  @override
  _PerformanceTrackerState createState() => _PerformanceTrackerState();
}

class _PerformanceTrackerState extends State<PerformanceTracker> {
  @override
  void initState() {
    super.initState();
    PerformanceUtils.startTimer('render_${widget.name}');
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      PerformanceUtils.endTimer('render_${widget.name}');
      widget.onRenderComplete?.call();
    });
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}

/// Memory usage tracker
class MemoryTracker {
  static final List<MemoryMeasurement> _measurements = [];

  static void trackMemory(String operation) {
    if (kDebugMode) {
      // Simulacija memory trackinga - u realnom scenariju bi koristili pravi memory profiler
      _measurements.add(MemoryMeasurement(
        operation: operation,
        timestamp: DateTime.now(),
        // Ovo je placeholder - trebalo bi koristiti dart:developer ili platform-specific API
        memoryUsage: 0,
      ));
    }
  }

  static List<MemoryMeasurement> getMeasurements() {
    return List.from(_measurements);
  }

  static void clearMeasurements() {
    _measurements.clear();
  }
}

class MemoryMeasurement {
  final String operation;
  final DateTime timestamp;
  final int memoryUsage; // u bajtovima

  MemoryMeasurement({
    required this.operation,
    required this.timestamp,
    required this.memoryUsage,
  });
}

/// Frame rate monitor
class FrameRateMonitor {
  static final List<double> _frameRates = [];
  static Timer? _timer;
  static int _frameCount = 0;
  static DateTime _lastCheck = DateTime.now();

  static void startMonitoring() {
    if (_timer?.isActive == true) return;

    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      final now = DateTime.now();
      final elapsed = now.difference(_lastCheck).inMilliseconds;
      
      if (elapsed >= 1000) {
        final fps = (_frameCount * 1000) / elapsed;
        _frameRates.add(fps);
        
        if (kDebugMode && fps < 30) {
          print('⚠️ LOW FPS: ${fps.toStringAsFixed(1)}');
        }
        
        _frameCount = 0;
        _lastCheck = now;
      }
    });
  }

  static void stopMonitoring() {
    _timer?.cancel();
    _timer = null;
  }

  static void recordFrame() {
    _frameCount++;
  }

  static double? getAverageFPS() {
    if (_frameRates.isEmpty) return null;
    return _frameRates.reduce((a, b) => a + b) / _frameRates.length;
  }

  static List<double> getFrameRates() {
    return List.from(_frameRates);
  }

  static void clearHistory() {
    _frameRates.clear();
  }
}

/// Network performance tracker
class NetworkPerformanceTracker {
  static final Map<String, NetworkMeasurement> _activeCalls = {};
  static final List<NetworkMeasurement> _completedCalls = [];

  static void startNetworkCall(String callId, String url) {
    _activeCalls[callId] = NetworkMeasurement(
      callId: callId,
      url: url,
      startTime: DateTime.now(),
    );
  }

  static void endNetworkCall(
    String callId, {
    int? responseSize,
    int? statusCode,
    String? error,
  }) {
    final call = _activeCalls[callId];
    if (call != null) {
      final completedCall = call.copyWith(
        endTime: DateTime.now(),
        responseSize: responseSize,
        statusCode: statusCode,
        error: error,
      );
      
      _completedCalls.add(completedCall);
      _activeCalls.remove(callId);
      
      final duration = completedCall.duration;
      if (kDebugMode) {
        print('Network: ${call.url} took ${duration}ms');
        
        if (duration > 5000) {
          print('⚠️ SLOW NETWORK CALL: ${call.url} took ${duration}ms');
        }
      }
    }
  }

  static List<NetworkMeasurement> getCompletedCalls() {
    return List.from(_completedCalls);
  }

  static double? getAverageNetworkTime() {
    if (_completedCalls.isEmpty) return null;
    
    final times = _completedCalls.map((call) => call.duration).toList();
    return times.reduce((a, b) => a + b) / times.length;
  }

  static void clearHistory() {
    _completedCalls.clear();
  }
}

class NetworkMeasurement {
  final String callId;
  final String url;
  final DateTime startTime;
  final DateTime? endTime;
  final int? responseSize;
  final int? statusCode;
  final String? error;

  NetworkMeasurement({
    required this.callId,
    required this.url,
    required this.startTime,
    this.endTime,
    this.responseSize,
    this.statusCode,
    this.error,
  });

  int get duration {
    if (endTime == null) return 0;
    return endTime!.difference(startTime).inMilliseconds;
  }

  bool get isSuccess => statusCode != null && statusCode! >= 200 && statusCode! < 300;

  NetworkMeasurement copyWith({
    String? callId,
    String? url,
    DateTime? startTime,
    DateTime? endTime,
    int? responseSize,
    int? statusCode,
    String? error,
  }) {
    return NetworkMeasurement(
      callId: callId ?? this.callId,
      url: url ?? this.url,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      responseSize: responseSize ?? this.responseSize,
      statusCode: statusCode ?? this.statusCode,
      error: error ?? this.error,
    );
  }
}