import 'package:flutter/material.dart';
import '../models/simulation_result.dart';
import '../services/simulation_service.dart';

class SimulationProvider with ChangeNotifier {
  final SimulationService _simulationService = SimulationService();

  final List<SimulationResult> _simulations = [];
  bool _isSimulating = false;

  List<SimulationResult> get simulations => _simulations;
  bool get isSimulating => _isSimulating;

  // Get total temperature reduction from all simulations
  double get totalTemperatureReduction {
    if (_simulations.isEmpty) return 0;
    return _simulations
        .map((s) => s.temperatureReduction)
        .reduce((a, b) => a + b);
  }

  // Get total affected population
  int get totalAffectedPopulation {
    if (_simulations.isEmpty) return 0;
    return _simulations
        .map((s) => s.affectedPopulation)
        .reduce((a, b) => a + b);
  }

  // Get total estimated cost
  double get totalEstimatedCost {
    if (_simulations.isEmpty) return 0;
    return _simulations.map((s) => s.estimatedCost).reduce((a, b) => a + b);
  }

  // Add new intervention simulation
  Future<SimulationResult> addIntervention({
    required double latitude,
    required double longitude,
    required double currentTemperature,
    required InterventionType interventionType,
  }) async {
    _isSimulating = true;
    notifyListeners();

    try {
      final result = await _simulationService.simulateIntervention(
        latitude: latitude,
        longitude: longitude,
        currentTemperature: currentTemperature,
        interventionType: interventionType,
      );

      _simulations.add(result);
      return result;
    } finally {
      _isSimulating = false;
      notifyListeners();
    }
  }

  // Remove simulation
  void removeSimulation(String id) {
    _simulations.removeWhere((s) => s.id == id);
    notifyListeners();
  }

  // Clear all simulations
  void clearSimulations() {
    _simulations.clear();
    notifyListeners();
  }

  // Get ROI for simulation
  double getROI(String id) {
    final result = _simulations.firstWhere((s) => s.id == id);
    return _simulationService.calculateROI(result);
  }
}
