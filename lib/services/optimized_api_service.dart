import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:connectivity_plus/connectivity_plus.dart';
import '../utils/api_utils.dart';
import '../models/service_model.dart';
import '../models/spare_part_model.dart';
import 'cache_service.dart';

/// Error types for better error handling
enum ApiErrorType {
  noInternet,
  timeout,
  serverError,
  unknown,
}

/// API error with type information
class ApiError implements Exception {
  final ApiErrorType type;
  final String message;
  final dynamic originalError;

  ApiError(this.type, this.message, [this.originalError]);

  @override
  String toString() => message;
}

/// Optimized API service with caching, parallel loading, and performance enhancements
class OptimizedApiService {
  static final OptimizedApiService _instance = OptimizedApiService._internal();
  factory OptimizedApiService() => _instance;
  OptimizedApiService._internal();

  final CacheService _cache = CacheService();
  final Map<String, Completer> _pendingRequests = {};

  /// Initialize the service
  void initialize() {
    _cache.initialize();
  }

  /// Dispose of the service
  void dispose() {
    _cache.dispose();
    _pendingRequests.clear();
  }

  /// Make HTTP request with retry logic for cold starts
  Future<http.Response> _makeRequestWithRetry(
    String url, {
    int maxRetries = 3,
    Duration initialTimeout = const Duration(seconds: 30), // Longer for cold starts
  }) async {
    // Check connectivity first
    final connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult == ConnectivityResult.none) {
      throw ApiError(ApiErrorType.noInternet, 'No internet connection');
    }

    int attempt = 0;
    Duration currentTimeout = initialTimeout;

    while (attempt < maxRetries) {
      attempt++;
      print('🌐 Attempt $attempt/$maxRetries for $url (timeout: ${currentTimeout.inSeconds}s)');

      try {
        final response = await http.get(Uri.parse(url)).timeout(currentTimeout);
        return response;
      } on TimeoutException catch (e) {
        if (attempt >= maxRetries) {
          throw ApiError(ApiErrorType.timeout, 'Connection timeout after $maxRetries attempts', e);
        }
        // Exponential backoff: wait before retry
        final waitTime = Duration(seconds: attempt * 2);
        print('⏳ Timeout, waiting ${waitTime.inSeconds}s before retry...');
        await Future.delayed(waitTime);
        // Increase timeout for next attempt
        currentTimeout = Duration(seconds: currentTimeout.inSeconds + 10);
      } on SocketException catch (e) {
        throw ApiError(ApiErrorType.noInternet, 'No internet connection', e);
      } catch (e) {
        if (attempt >= maxRetries) {
          throw ApiError(ApiErrorType.unknown, 'Network error: ${e.toString()}', e);
        }
        // For other errors, retry after short delay
        await Future.delayed(const Duration(seconds: 1));
      }
    }

