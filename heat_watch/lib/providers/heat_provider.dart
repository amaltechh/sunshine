import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/heat_data.dart';
import '../models/heat_inequality_index.dart';
import '../models/vulnerability_metrics.dart';
import '../services/heat_service.dart';

class HeatProvider with ChangeNotifier {
  final HeatService _heatService = HeatService();

  List<HeatData> _heatData = [];
  List<HeatInequalityIndex> _hiiData = [];
  List<VulnerabilityMetrics> _vulnerabilityData = [];
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
      // First load local/mock data to get coordinates and static metrics
      _heatData = await _heatService.getHeatData();
      _vulnerabilityData = await _heatService.getVulnerabilityMetrics();

      // Calculate initial HII based on mock/static data
      _hiiData = await _heatService.calculateHII();

      // Then attempt to fetch live data
      await fetchLiveHeatData();

      _error = null;
    } catch (e) {
      _error = 'Failed to load data: $e';
      // Fallback is already loaded from _heatService.getHeatData()
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Fetch live temperature for a single location (on tap)
  Future<double> getLiveTempForLocation(double lat, double lng) async {
    try {
      final url = Uri.parse(
          'https://api.open-meteo.com/v1/forecast?latitude=$lat&longitude=$lng&current=temperature_2m');

      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        // Single point returns object with 'current' field directly
        if (data['current'] != null &&
            data['current']['temperature_2m'] != null) {
          return (data['current']['temperature_2m'] as num).toDouble();
        }
      }
    } catch (e) {
      debugPrint('Error fetching spot temp: $e');
    }
    // Fallback if API fails
    return 35.0;
  }

  // Fetch live temperature from Open-Meteo for all data points
  Future<void> fetchLiveHeatData() async {
    if (_heatData.isEmpty) return;

    try {
      final List<String> latStr =
          _heatData.map((e) => e.latitude.toStringAsFixed(4)).toList();
      final List<String> lngStr =
          _heatData.map((e) => e.longitude.toStringAsFixed(4)).toList();

      final url = Uri.parse(
          'https://api.open-meteo.com/v1/forecast?latitude=${latStr.join(',')}&longitude=${lngStr.join(',')}&current=temperature_2m');

      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        List<dynamic> results;
        if (data is List) {
          results = data;
        } else {
          // Open-Meteo single result format check
          results = [data];
        }

        // Update local data with live temps
        List<HeatData> updatedData = [];
        for (int i = 0; i < _heatData.length; i++) {
          double? currentTemp;

          // Handle response mapping carefully
          if (i < results.length) {
            if (results[i]['current'] != null) {
              currentTemp =
                  (results[i]['current']['temperature_2m'] as num).toDouble();
            }
          }

          if (currentTemp != null) {
            updatedData.add(HeatData(
              id: _heatData[i].id,
              latitude: _heatData[i].latitude,
              longitude: _heatData[i].longitude,
              temperature: currentTemp,
              nightTemperature: _heatData[i].nightTemperature,
              timestamp: DateTime.now(),
              wardName: _heatData[i].wardName,
            ));
          } else {
            updatedData.add(_heatData[i]);
          }
        }

        if (updatedData.isNotEmpty) {
          _heatData = updatedData;
          _recalculateHII(); // Recalculate HII with new temperatures
        }
      }
    } catch (e) {
      debugPrint('Error fetching live heat data: $e');
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

  // Find closest HII data for a coordinate
  HeatInequalityIndex? getClosestHII(double lat, double lng) {
    if (_heatData.isEmpty || _hiiData.isEmpty) return null;

    double minDistance = double.infinity;
    HeatData? closestHeat;

    for (final heat in _heatData) {
      final distance = (lat - heat.latitude) * (lat - heat.latitude) +
          (lng - heat.longitude) * (lng - heat.longitude);
      if (distance < minDistance) {
        minDistance = distance;
        closestHeat = heat;
      }
    }

    if (closestHeat != null) {
      // Find matching HII (assuming wardName matches or via index if ids missing)
      try {
        return _hiiData.firstWhere((h) => h.wardName == closestHeat!.wardName);
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  // Recalculate HII based on current heat data and stored vulnerability metrics
  void _recalculateHII() {
    if (_heatData.isEmpty || _vulnerabilityData.isEmpty) return;

    final List<HeatInequalityIndex> updatedHiiList = [];

    for (var i = 0; i < _heatData.length; i++) {
      final heat = _heatData[i];
      // Find matching vulnerability data
      // Assuming index alignment for now since they are loaded from same source order,
      // but matching by wardName/Id is safer if we had IDs.
      // HeatService mock generates them in loop, so index i matches.
      if (i >= _vulnerabilityData.length) break;

      final vuln = _vulnerabilityData[i];

      final hii = HeatInequalityIndex.calculate(
        wardId: vuln.wardId,
        wardName: vuln.wardName,
        temperature: heat.temperature,
        nightTemperature: heat
            .nightTemperature, // Logic for live night temp? For now keep existing.
        populationDensity: vuln.populationDensity,
        vulnerablePopulation: vuln.vulnerablePopulation,
        greenCover: vuln.greenCoverPercentage,
        hospitalAccess: vuln.accessibilityScore,
      );

      updatedHiiList.add(hii);
    }

    // Sort by overall score (highest risk first)
    updatedHiiList.sort((a, b) => b.overallScore.compareTo(a.overallScore));

    _hiiData = updatedHiiList;
    notifyListeners(); // Notify UI of HII updates
  }
}
