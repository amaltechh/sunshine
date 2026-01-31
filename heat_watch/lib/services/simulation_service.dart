import 'dart:math';
import '../models/simulation_result.dart';
import '../constants/app_constants.dart';

class SimulationService {
  final Random _random = Random();

  // Simulate intervention impact
  Future<SimulationResult> simulateIntervention({
    required double latitude,
    required double longitude,
    required double currentTemperature,
    required InterventionType interventionType,
  }) async {
    await Future.delayed(const Duration(milliseconds: 300));

    double temperatureReduction = 0;
    double cost = 0;
    int affectedPopulation = 0;

    switch (interventionType) {
      case InterventionType.treePlanting:
        temperatureReduction = AppConstants.treeCoolingEffect +
            (_random.nextDouble() * 0.5 - 0.25);
        cost = 50000 + _random.nextDouble() * 30000; // ₹50k-80k
        affectedPopulation = 500 + _random.nextInt(1000);
        break;

      case InterventionType.coolRoof:
        temperatureReduction =
            AppConstants.coolRoofEffect + (_random.nextDouble() * 0.8 - 0.4);
        cost = 200000 + _random.nextDouble() * 150000; // ₹2L-3.5L
        affectedPopulation = 200 + _random.nextInt(500);
        break;

      case InterventionType.greenSpace:
        temperatureReduction =
            AppConstants.greenSpaceEffect + (_random.nextDouble() * 0.4 - 0.2);
        cost = 500000 + _random.nextDouble() * 500000; // ₹5L-10L
        affectedPopulation = 1000 + _random.nextInt(3000);
        break;
    }

    final predictedTemperature =
        (currentTemperature - temperatureReduction).clamp(
      AppConstants.minTemp,
      AppConstants.maxTemp,
    );

    return SimulationResult(
      id: 'sim_${DateTime.now().millisecondsSinceEpoch}',
      latitude: latitude,
      longitude: longitude,
      interventionType: interventionType,
      currentTemperature: currentTemperature,
      predictedTemperature: predictedTemperature,
      temperatureReduction: temperatureReduction,
      affectedPopulation: affectedPopulation,
      estimatedCost: cost,
    );
  }

  // Calculate ROI (lives protected per lakh spent)
  double calculateROI(SimulationResult result) {
    final costPerLakh = result.estimatedCost / 100000;
    if (costPerLakh == 0) return 0;
    return result.affectedPopulation / costPerLakh;
  }

  // Get optimal intervention for a location
  Future<SimulationResult> getOptimalIntervention({
    required double latitude,
    required double longitude,
    required double currentTemperature,
    required double greenCover,
    required String buildingType,
  }) async {
    // Logic: Low green cover -> plant trees, High building density -> cool roofs
    InterventionType optimalType;

    if (greenCover < 15) {
      optimalType = InterventionType.treePlanting;
    } else if (buildingType == 'residential' && greenCover < 25) {
      optimalType = InterventionType.coolRoof;
    } else {
      optimalType = InterventionType.greenSpace;
    }

    return await simulateIntervention(
      latitude: latitude,
      longitude: longitude,
      currentTemperature: currentTemperature,
      interventionType: optimalType,
    );
  }
}