    throw ApiError(ApiErrorType.unknown, 'Request failed after $maxRetries attempts');
  }

  /// Fetch towing services with caching
  Future<List<Service>> fetchTowingServices() async {
    const cacheKey = 'towing_services';
    const ttl = Duration(minutes: 30);

    // Check cache first
    final cachedData = _cache.get<List<Service>>(cacheKey);
    if (cachedData != null) {
      print('🚀 Using cached towing services');
      return cachedData;
    }

    // Check for pending request
    if (_pendingRequests.containsKey(cacheKey)) {
      print('⏳ Waiting for pending towing services request');
      return await _pendingRequests[cacheKey]!.future as List<Service>;
    }

    // Create new request
    final completer = Completer<List<Service>>();
    _pendingRequests[cacheKey] = completer;

    try {
      print('🔄 Fetching towing services from API...');
      final url = '${getApiBaseUrl()}/api/services/type/towing';

      final response = await _makeRequestWithRetry(url);

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        final services = data.map((json) => Service.fromJson(json)).toList();

        // Cache the result
        _cache.set(cacheKey, services, ttl);

        print('✅ Cached ${services.length} towing services');
        completer.complete(services);
        return services;
      } else {
        throw ApiError(ApiErrorType.serverError, 'Failed to load towing services: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error fetching towing services: $e');
      completer.completeError(e);
      rethrow;
    } finally {
      _pendingRequests.remove(cacheKey);
    }
  }

  /// Fetch mechanic services with caching
  Future<List<Service>> fetchMechanicServices() async {
    const cacheKey = 'mechanic_services';
    const ttl = Duration(minutes: 30);

    // Check cache first
    final cachedData = _cache.get<List<Service>>(cacheKey);
    if (cachedData != null) {
      print('🚀 Using cached mechanic services');
      return cachedData;
    }

    // Check for pending request
    if (_pendingRequests.containsKey(cacheKey)) {
      print('⏳ Waiting for pending mechanic services request');
      return await _pendingRequests[cacheKey]!.future as List<Service>;
    }

    // Create new request
    final completer = Completer<List<Service>>();
    _pendingRequests[cacheKey] = completer;

    try {
      print('🔄 Fetching mechanic services from API...');
      final url = '${getApiBaseUrl()}/api/services/type/mechanic';

      final response = await _makeRequestWithRetry(url);

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        final services = data.map((json) => Service.fromJson(json)).toList();

        // Cache the result
        _cache.set(cacheKey, services, ttl);

        print('✅ Cached ${services.length} mechanic services');
        completer.complete(services);
        return services;
      } else {
        throw ApiError(ApiErrorType.serverError, 'Failed to load mechanic services: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error fetching mechanic services: $e');
      completer.completeError(e);
      rethrow;
    } finally {
      _pendingRequests.remove(cacheKey);
    }
  }

  /// Fetch spare parts with pagination and caching
  Future<List<SparePart>> fetchSpareParts({
    int page = 1,
    int limit = 50,
    String? search,
  }) async {
    final cacheKey = 'spare_parts_page_${page}_limit_${limit}_search_${search ?? 'all'}';
    const ttl = Duration(minutes: 15);

    // Check cache first
    final cachedData = _cache.get<List<SparePart>>(cacheKey);
    if (cachedData != null) {
      print('🚀 Using cached spare parts (page $page)');
      return cachedData;
    }

    // Check for pending request
    if (_pendingRequests.containsKey(cacheKey)) {
      print('⏳ Waiting for pending spare parts request (page $page)');
      return await _pendingRequests[cacheKey]!.future as List<SparePart>;
    }

    // Create new request
    final completer = Completer<List<SparePart>>();
    _pendingRequests[cacheKey] = completer;

    try {
      print('🔄 Fetching spare parts from API (page $page)...');
      var url = '${getApiBaseUrl()}/api/spare-parts?page=$page&limit=$limit';

      if (search != null && search.isNotEmpty) {
        url += '&search=$search';
      }

      final response = await _makeRequestWithRetry(url);

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        final List<dynamic> data = responseData['data'] ?? responseData['spareParts'] ?? [];
        final parts = data.map((json) => SparePart.fromJson(json)).toList();

        // Cache the result
        _cache.set(cacheKey, parts, ttl);

        print('✅ Cached ${parts.length} spare parts (page $page)');
        completer.complete(parts);
        return parts;
      } else {
        throw ApiError(ApiErrorType.serverError, 'Failed to load spare parts: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error fetching spare parts: $e');
      completer.completeError(e);
      rethrow;
    } finally {
      _pendingRequests.remove(cacheKey);
    }
  }

  /// Fetch all spare parts (for search functionality)
  Future<List<SparePart>> fetchAllSpareParts() async {
    const cacheKey = 'all_spare_parts';
    const ttl = Duration(minutes: 15);

    // Check cache first
    final cachedData = _cache.get<List<SparePart>>(cacheKey);
    if (cachedData != null) {
      print('🚀 Using cached all spare parts');
      return cachedData;
    }

    // Check for pending request
    if (_pendingRequests.containsKey(cacheKey)) {
      print('⏳ Waiting for pending all spare parts request');
      return await _pendingRequests[cacheKey]!.future as List<SparePart>;
    }

    // Create new request
    final completer = Completer<List<SparePart>>();
    _pendingRequests[cacheKey] = completer;

    try {
      print('🔄 Fetching all spare parts from API...');
      final url = '${getApiBaseUrl()}/api/spare-parts?limit=1000'; // Large limit for search

      final response = await _makeRequestWithRetry(url, initialTimeout: const Duration(seconds: 45)); // Longer for large data

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        final List<dynamic> data = responseData['data'] ?? responseData['spareParts'] ?? [];
        final allParts = data.map((json) => SparePart.fromJson(json)).toList();

        // Cache the result
        _cache.set(cacheKey, allParts, ttl);

        print('✅ Cached ${allParts.length} spare parts for search');
        completer.complete(allParts);
        return allParts;
      } else {
        throw ApiError(ApiErrorType.serverError, 'Failed to load all spare parts: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error fetching all spare parts: $e');
      completer.completeError(e);
      rethrow;
    } finally {
      _pendingRequests.remove(cacheKey);
    }
  }

  /// Preload critical data in parallel
  Future<void> preloadCriticalData() async {
    print('🚀 Starting parallel data preloading...');

    final futures = <Future>[];

    // Preload towing services
    futures.add(fetchTowingServices().catchError((e) {
      print('⚠️ Failed to preload towing services: $e');
      return <Service>[];
    }));

    // Preload mechanic services
    futures.add(fetchMechanicServices().catchError((e) {
      print('⚠️ Failed to preload mechanic services: $e');
      return <Service>[];
    }));

    // Preload first page of spare parts
    futures.add(fetchSpareParts(page: 1, limit: 20).catchError((e) {
      print('⚠️ Failed to preload spare parts: $e');
      return <SparePart>[];
    }));

    try {
      await Future.wait(futures);
      print('✅ Critical data preloading completed');
    } catch (e) {
      print('⚠️ Some preloading failed: $e');
    }
  }

  /// Clear all caches
  void clearCache() {
    _cache.clear();
    print('🧹 All caches cleared');
  }

  /// Get cache statistics
  Map<String, dynamic> getCacheStats() {
    return _cache.getStats();
  }
}