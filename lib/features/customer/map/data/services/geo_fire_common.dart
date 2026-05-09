import 'dart:math' as math;

/// Firebase GeoFire geohash helpers (ported from `geofire-common` / `geofire-js`).
///
/// Source reference:
/// https://github.com/firebase/geofire-js/blob/master/packages/geofire-common/src/index.ts
///
/// Used only by [CustomerMapGeoService] — keep geohash math out of UI/providers.
class GeoFireCommon {
  GeoFireCommon._();

  static const int geoHashPrecision = 10;

  static const String base32 = '0123456789bcdefghjkmnpqrstuvwxyz';

  /// Meridional circumference (meters).
  static const double earthMeridionalCircumference = 40007860;

  static const double metersPerDegreeLatitude = 110574;

  static const int bitsPerChar = 5;

  static const int maximumBitsPrecision = 22 * bitsPerChar;

  static const double earthEquatorialRadius = 6378137.0;

  /// Polar flattening constant from GeoFire (matches TS reference exactly).
  static const double e2 = 0.00669447819799;

  static const double epsilon = 1e-12;

  static double _log2(double x) => math.log(x) / math.ln2;

  /// `[latitude, longitude]`
  static List<double> validateLocation(List<double> location) {
    if (location.length != 2) {
      throw ArgumentError.value(location, 'location', 'expected [lat, lng]');
    }
    final lat = location[0];
    final lng = location[1];
    if (lat < -90 || lat > 90 || lng < -180 || lng > 180) {
      throw ArgumentError.value(location, 'location', 'lat/lng out of range');
    }
    return location;
  }

  static String geohashForLocation(List<double> location, [int precision = geoHashPrecision]) {
    validateLocation(location);
    var latMin = -90.0;
    var latMax = 90.0;
    var lonMin = -180.0;
    var lonMax = 180.0;

    var hash = '';
    var hashVal = 0;
    var bits = 0;
    var evenBit = true;

    while (hash.length < precision) {
      final val = evenBit ? location[1] : location[0];
      final mid = evenBit ? (lonMin + lonMax) / 2 : (latMin + latMax) / 2;

      if (val > mid) {
        hashVal = (hashVal << 1) + 1;
        if (evenBit) {
          lonMin = mid;
        } else {
          latMin = mid;
        }
      } else {
        hashVal = hashVal << 1;
        if (evenBit) {
          lonMax = mid;
        } else {
          latMax = mid;
        }
      }
      evenBit = !evenBit;

      if (bits < 4) {
        bits++;
      } else {
        bits = 0;
        hash += base32[hashVal];
        hashVal = 0;
      }
    }

    return hash;
  }

  static double degreesToRadians(double degrees) => degrees * math.pi / 180;

  static double metersToLongitudeDegrees(double distance, double latitude) {
    final radians = degreesToRadians(latitude);
    final num = math.cos(radians) * earthEquatorialRadius * math.pi / 180;
    final denom = 1 / math.sqrt(1 - e2 * math.sin(radians) * math.sin(radians));
    final deltaDeg = num * denom;
    if (deltaDeg < epsilon) {
      return distance > 0 ? 360 : 0;
    }
    return math.min(360, distance / deltaDeg);
  }

  static double longitudeBitsForResolution(double resolution, double latitude) {
    final degs = metersToLongitudeDegrees(resolution, latitude);
    return (degs.abs() > 0.000001) ? math.max(1, _log2(360 / degs)) : 1;
  }

  static double latitudeBitsForResolution(double resolution) {
    return math.min(_log2(earthMeridionalCircumference / 2 / resolution), maximumBitsPrecision.toDouble());
  }

  static double wrapLongitude(double longitude) {
    if (longitude <= 180 && longitude >= -180) {
      return longitude;
    }
    final adjusted = longitude + 180;
    if (adjusted > 0) {
      return (adjusted % 360) - 180;
    }
    return 180 - (-adjusted % 360);
  }

  static int boundingBoxBits(List<double> coordinate, double size) {
    validateLocation(coordinate);
    final latDeltaDegrees = size / metersPerDegreeLatitude;
    final latitudeNorth =
        math.min(90.0, coordinate[0] + latDeltaDegrees).toDouble();
    final latitudeSouth =
        math.max(-90.0, coordinate[0] - latDeltaDegrees).toDouble();
    final bitsLat = latitudeBitsForResolution(size).floor() * 2;
    final bitsLongNorth = longitudeBitsForResolution(size, latitudeNorth).floor() * 2 - 1;
    final bitsLongSouth = longitudeBitsForResolution(size, latitudeSouth).floor() * 2 - 1;
    return math.min(
      math.min(bitsLat, math.min(bitsLongNorth, bitsLongSouth)),
      maximumBitsPrecision,
    );
  }

