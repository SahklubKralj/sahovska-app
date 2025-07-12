import 'package:flutter/foundation.dart';

/// Production-ready logger that only logs in debug mode
/// Replaces all print() statements for better performance in release builds
class AppLogger {
  static const String _tag = 'ShahovskaApp';
  
  /// Debug level logging - only in debug builds
  static void debug(String message, [String? tag]) {
    if (kDebugMode) {
      _log('DEBUG', tag ?? _tag, message);
    }
  }
  
  /// Info level logging - only in debug builds  
  static void info(String message, [String? tag]) {
    if (kDebugMode) {
      _log('INFO', tag ?? _tag, message);
    }
  }
  
  /// Warning level logging - always logged
  static void warning(String message, [String? tag]) {
    _log('WARNING', tag ?? _tag, message);
  }
  
  /// Error level logging - always logged
  static void error(String message, [String? tag, dynamic error]) {
    _log('ERROR', tag ?? _tag, message);
    if (error != null && kDebugMode) {
      _log('ERROR', tag ?? _tag, 'Error details: $error');
    }
  }
  
  /// Performance logging for timing operations
  static void performance(String operation, int milliseconds, [String? tag]) {
    if (kDebugMode) {
      final performanceTag = '${tag ?? _tag}_PERF';
      _log('PERF', performanceTag, '$operation completed in ${milliseconds}ms');
      
      // Warn about slow operations
      if (milliseconds > 1000) {
        _log('PERF_WARNING', performanceTag, '⚠️ SLOW: $operation took ${milliseconds}ms');
      }
    }
  }
  
  /// Network logging for API calls
  static void network(String method, String url, int statusCode, int duration) {
    if (kDebugMode) {
      _log('NETWORK', '${_tag}_NET', '$method $url -> $statusCode (${duration}ms)');
    }
  }
  
  /// Firebase operations logging
  static void firebase(String operation, String collection, [String? documentId]) {
    if (kDebugMode) {
      final target = documentId != null ? '$collection/$documentId' : collection;
      _log('FIREBASE', '${_tag}_FB', '$operation: $target');
    }
  }
  
  /// Authentication operations logging
  static void auth(String operation, [String? userId]) {
    if (kDebugMode) {
      final userInfo = userId != null ? ' (user: ${userId.substring(0, 8)}...)' : '';
      _log('AUTH', '${_tag}_AUTH', '$operation$userInfo');
    }
  }
  
  /// Notification operations logging
  static void notification(String operation, [String? notificationId]) {
    if (kDebugMode) {
      final notifInfo = notificationId != null ? ' (id: $notificationId)' : '';
      _log('NOTIFICATION', '${_tag}_NOTIF', '$operation$notifInfo');
    }
  }
  
  /// Storage operations logging
  static void storage(String operation, String path, [int? sizeBytes]) {
    if (kDebugMode) {
      final sizeInfo = sizeBytes != null ? ' (${_formatBytes(sizeBytes)})' : '';
      _log('STORAGE', '${_tag}_STORAGE', '$operation: $path$sizeInfo');
    }
  }
  
  /// Private method to handle actual logging
  static void _log(String level, String tag, String message) {
    final timestamp = DateTime.now().toIso8601String().substring(11, 23); // HH:mm:ss.SSS
    final logMessage = '[$timestamp] [$level] [$tag] $message';
    
    // In production, only errors and warnings go to system log
    if (kReleaseMode && (level == 'ERROR' || level == 'WARNING')) {
      // This would integrate with crash reporting in production
      debugPrint(logMessage);
    } else if (kDebugMode) {
      debugPrint(logMessage);
    }
  }
  
  /// Format bytes for readable storage logging
  static String _formatBytes(int bytes) {
    if (bytes < 1024) return '${bytes}B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)}KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)}MB';
  }
  
  /// Log app lifecycle events
  static void lifecycle(String event) {
    debug('App lifecycle: $event', 'LIFECYCLE');
  }
  
  /// Log user interactions for analytics
  static void userAction(String action, [Map<String, dynamic>? parameters]) {
    if (kDebugMode) {
      final params = parameters != null ? ' with params: $parameters' : '';
      _log('USER_ACTION', '${_tag}_UA', '$action$params');
    }
  }
  
  /// Batch logging for multiple related operations
  static void batch(String batchName, List<String> operations) {
    if (kDebugMode) {
      _log('BATCH_START', _tag, 'Starting batch: $batchName');
      for (int i = 0; i < operations.length; i++) {
        _log('BATCH_ITEM', _tag, '[${i + 1}/${operations.length}] ${operations[i]}');
      }
      _log('BATCH_END', _tag, 'Completed batch: $batchName');
    }
  }
}

/// Extension for easy performance timing
extension PerformanceLogging on Stopwatch {
  void logPerformance(String operation, [String? tag]) {
    AppLogger.performance(operation, elapsedMilliseconds, tag);
  }
}