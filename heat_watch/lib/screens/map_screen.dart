import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../providers/heat_provider.dart';
import '../theme/app_colors.dart';
import '../constants/app_constants.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final MapController _mapController = MapController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<HeatProvider>().loadData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Heat Map'),
        actions: [
          Consumer<HeatProvider>(
            builder: (context, provider, child) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      provider.showNightHeat ? 'Night' : 'Day',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    Switch(
                      value: provider.showNightHeat,
                      onChanged: (value) {
                        provider.toggleNightHeat();
                        setState(() {});
                      },
                      activeColor: AppColors.cyan,
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: Consumer<HeatProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.cyan),
            );
          }

          final heatData = provider.heatData;

          return Stack(
            children: [
              FlutterMap(
                mapController: _mapController,
                options: MapOptions(
                  initialCenter: LatLng(
                    AppConstants.defaultLat,
                    AppConstants.defaultLng,
                  ),
                  initialZoom: AppConstants.defaultZoom,
                  minZoom: 10,
                  maxZoom: 18,
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

                  // Heat circles
                  CircleLayer(
                    circles: heatData.map((data) {
                      final temp = provider.showNightHeat
                          ? data.nightTemperature
                          : data.temperature;
                      final normalizedTemp = data.getNormalizedTemp(
                        AppConstants.minTemp,
                        AppConstants.maxTemp,
                      );

                      return CircleMarker(
                        point: LatLng(data.latitude, data.longitude),
                        radius: 800,
                        useRadiusInMeter: true,
                        color: AppColors.getHeatColor(normalizedTemp)
                            .withOpacity(0.3),
                        borderColor: AppColors.getHeatColor(normalizedTemp),
                        borderStrokeWidth: 2,
                      );
                    }).toList(),
                  ),

                  // Markers
                  MarkerLayer(
                    markers: heatData.map((data) {
                      final temp = provider.showNightHeat
                          ? data.nightTemperature
                          : data.temperature;
                      final normalizedTemp = data.getNormalizedTemp(
                        AppConstants.minTemp,
                        AppConstants.maxTemp,
                      );

                      return Marker(
                        point: LatLng(data.latitude, data.longitude),
                        width: 80,
                        height: 80,
                        child: GestureDetector(
                          onTap: () {
                            _showWardInfo(context, data.wardName, temp);
                          },
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.getHeatColor(normalizedTemp),
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.3),
                                      blurRadius: 4,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Text(
                                  '${temp.toStringAsFixed(1)}°C',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 2),
                              Icon(
                                Icons.location_on,
                                color: AppColors.getHeatColor(normalizedTemp),
                                size: 24,
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),

              // Legend
              Positioned(
                bottom: 24,
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
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'Temperature Scale',
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _LegendItem(
                              color: AppColors.cyan, label: 'Cool\n<35°C'),
                          _LegendItem(
                              color: AppColors.yellow, label: 'Warm\n35-40°C'),
                          _LegendItem(
                              color: AppColors.orange, label: 'Hot\n40-43°C'),
                          _LegendItem(
                              color: AppColors.red, label: 'Extreme\n>43°C'),
                        ],
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

  void _showWardInfo(BuildContext context, String wardName, double temp) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '$wardName: ${temp.toStringAsFixed(1)}°C',
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: AppColors.cardBackground.withOpacity(0.95),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.only(bottom: 140, left: 16, right: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: AppColors.success, width: 1),
        ),
      ),
    );
  }
}

class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;

  const _LegendItem({
    required this.color,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.5),
                blurRadius: 4,
              ),
            ],
          ),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: AppColors
                .textPrimary, // Changed from textSecondary for better visibility
            fontSize: 11, // Increased from 10
            height: 1.2,
            fontWeight: FontWeight.w500, // Added weight
          ),
        ),
      ],
    );
  }
}
