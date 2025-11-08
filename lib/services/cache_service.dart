import 'dart:async';

/// Cache entry with expiration time
class _CacheEntry {
  final dynamic data;
  final DateTime expiresAt;

  _CacheEntry(this.data, Duration ttl)
      : expiresAt = DateTime.now().add(ttl);

  bool get isExpired => DateTime.now().isAfter(expiresAt);
}

/// Advanced caching service with TTL support and automatic cleanup
class CacheService {
  static final CacheService _instance = CacheService._internal();
  factory CacheService() => _instance;
  CacheService._internal();

  final Map<String, _CacheEntry> _cache = {};
  Timer? _cleanupTimer;

  /// Initialize the cache service with periodic cleanup
  void initialize() {
    // Clean up expired entries every 5 minutes
    _cleanupTimer = Timer.periodic(const Duration(minutes: 5), (_) {
      _cleanup();
    });
  }

  /// Dispose of the cache service
  void dispose() {
    _cleanupTimer?.cancel();
    _cache.clear();
  }

  /// Get data from cache if not expired
  T? get<T>(String key) {
    final entry = _cache[key];
    if (entry != null && !entry.isExpired) {
      return entry.data as T;
    } else if (entry != null && entry.isExpired) {
      _cache.remove(key);
    }
    return null;
  }

  /// Set data in cache with TTL
  void set<T>(String key, T data, Duration ttl) {
    _cache[key] = _CacheEntry(data, ttl);
  }

  /// Check if key exists and is not expired
  bool has(String key) {
    final entry = _cache[key];
    return entry != null && !entry.isExpired;
  }

  /// Remove specific key from cache
  void remove(String key) {
    _cache.remove(key);
  }

  /// Clear all cache entries
  void clear() {
    _cache.clear();
  }

  /// Get cache statistics
  Map<String, dynamic> getStats() {
    final totalEntries = _cache.length;
    final expiredEntries = _cache.values.where((entry) => entry.isExpired).length;
    final activeEntries = totalEntries - expiredEntries;

    return {
      'total_entries': totalEntries,
      'active_entries': activeEntries,
      'expired_entries': expiredEntries,
      'cache_size_mb': _calculateCacheSize(),
    };
  }

  /// Clean up expired entries
  void _cleanup() {
    final keysToRemove = <String>[];
    for (final entry in _cache.entries) {
      if (entry.value.isExpired) {
        keysToRemove.add(entry.key);
      }
    }

    for (final key in keysToRemove) {
      _cache.remove(key);
    }

    if (keysToRemove.isNotEmpty) {
      print('🧹 Cache cleanup: Removed ${keysToRemove.length} expired entries');
    }
  }

  /// Calculate approximate cache size in MB
  double _calculateCacheSize() {
    // Rough estimation: each entry ~1KB + key length
    const entrySizeBytes = 1024; // 1KB per entry
    final keySizeBytes = _cache.keys.fold<int>(0, (sum, key) => sum + key.length * 2);
    final totalBytes = (_cache.length * entrySizeBytes) + keySizeBytes;
    return totalBytes / (1024 * 1024); // Convert to MB
  }

  // Predefined TTL values for different data types
  static const Duration shortTtl = Duration(minutes: 5);
  static const Duration mediumTtl = Duration(minutes: 15);
  static const Duration longTtl = Duration(minutes: 30);
  static const Duration veryLongTtl = Duration(hours: 1);
}