import 'package:flutter_cache_manager/flutter_cache_manager.dart';

class MapCacheService {
  static const key = 'mapboxCache';

  static CacheManager instance = CacheManager(
    Config(
      key,
      stalePeriod: const Duration(days: 7), // Delete tiles older than 7 days
      maxNrOfCacheObjects: 1000,            // Max number of tiles (approx 20-30MB)
      repo: JsonCacheInfoRepository(databaseName: key),
      fileService: HttpFileService(),
    ),
  );
}