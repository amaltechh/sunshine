import 'dart:math';
import '../models/heat_data.dart';
import '../models/vulnerability_metrics.dart';
import '../models/heat_inequality_index.dart';

class HeatService {
  final Random _random = Random();

  // Generate mock heat data for demonstration
  Future<List<HeatData>> getHeatData() async {
    await Future.delayed(const Duration(milliseconds: 500));

    final List<HeatData> heatData = [];
    final wards = _getMockWards();

    for (var i = 0; i < wards.length; i++) {
      final ward = wards[i];
      heatData.add(HeatData(
        id: 'heat_$i',
        latitude: ward['lat']!,
        longitude: ward['lng']!,
        temperature: ward['temp']!,
        nightTemperature: ward['temp']! - 5 - _random.nextDouble() * 3,
        timestamp: DateTime.now(),
        wardName: ward['name']! as String,
      ));
    }

    return heatData;
  }

  // Get vulnerability metrics for wards
  Future<List<VulnerabilityMetrics>> getVulnerabilityMetrics() async {
    await Future.delayed(const Duration(milliseconds: 500));

    final List<VulnerabilityMetrics> metrics = [];
    final wards = _getMockWards();

    for (var i = 0; i < wards.length; i++) {
      final ward = wards[i];
      metrics.add(VulnerabilityMetrics(
        wardId: 'ward_$i',
        wardName: ward['name']! as String,
        populationDensity: 5000 + _random.nextDouble() * 20000,
        elderlyPercentage: 5 + _random.nextDouble() * 15,
        childrenPercentage: 15 + _random.nextDouble() * 20,
        lowIncomePercentage: ward['income']!,
        greenCoverPercentage: ward['green']!,
        avgHospitalDistance: 0.5 + _random.nextDouble() * 4.5,
        avgWaterPointDistance: 0.1 + _random.nextDouble() * 1.9,
      ));
    }

    return metrics;
  }

  // Calculate Heat Inequality Index for all wards
  Future<List<HeatInequalityIndex>> calculateHII() async {
    final heatData = await getHeatData();
    final vulnerabilityData = await getVulnerabilityMetrics();

    final List<HeatInequalityIndex> hiiList = [];

    for (var i = 0; i < heatData.length; i++) {
      final heat = heatData[i];
      final vuln = vulnerabilityData[i];

      final hii = HeatInequalityIndex.calculate(
        wardId: vuln.wardId,
        wardName: vuln.wardName,
        temperature: heat.temperature,
        nightTemperature: heat.nightTemperature,
        populationDensity: vuln.populationDensity,
        vulnerablePopulation: vuln.vulnerablePopulation,
        greenCover: vuln.greenCoverPercentage,
        hospitalAccess: vuln.accessibilityScore,
      );

      hiiList.add(hii);
    }

    // Sort by overall score (highest risk first)
    hiiList.sort((a, b) => b.overallScore.compareTo(a.overallScore));

    return hiiList;
  }

  // Mock ward data for New Delhi
  List<Map<String, dynamic>> _getMockWards() {
    return [
      {
        'name': 'Narela',
        'lat': 28.8540,
        'lng': 77.0896,
        'temp': 44.5,
        'income': 65.0,
        'green': 12.0
      },
      {
        'name': 'Rohini',
        'lat': 28.7437,
        'lng': 77.0677,
        'temp': 42.8,
        'income': 35.0,
        'green': 25.0
      },
      {
        'name': 'Dwarka',
        'lat': 28.5921,
        'lng': 77.0460,
        'temp': 41.2,
        'income': 25.0,
        'green': 30.0
      },
      {
        'name': 'Connaught Place',
        'lat': 28.6315,
        'lng': 77.2167,
        'temp': 43.5,
        'income': 15.0,
        'green': 18.0
      },
      {
        'name': 'Karol Bagh',
        'lat': 28.6519,
        'lng': 77.1905,
        'temp': 44.0,
        'income': 40.0,
        'green': 10.0
      },
      {
        'name': 'Paharganj',
        'lat': 28.6433,
        'lng': 77.2143,
        'temp': 45.2,
        'income': 75.0,
        'green': 5.0
      },
      {
        'name': 'Model Town',
        'lat': 28.7196,
        'lng': 77.1888,
        'temp': 41.8,
        'income': 20.0,
        'green': 35.0
      },
      {
        'name': 'Shahdara',
        'lat': 28.6842,
        'lng': 77.2840,
        'temp': 44.8,
        'income': 60.0,
        'green': 8.0
      },
      {
        'name': 'Vasant Vihar',
        'lat': 28.5525,
        'lng': 77.1588,
        'temp': 40.5,
        'income': 10.0,
        'green': 40.0
      },
      {
        'name': 'Mehrauli',
        'lat': 28.5244,
        'lng': 77.1855,
        'temp': 42.0,
        'income': 45.0,
        'green': 20.0
      },
      {
        'name': 'Najafgarh',
        'lat': 28.6090,
        'lng': 76.9798,
        'temp': 45.5,
        'income': 70.0,
        'green': 6.0
      },
      {
        'name': 'Okhla',
        'lat': 28.5355,
        'lng': 77.2747,
        'temp': 44.2,
        'income': 55.0,
        'green': 12.0
      },
    ];
  }
}
