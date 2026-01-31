enum InterventionType {
  treePlanting,
  coolRoof,
  greenSpace,
}

class SimulationResult {
  final String id;
  final double latitude;
  final double longitude;
  final InterventionType interventionType;
  final double currentTemperature;
  final double predictedTemperature;
  final double temperatureReduction;
  final int affectedPopulation;
  final double estimatedCost; // in local currency

  const SimulationResult({
    required this.id,
    required this.latitude,
    required this.longitude,
    required this.interventionType,
    required this.currentTemperature,
    required this.predictedTemperature,
    required this.temperatureReduction,
    required this.affectedPopulation,
    required this.estimatedCost,
  });

  String get interventionName {
    switch (interventionType) {
      case InterventionType.treePlanting:
        return 'Tree Planting';
      case InterventionType.coolRoof:
        return 'Cool Roof';
      case InterventionType.greenSpace:
        return 'Green Space';
    }
  }

  String get interventionIcon {
    switch (interventionType) {
      case InterventionType.treePlanting:
        return '🌳';
      case InterventionType.coolRoof:
        return '🏠';
      case InterventionType.greenSpace:
        return '🌿';
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'latitude': latitude,
      'longitude': longitude,
      'interventionType': interventionType.toString(),
      'currentTemperature': currentTemperature,
      'predictedTemperature': predictedTemperature,
      'temperatureReduction': temperatureReduction,
      'affectedPopulation': affectedPopulation,
      'estimatedCost': estimatedCost,
    };
  }
}
