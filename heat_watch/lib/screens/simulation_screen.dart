import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../providers/heat_provider.dart';
import '../providers/simulation_provider.dart';
import '../models/simulation_result.dart';
import '../theme/app_colors.dart';
import '../constants/app_constants.dart';

class SimulationScreen extends StatefulWidget {
  const SimulationScreen({super.key});

  @override
  State<SimulationScreen> createState() => _SimulationScreenState();
}

class _SimulationScreenState extends State<SimulationScreen> {
  final MapController _mapController = MapController();
  LatLng? _selectedLocation;
  InterventionType _selectedIntervention = InterventionType.treePlanting;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Intervention Simulator'),
        actions: [
          IconButton(
            onPressed: () {
              context.read<SimulationProvider>().clearSimulations();
              setState(() {
                _selectedLocation = null;
              });
            },
            icon: const Icon(Icons.refresh),
            tooltip: 'Clear All',
          ),
        ],
      ),
      body: Consumer2<HeatProvider, SimulationProvider>(
        builder: (context, heatProvider, simProvider, child) {
          return Column(
            children: [
              // Map
              Expanded(
                flex: 2,
                child: Stack(
                  children: [
                    FlutterMap(
                      mapController: _mapController,
                      options: MapOptions(
                        initialCenter: LatLng(
                          AppConstants.defaultLat,
                          AppConstants.defaultLng,
                        ),
                        initialZoom: 12,
                        onTap: (_, position) {
                          setState(() {
                            _selectedLocation = position;
                          });
                        },
                      ),
                      children: [
                        TileLayer(
                          urlTemplate:
                              'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                          userAgentPackageName: 'com.heatwatch.heat_watch',
                          maxNativeZoom: 19,
                          maxZoom: 19,
                          keepBuffer: 4, // Better tile caching
                          tileProvider: NetworkTileProvider(), // Faster loading
                        ),

                        // Intervention markers
                        if (simProvider.simulations.isNotEmpty)
                          MarkerLayer(
                            markers: simProvider.simulations.map((sim) {
                              return Marker(
                                point: LatLng(sim.latitude, sim.longitude),
                                width: 50,
                                height: 50,
                                child: Icon(
                                  _getInterventionIcon(sim.interventionType),
                                  color: AppColors.success,
                                  size: 36,
                                  shadows: [
                                    Shadow(
                                      color: Colors.black.withOpacity(0.3),
                                      blurRadius: 4,
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                          ),

                        // Selected location marker
                        if (_selectedLocation != null)
                          MarkerLayer(
                            markers: [
                              Marker(
                                point: _selectedLocation!,
                                width: 40,
                                height: 40,
                                child: Icon(
                                  Icons.add_location,
                                  color: AppColors.primary,
                                  size: 40,
                                  shadows: [
                                    Shadow(
                                      color: Colors.black.withOpacity(0.5),
                                      blurRadius: 6,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                      ],
                    ),

                    // Instructions
                    if (_selectedLocation == null &&
                        simProvider.simulations.isEmpty)
                      Positioned(
                        top: 16,
                        left: 16,
                        right: 16,
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppColors.cardBackground,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: AppColors.glassBorder),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                blurRadius: 8,
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.touch_app,
                                  color: AppColors.primary, size: 28),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  'Tap on the map to select intervention location',
                                  style: TextStyle(
                                    color: AppColors.textPrimary,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ).animate().fadeIn(duration: 400.ms),
                      ),
                  ],
                ),
              ),

              // Controls
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.cardBackground,
                  border: Border(
                    top: BorderSide(color: AppColors.glassBorder),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Select Intervention Type',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _InterventionButton(
                            type: InterventionType.treePlanting,
                            isSelected: _selectedIntervention ==
                                InterventionType.treePlanting,
                            onTap: () => setState(() => _selectedIntervention =
                                InterventionType.treePlanting),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _InterventionButton(
                            type: InterventionType.coolRoof,
                            isSelected: _selectedIntervention ==
                                InterventionType.coolRoof,
                            onTap: () => setState(() => _selectedIntervention =
                                InterventionType.coolRoof),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _InterventionButton(
                            type: InterventionType.greenSpace,
                            isSelected: _selectedIntervention ==
                                InterventionType.greenSpace,
                            onTap: () => setState(() => _selectedIntervention =
                                InterventionType.greenSpace),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _selectedLocation == null
                            ? null
                            : () => _simulateIntervention(
                                heatProvider, simProvider),
                        child: simProvider.isSimulating
                            ? SizedBox(
                                height: 24,
                                width: 24,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : Text('Simulate Impact',
                                style: TextStyle(fontSize: 16)),
                      ),
                    ),
                  ],
                ),
              ),

              // Results
              if (simProvider.simulations.isNotEmpty)
                Expanded(
                  flex: 3, // Increased from 1 to 3 for more scroll space
                  child: Container(
                    color: AppColors.darkBackground,
                    child: Column(
                      children: [
                        // Summary
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                AppColors.primary.withOpacity(0.15),
                                Colors.transparent,
                              ],
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              _SummaryItem(
                                label: 'Temp Drop',
                                value:
                                    '${simProvider.totalTemperatureReduction.toStringAsFixed(1)}°C',
                                icon: Icons.trending_down,
                              ),
                              _SummaryItem(
                                label: 'People',
                                value: _formatNumber(
                                    simProvider.totalAffectedPopulation),
                                icon: Icons.people,
                              ),
                              _SummaryItem(
                                label: 'Cost',
                                value:
                                    '₹${_formatCurrency(simProvider.totalEstimatedCost)}',
                                icon: Icons.currency_rupee,
                              ),
                            ],
                          ),
                        ),

                        // List
                        Expanded(
                          child: ListView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: simProvider.simulations.length,
                            itemBuilder: (context, index) {
                              final sim = simProvider.simulations[index];
                              return _SimulationCard(
                                simulation: sim,
                                onRemove: () {
                                  simProvider.removeSimulation(sim.id);
                                },
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  IconData _getInterventionIcon(InterventionType type) {
    switch (type) {
      case InterventionType.treePlanting:
        return Icons.park;
      case InterventionType.coolRoof:
        return Icons.roofing;
      case InterventionType.greenSpace:
        return Icons.grass;
    }
  }

  Future<void> _simulateIntervention(
    HeatProvider heatProvider,
    SimulationProvider simProvider,
  ) async {
    if (_selectedLocation == null) return;

    double currentTemp = 42.0;
    double minDistance = double.infinity;

    for (final heatData in heatProvider.heatData) {
      final distance = _calculateDistance(
        _selectedLocation!.latitude,
        _selectedLocation!.longitude,
        heatData.latitude,
        heatData.longitude,
      );

      if (distance < minDistance) {
        minDistance = distance;
        currentTemp = heatData.temperature;
      }
    }

    await simProvider.addIntervention(
      latitude: _selectedLocation!.latitude,
      longitude: _selectedLocation!.longitude,
      currentTemperature: currentTemp,
      interventionType: _selectedIntervention,
    );

    setState(() => _selectedLocation = null);
  }

  double _calculateDistance(
      double lat1, double lon1, double lat2, double lon2) {
    return ((lat1 - lat2) * (lat1 - lat2) + (lon1 - lon2) * (lon1 - lon2));
  }

  String _formatNumber(int num) {
    if (num >= 1000) return '${(num / 1000).toStringAsFixed(1)}k';
    return num.toString();
  }

  String _formatCurrency(double amount) {
    if (amount >= 10000000)
      return '${(amount / 10000000).toStringAsFixed(1)}Cr';
    if (amount >= 100000) return '${(amount / 100000).toStringAsFixed(1)}L';
    if (amount >= 1000) return '${(amount / 1000).toStringAsFixed(0)}k';
    return amount.toStringAsFixed(0);
  }
}

class _InterventionButton extends StatelessWidget {
  final InterventionType type;
  final bool isSelected;
  final VoidCallback onTap;

  const _InterventionButton({
    required this.type,
    required this.isSelected,
    required this.onTap,
  });

  String get _icon {
    switch (type) {
      case InterventionType.treePlanting:
        return '🌳';
      case InterventionType.coolRoof:
        return '🏠';
      case InterventionType.greenSpace:
        return '🌿';
    }
  }

  String get _label {
    switch (type) {
      case InterventionType.treePlanting:
        return 'Trees';
      case InterventionType.coolRoof:
        return 'Cool Roof';
      case InterventionType.greenSpace:
        return 'Park';
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withOpacity(0.2)
              : AppColors.surfaceColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.glassBorder,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(_icon, style: TextStyle(fontSize: 28)),
            const SizedBox(height: 6),
            Text(
              _label,
              style: TextStyle(
                color: isSelected ? AppColors.primary : AppColors.textSecondary,
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryItem extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _SummaryItem({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: AppColors.primary, size: 22),
        const SizedBox(height: 6),
        Text(
          value,
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 17,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            color: AppColors.textTertiary,
            fontSize: 11,
          ),
        ),
      ],
    );
  }
}

class _SimulationCard extends StatelessWidget {
  final SimulationResult simulation;
  final VoidCallback onRemove;

  const _SimulationCard({
    required this.simulation,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.glassBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                simulation.interventionIcon,
                style: TextStyle(fontSize: 28),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      simulation.interventionName,
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${simulation.affectedPopulation} people affected',
                      style: TextStyle(
                        color: AppColors.textTertiary,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: Icon(Icons.close, size: 20),
                onPressed: onRemove,
                color: AppColors.textTertiary,
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _MetricBox(
                  label: 'Before',
                  value:
                      '${simulation.currentTemperature.toStringAsFixed(1)}°C',
                  color: AppColors.red,
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Icon(Icons.arrow_forward,
                    color: AppColors.textTertiary, size: 18),
              ),
              Expanded(
                child: _MetricBox(
                  label: 'After',
                  value:
                      '${simulation.predictedTemperature.toStringAsFixed(1)}°C',
                  color: AppColors.success,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _MetricBox(
                  label: 'Drop',
                  value:
                      '-${simulation.temperatureReduction.toStringAsFixed(1)}°C',
                  color: AppColors.cyan,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MetricBox extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _MetricBox({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 10,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
