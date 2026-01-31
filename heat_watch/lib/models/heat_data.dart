class HeatData {
  final String id;
  final double latitude;
  final double longitude;
  final double temperature;
  final double nightTemperature;
  final DateTime timestamp;
  final String wardName;

  const HeatData({
    required this.id,
    required this.latitude,
    required this.longitude,
    required this.temperature,
    required this.nightTemperature,
    required this.timestamp,
    required this.wardName,
  });

  factory HeatData.fromJson(Map<String, dynamic> json) {
    return HeatData(
      id: json['id'] as String,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      temperature: (json['temperature'] as num).toDouble(),
      nightTemperature: (json['nightTemperature'] as num).toDouble(),
      timestamp: DateTime.parse(json['timestamp'] as String),
      wardName: json['wardName'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'latitude': latitude,
      'longitude': longitude,
      'temperature': temperature,
      'nightTemperature': nightTemperature,
      'timestamp': timestamp.toIso8601String(),
      'wardName': wardName,
    };
  }

  // Get normalized temperature (0-1 scale)
  double getNormalizedTemp(double minTemp, double maxTemp) {
    return ((temperature - minTemp) / (maxTemp - minTemp)).clamp(0.0, 1.0);
  }
}
