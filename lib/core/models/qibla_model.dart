/// Model for Qibla direction data
class QiblaModel {
  final double latitude;
  final double longitude;
  final double direction; // Qibla direction in degrees

  const QiblaModel({
    required this.latitude,
    required this.longitude,
    required this.direction,
  });

  factory QiblaModel.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>;
    return QiblaModel(
      latitude: (data['latitude'] as num).toDouble(),
      longitude: (data['longitude'] as num).toDouble(),
      direction: (data['direction'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'data': {
        'latitude': latitude,
        'longitude': longitude,
        'direction': direction,
      },
    };
  }

  /// Get cardinal direction (N, NE, E, SE, S, SW, W, NW)
  String get cardinalDirection {
    const directions = ['N', 'NE', 'E', 'SE', 'S', 'SW', 'W', 'NW'];
    final index = ((direction + 22.5) / 45).floor() % 8;
    return directions[index];
  }

  @override
  String toString() => 'QiblaModel(direction: $direction°, cardinal: $cardinalDirection)';
}
