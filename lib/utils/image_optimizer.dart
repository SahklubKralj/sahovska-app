import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

class ImageOptimizer {
  static const int maxImageSize = 1024; // Max width/height
  static const int jpegQuality = 85; // JPEG compression quality
  static const int maxFileSizeBytes = 2 * 1024 * 1024; // 2MB

  /// Optimizuje sliku za upload
  static Future<Uint8List?> optimizeImage(
    Uint8List imageBytes, {
    int maxSize = maxImageSize,
    int quality = jpegQuality,
  }) async {
    try {
      // U stvarnoj implementaciji bi koristili package kao što je image
      // Ovo je placeholder implementacija
      
      if (imageBytes.length <= maxFileSizeBytes) {
        return imageBytes;
      }

      // Simulacija kompresije
      final compressedSize = (imageBytes.length * quality / 100).round();
      return Uint8List.fromList(imageBytes.take(compressedSize).toList());
    } catch (e) {
      if (kDebugMode) {
        print('Error optimizing image: $e');
      }
      return null;
    }
  }

  /// Generiše thumbnail od slike
  static Future<Uint8List?> generateThumbnail(
    Uint8List imageBytes, {
    int thumbnailSize = 200,
  }) async {
    try {
      // U stvarnoj implementaciji bi koristili image package
      // za resize operacije
      
      // Placeholder - vraća originalnu sliku
      return imageBytes;
    } catch (e) {
      if (kDebugMode) {
        print('Error generating thumbnail: $e');
      }
      return null;
    }
  }

  /// Proverava da li je fajl validna slika
  static bool isValidImageFormat(String filename) {
    final extension = filename.toLowerCase().split('.').last;
    return ['jpg', 'jpeg', 'png', 'webp'].contains(extension);
  }

  /// Dobija MIME tip na osnovu ekstenzije
  static String getMimeType(String filename) {
    final extension = filename.toLowerCase().split('.').last;
    switch (extension) {
      case 'jpg':
      case 'jpeg':
        return 'image/jpeg';
      case 'png':
        return 'image/png';
      case 'webp':
        return 'image/webp';
      default:
        return 'image/jpeg';
    }
  }

  /// Proverava veličinu fajla
  static bool isFileSizeValid(int fileSizeBytes) {
    return fileSizeBytes <= maxFileSizeBytes;
  }

  /// Formatira veličinu fajla za prikaz
  static String formatFileSize(int bytes) {
    if (bytes < 1024) {
      return '$bytes B';
    } else if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(1)} KB';
    } else {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
  }
}

class CacheManager {
  static final Map<String, CacheEntry> _cache = {};
  static const int maxCacheSize = 50; // Maksimalno 50 stavki u cache-u
  static const Duration cacheExpiry = Duration(hours: 24);

  /// Dodaje stavku u cache
  static void put(String key, dynamic data) {
    // Ukloni stare stavke ako je cache pun
    if (_cache.length >= maxCacheSize) {
      _evictOldest();
    }

    _cache[key] = CacheEntry(
      data: data,
      timestamp: DateTime.now(),
    );
  }

  /// Dobija stavku iz cache-a
  static T? get<T>(String key) {
    final entry = _cache[key];
    if (entry == null) return null;

    // Proveri da li je cache entry zastario
    if (DateTime.now().difference(entry.timestamp) > cacheExpiry) {
      _cache.remove(key);
      return null;
    }

    return entry.data as T?;
  }

  /// Uklanja stavku iz cache-a
  static void remove(String key) {
    _cache.remove(key);
  }

  /// Čisti ceo cache
  static void clear() {
    _cache.clear();
  }

  /// Uklanja najstariju stavku
  static void _evictOldest() {
    if (_cache.isEmpty) return;

    String? oldestKey;
    DateTime? oldestTime;

    for (final entry in _cache.entries) {
      if (oldestTime == null || entry.value.timestamp.isBefore(oldestTime)) {
        oldestTime = entry.value.timestamp;
        oldestKey = entry.key;
      }
    }

    if (oldestKey != null) {
      _cache.remove(oldestKey);
    }
  }

  /// Dobija informacije o cache-u
  static Map<String, dynamic> getCacheInfo() {
    return {
      'size': _cache.length,
      'maxSize': maxCacheSize,
      'entries': _cache.keys.toList(),
    };
  }
}

class CacheEntry {
  final dynamic data;
  final DateTime timestamp;

  CacheEntry({
    required this.data,
    required this.timestamp,
  });
}

class LazyLoader<T> {
  T? _data;
  Future<T>? _future;
  final Future<T> Function() _loader;

  LazyLoader(this._loader);

  Future<T> get() async {
    if (_data != null) {
      return _data!;
    }

    if (_future != null) {
      return _future!;
    }

    _future = _loader();
    _data = await _future!;
    _future = null;

    return _data!;
  }

  void clear() {
    _data = null;
    _future = null;
  }

  bool get isLoaded => _data != null;
}

class BatchProcessor<T> {
  final List<T> _batch = [];
  final int batchSize;
  final Duration delay;
  final Future<void> Function(List<T>) processor;
  Timer? _timer;

  BatchProcessor({
    required this.batchSize,
    required this.delay,
    required this.processor,
  });

  void add(T item) {
    _batch.add(item);

    if (_batch.length >= batchSize) {
      _processBatch();
    } else {
      _scheduleProcessing();
    }
  }

  void _scheduleProcessing() {
    _timer?.cancel();
    _timer = Timer(delay, _processBatch);
  }

  Future<void> _processBatch() async {
    if (_batch.isEmpty) return;

    _timer?.cancel();
    
    final itemsToProcess = List<T>.from(_batch);
    _batch.clear();

    try {
      await processor(itemsToProcess);
    } catch (e) {
      if (kDebugMode) {
        print('Error processing batch: $e');
      }
    }
  }

  void flush() {
    _processBatch();
  }

  void dispose() {
    _timer?.cancel();
    _batch.clear();
  }
}

// Import potreban za Timer
import 'dart:async';