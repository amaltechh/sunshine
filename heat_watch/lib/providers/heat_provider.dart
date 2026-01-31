import 'package:flutter/material.dart';
import '../models/heat_data.dart';
import '../models/heat_inequality_index.dart';
import '../services/heat_service.dart';

class HeatProvider with ChangeNotifier {
  final HeatService _heatService = HeatService();

  List<HeatData> _heatData = [];
  List<HeatInequalityIndex> _hiiData = [];
  bool _isLoading = false;
  bool _showNightHeat = false;
  String? _error;

  List<HeatData> get heatData => _heatData;
  List<HeatInequalityIndex> get hiiData => _hiiData;
  bool get isLoading => _isLoading;
  bool get showNightHeat => _showNightHeat;
  String? get error => _error;

  // Get average city temperature
  double get avgCityTemperature {
    if (_heatData.isEmpty) return 0;
    return _heatData.map((e) => e.temperature).reduce((a, b) => a + b) /
        _heatData.length;
  }

  // Get hottest ward
  HeatData? get hottestWard {
    if (_heatData.isEmpty) return null;
    return _heatData.reduce((a, b) => a.temperature > b.temperature ? a : b);
  }

  // Get most vulnerable ward
  HeatInequalityIndex? get mostVulnerableWard {
    if (_hiiData.isEmpty) return null;
    return _hiiData.first; // Already sorted by risk
  }

  // Toggle night heat view
  void toggleNightHeat() {
    _showNightHeat = !_showNightHeat;
    notifyListeners();
  }

  // Load all data
  Future<void> loadData() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _heatData = await _heatService.getHeatData();
      _hiiData = await _heatService.calculateHII();
      _error = null;
    } catch (e) {
      _error = 'Failed to load data: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Refresh data
  Future<void> refreshData() async {
    await loadData();
  }

  // Get HII for specific ward
  HeatInequalityIndex? getHIIForWard(String wardId) {
    try {
      return _hiiData.firstWhere((hii) => hii.wardId == wardId);
    } catch (e) {
      return null;
    }
  }
}
