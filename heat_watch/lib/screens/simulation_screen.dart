import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../providers/heat_provider.dart';
import '../providers/simulation_provider.dart';
import '../models/simulation_result.dart';
import '../models/heat_inequality_index.dart'; // Added import
import '../theme/app_colors.dart';
import '../constants/app_constants.dart';

class SimulationScreen extends StatefulWidget {
  const SimulationScreen({super.key});

  @override
  State<SimulationScreen> createState() => _SimulationScreenState();
}

class _SimulationScreenState extends State<SimulationScreen> {
  GoogleMapController? _mapController;
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
          Set<Marker> markers = {};

          // Simulation Markers
          for (var sim in simProvider.simulations) {
            // Create a marker with a hue color corresponding to intervention type
            double hue;
            switch (sim.interventionType) {
              case InterventionType.treePlanting:
                hue = BitmapDescriptor.hueGreen;
                break;
              case InterventionType.coolRoof:
                hue = BitmapDescriptor.hueBlue;
                break;
              case InterventionType.greenSpace:
                hue = BitmapDescriptor.hueYellow;
                break;
            }

            markers.add(
              Marker(
                markerId: MarkerId(sim.id),
                position: LatLng(sim.latitude, sim.longitude),
                icon: BitmapDescriptor.defaultMarkerWithHue(hue),
                infoWindow: InfoWindow(
                  title: sim.interventionName,
                  snippet:
                      '-${sim.temperatureReduction.toStringAsFixed(1)}°C Temp Drop',
                  onTap: () {
                    simProvider.removeSimulation(sim.id);
                  },
                ),
              ),
            );
          }

          // Selected Location Marker
          if (_selectedLocation != null) {
            markers.add(
              Marker(
                markerId: const MarkerId('selected'),
                position: _selectedLocation!,
                icon: BitmapDescriptor.defaultMarkerWithHue(
                    BitmapDescriptor.hueRed),
                infoWindow: const InfoWindow(title: 'Selected Location'),
              ),
            );
          }

          return Column(
            children: [
              // Map
              Expanded(
                flex: 2,
                child: Stack(
                  children: [
                    GoogleMap(
                      initialCameraPosition: CameraPosition(
                        target: LatLng(
                          AppConstants.defaultLat,
                          AppConstants.defaultLng,
                        ),
                        zoom: 12, // Google maps zoom
                      ),
                      onMapCreated: (controller) {
                        _mapController = controller;
                      },
                      onTap: (position) {
                        setState(() {
                          _selectedLocation = position;
                        });
                      },
                      markers: markers,
                      myLocationButtonEnabled: false,
                      zoomControlsEnabled: false,
                      mapToolbarEnabled: false,
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

                    // SMART RECOMMENDATION SECTION
                    if (_selectedLocation != null) ...[
                      const SizedBox(height: 16),
                      _buildRecommendationCard(heatProvider),
                    ],

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
                  flex: 3,
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

  Widget _buildRecommendationCard(HeatProvider heatProvider) {
    if (_selectedLocation == null) return const SizedBox.shrink();

    final hii = heatProvider.getClosestHII(
      _selectedLocation!.latitude,
      _selectedLocation!.longitude,
    );

    if (hii == null) return const SizedBox.shrink();

    // Recommendation Logic
    String recommendation = '';
    IconData recIcon = Icons.lightbulb;
    String reason = '';

    if (hii.populationDensity > 20000) {
      recommendation = 'Cool Roofs';
      recIcon = Icons.roofing;
      reason =
          'High population density (${(hii.populationDensity / 1000).toStringAsFixed(1)}k/km²) requires vertical cooling solutions.';
    } else if (hii.greenCover < 15) {
      recommendation = 'Urban Forestry';
      recIcon = Icons.park;
      reason =
          'Critical lack of green cover (${hii.greenCover.toStringAsFixed(1)}%) contributes to heat island effect.';
    } else {
      recommendation = 'Green Spaces';
      recIcon = Icons.grass;
      reason =
          'General cooling needed. Parks would benefit this moderate density area.';
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primary.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.analytics, color: AppColors.primary, size: 20),
              const SizedBox(width: 8),
              const Text(
                'Site Analysis',
                style: TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Ward: ${hii.wardName}',
            style: const TextStyle(
                color: AppColors.textPrimary, fontWeight: FontWeight.bold),
          ),
          Text(
            'Density: ${(hii.populationDensity / 1000).toStringAsFixed(1)}k/km² • Green Cover: ${hii.greenCover.toStringAsFixed(1)}%',
            style:
                const TextStyle(color: AppColors.textSecondary, fontSize: 12),
          ),
          const SizedBox(height: 8),
          const Divider(height: 16, color: AppColors.glassBorder),
          Row(
            children: [
              Icon(recIcon, color: AppColors.secondary, size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Recommended: $recommendation',
                      style: const TextStyle(
                        color: AppColors.secondary,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                    Text(
                      reason,
                      style: const TextStyle(
                          color: AppColors.textTertiary, fontSize: 11),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
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
