import 'package:heat_watch/constants/app_constants.dart';

enum RiskLevel {
  low,
  moderate,
  high,
  extreme,
}

class HeatInequalityIndex {
  final String wardId;
  final String wardName;
  final double temperature;
  final double nightTemperature;
  final double populationDensity;
  final double vulnerablePopulation;
  final double greenCover;
  final double hospitalAccess;
  final double overallScore; // 0-100

  const HeatInequalityIndex({
    required this.wardId,
    required this.wardName,
    required this.temperature,
    required this.nightTemperature,
    required this.populationDensity,
    required this.vulnerablePopulation,
    required this.greenCover,
    required this.hospitalAccess,
    required this.overallScore,
  });

  // Get risk level based on score
  RiskLevel get riskLevel {
    if (overallScore >= 75) return RiskLevel.extreme;
    if (overallScore >= 50) return RiskLevel.high;
    if (overallScore >= 25) return RiskLevel.moderate;
    return RiskLevel.low;
  }

  // Get risk level color
  String get riskLevelText {
    switch (riskLevel) {
      case RiskLevel.extreme:
        return 'EXTREME RISK';
      case RiskLevel.high:
        return 'HIGH RISK';
      case RiskLevel.moderate:
        return 'MODERATE RISK';
      case RiskLevel.low:
        return 'LOW RISK';
    }
  }

  // Calculate HII from components
  static HeatInequalityIndex calculate({
    required String wardId,
    required String wardName,
    required double temperature,
    required double nightTemperature,
    required double populationDensity,
    required double vulnerablePopulation,
    required double greenCover,
    required double hospitalAccess,
  }) {
    // Normalize all values to 0-100 scale
    final tempScore = ((temperature - AppConstants.minTemp) /
            (AppConstants.maxTemp - AppConstants.minTemp) *
            100)
        .clamp(0, 100);

    final densityScore =
        (populationDensity / 30000 * 100).clamp(0, 100); // Assume max 30k/km²

    final vulnerableScore = vulnerablePopulation; // Already 0-100

    final greenScore = 100 - greenCover; // Invert: less green = higher risk

    final accessScore =
        (1 - hospitalAccess) * 100; // Invert: worse access = higher risk

    // Calculate weighted average
    final overallScore = (tempScore * AppConstants.temperatureWeight +
        densityScore * AppConstants.populationDensityWeight +
        vulnerableScore * AppConstants.vulnerablePopulationWeight +
        greenScore * AppConstants.greenCoverWeight +
        accessScore * AppConstants.hospitalAccessWeight);

    return HeatInequalityIndex(
      wardId: wardId,
      wardName: wardName,
      temperature: temperature,
      nightTemperature: nightTemperature,
      populationDensity: populationDensity,
      vulnerablePopulation: vulnerablePopulation,
      greenCover: greenCover,
      hospitalAccess: hospitalAccess,
      overallScore: overallScore,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'wardId': wardId,
      'wardName': wardName,
      'temperature': temperature,
      'nightTemperature': nightTemperature,
      'populationDensity': populationDensity,
      'vulnerablePopulation': vulnerablePopulation,
      'greenCover': greenCover,
      'hospitalAccess': hospitalAccess,
      'overallScore': overallScore,
      'riskLevel': riskLevelText,
    };
  }
}