  /// Nine coordinates (center + 8 corners) whose geohash prefixes cover the circle.
  static List<List<double>> boundingBoxCoordinates(List<double> center, double radius) {
    validateLocation(center);
    final latDegrees = radius / metersPerDegreeLatitude;
    final latitudeNorth = math.min(90.0, center[0] + latDegrees).toDouble();
    final latitudeSouth = math.max(-90.0, center[0] - latDegrees).toDouble();
    final longDegsNorth = metersToLongitudeDegrees(radius, latitudeNorth);
    final longDegsSouth = metersToLongitudeDegrees(radius, latitudeSouth);
    final longDegs = math.max(longDegsNorth, longDegsSouth);
    return <List<double>>[
      <double>[center[0], center[1]],
      <double>[center[0], wrapLongitude(center[1] - longDegs)],
      <double>[center[0], wrapLongitude(center[1] + longDegs)],
      <double>[latitudeNorth, center[1]],
      <double>[latitudeNorth, wrapLongitude(center[1] - longDegs)],
      <double>[latitudeNorth, wrapLongitude(center[1] + longDegs)],
      <double>[latitudeSouth, center[1]],
      <double>[latitudeSouth, wrapLongitude(center[1] - longDegs)],
      <double>[latitudeSouth, wrapLongitude(center[1] + longDegs)],
    ];
  }

  /// `[start, end]` inclusive-exclusive geohash string range for Firestore `orderBy('geohash')`.
  static List<String> geohashQuery(String geohash, int bits) {
    final precision = (bits / bitsPerChar).ceil();
    if (geohash.length < precision) {
      return [geohash, '$geohash~'];
    }
    geohash = geohash.substring(0, precision);
    final base = geohash.substring(0, geohash.length - 1);
    final lastValue = base32.indexOf(geohash[geohash.length - 1]);
    final significantBits = bits - (base.length * bitsPerChar);
    final unusedBits = bitsPerChar - significantBits;
    final startValue = (lastValue >> unusedBits) << unusedBits;
    final endValue = startValue + (1 << unusedBits);
    if (endValue > 31) {
      return [base + base32[startValue], '$base~'];
    }
    return [base + base32[startValue], base + base32[endValue]];
  }

  /// Multiple disjoint/unmerged `[start, end]` ranges (typically ≤ 9).
  static List<List<String>> geohashQueryBounds(List<double> center, double radiusInMeters) {
    validateLocation(center);
    final queryBits = math.max(1, boundingBoxBits(center, radiusInMeters));
    final geohashPrecision = (queryBits / bitsPerChar).ceil();
    final coordinates = boundingBoxCoordinates(center, radiusInMeters);
    final queries = coordinates
        .map((c) => geohashQuery(geohashForLocation(c, geohashPrecision), queryBits))
        .toList(growable: false);

    final deduped = <List<String>>[];
    for (var i = 0; i < queries.length; i++) {
      final q = queries[i];
      final isDup = queries.asMap().entries.any((e) {
        final j = e.key;
        final o = e.value;
        return j < i && o[0] == q[0] && o[1] == q[1];
      });
      if (!isDup) {
        deduped.add(q);
      }
    }
    return deduped;
  }

  /// Haversine distance in kilometers (GeoFire reference).
  static double distanceBetweenKm(List<double> a, List<double> b) {
    validateLocation(a);
    validateLocation(b);
    const radius = 6371.0;
    final latDelta = degreesToRadians(b[0] - a[0]);
    final lonDelta = degreesToRadians(b[1] - a[1]);
    final h = (math.sin(latDelta / 2) * math.sin(latDelta / 2)) +
        (math.cos(degreesToRadians(a[0])) *
            math.cos(degreesToRadians(b[0])) *
            math.sin(lonDelta / 2) *
            math.sin(lonDelta / 2));
    final c = 2 * math.atan2(math.sqrt(h), math.sqrt(1 - h));
    return radius * c;
  }
}
