import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';

import '../providers/heat_provider.dart';
import '../theme/app_colors.dart';
import '../constants/app_constants.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  GoogleMapController? _mapController;
  MapType _currentMapType = MapType.normal;
  LatLng? _selectedLocation;

  // Simulation State
  double _treeCoverage = 0.0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<HeatProvider>().loadData();
      _determinePosition(); // Request permissions on load
    });
  }

  Future<void> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return;

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return;
    }

    if (permission == LocationPermission.deniedForever) return;

    setState(() {});
  }

  Future<void> _goToUserLocation() async {
    try {
      Position position = await Geolocator.getCurrentPosition();
      _mapController?.animateCamera(
        CameraUpdate.newLatLngZoom(
            LatLng(position.latitude, position.longitude), 15),
      );
    } catch (e) {
      // Handle error cleanly
      debugPrint('Error getting location: $e');
    }
  }

  void _onMapTap(LatLng position) async {
    // Reset state
    setState(() {
      _selectedLocation = position;
      _treeCoverage = 0;
    });

    // Show loading indicator in bottom sheet temporarily or just wait
    // Let's show the sheet immediately with a loading state

    // We'll use a FutureBuilder logic effectively by passing the future to the modal or just awaiting here
    // Awaiting here is safer for the "Selected Point" marker to settle

    // Show a small loading indicator on the UI or just fetch quickly
    // For better UX: Update _selectedLocation marker, then fetch

    final heatProvider = context.read<HeatProvider>();

    // Optimistic UI: Show "Loading..." in the bottom sheet
    // But since we need the temp to build the sheet, let's fetch first (fast API)

    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (c) => const Center(
            child: CircularProgressIndicator(color: AppColors.primary)));

    final double realTemp = await heatProvider.getLiveTempForLocation(
        position.latitude, position.longitude);

    Navigator.pop(context); // Close loader

    _showSelectionDetails(position, realTemp);
  }

  void _showSelectionDetails(LatLng position, double temp) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => StatefulBuilder(builder: (context, setModalState) {
        final simulatedTemp = temp - (_treeCoverage * 0.05);

        return Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: AppColors.cardBackground,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            border: Border(top: BorderSide(color: AppColors.glassBorder)),
            boxShadow: [
              BoxShadow(
                  color: Colors.black.withOpacity(0.4),
                  blurRadius: 20,
                  offset: const Offset(0, -5)),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('SELECTED LOCATION',
                          style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.2,
                              color: AppColors.textTertiary)),
                      Text(
                          '${position.latitude.toStringAsFixed(4)}, ${position.longitude.toStringAsFixed(4)}',
                          style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary)),
                    ],
                  ),
                  IconButton(
                      icon: const Icon(Icons.close,
                          color: AppColors.textSecondary),
                      onPressed: () => Navigator.pop(context)),
                ],
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('CURRENT TEMP',
                            style: TextStyle(
                                fontSize: 10, color: AppColors.textTertiary)),
                        Text('${simulatedTemp.toStringAsFixed(1)}°C',
                            style: TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                color: AppColors.getHeatColor(
                                    (simulatedTemp - 20) / 20))),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        const Text('RISK LEVEL',
                            style: TextStyle(
                                fontSize: 10, color: AppColors.textTertiary)),
                        Text(_getRiskLabel(simulatedTemp),
                            style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: AppColors.getHeatColor(
                                    (simulatedTemp - 20) / 20))),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              const Text('SIMULATE INTERVENTION',
                  style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary)),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Tree Coverage: ${_treeCoverage.toInt()}%',
                      style: const TextStyle(color: AppColors.textPrimary)),
                ],
              ),
              SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  trackHeight: 6,
                  activeTrackColor: AppColors.primary,
                  inactiveTrackColor: AppColors.surfaceColor,
                  thumbColor: Colors.white,
                ),
                child: Slider(
                  value: _treeCoverage,
                  min: 0,
                  max: 100,
                  divisions: 100,
                  onChanged: (val) {
                    setModalState(() {
                      _treeCoverage = val;
                    });
                    setState(() {
                      _treeCoverage = val;
                    });
                  },
                ),
              ),
              const SizedBox(height: 12),
              Text(
                  'Potential cooling: -${(_treeCoverage * 0.05).toStringAsFixed(1)}°C',
                  style: const TextStyle(
                      color: AppColors.coolBlue, fontStyle: FontStyle.italic)),
            ],
          ),
        );
      }),
    ).whenComplete(() {
      setState(() {
        _selectedLocation = null;
        _treeCoverage = 0;
      });
    });
  }

  String _getRiskLabel(double temp) {
    if (temp >= 40) return 'EXTREME';
    if (temp >= 35) return 'HIGH';
    if (temp >= 30) return 'MODERATE';
    return 'LOW';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<HeatProvider>(
        builder: (context, provider, child) {
          final heatData = provider.heatData;
          Set<Circle> circles = {};
          Set<Marker> markers = {};

          // Generate Map Objects
          for (var data in heatData) {
            final temp = provider.showNightHeat
                ? data.nightTemperature
                : data.temperature;
            final normalizedTemp = data.getNormalizedTemp(
                AppConstants.minTemp, AppConstants.maxTemp);

            circles.add(
              Circle(
                circleId: CircleId('${data.id}_circle'),
                center: LatLng(data.latitude, data.longitude),
                radius: 800,
                strokeWidth: 0,
                fillColor:
                    AppColors.getHeatColor(normalizedTemp).withOpacity(0.5),
              ),
            );

            markers.add(
              Marker(
                markerId: MarkerId(data.id),
                position: LatLng(data.latitude, data.longitude),
                icon: BitmapDescriptor.defaultMarkerWithHue(
                    (1.0 - normalizedTemp) * 120.0),
                infoWindow: InfoWindow(title: '${data.wardName}: ${temp}°C'),
              ),
            );
          }

          // Add Selected Location Marker
          if (_selectedLocation != null) {
            markers.add(
              Marker(
                markerId: const MarkerId('selected_point'),
                position: _selectedLocation!,
                icon: BitmapDescriptor.defaultMarkerWithHue(
                    BitmapDescriptor.hueAzure),
                zIndex: 10,
              ),
            );
          }

          return Stack(
            children: [
              GoogleMap(
                initialCameraPosition: CameraPosition(
                  target:
                      LatLng(AppConstants.defaultLat, AppConstants.defaultLng),
                  zoom: AppConstants.defaultZoom - 1,
                ),
                onMapCreated: (controller) => _mapController = controller,
                mapType: _currentMapType,
                markers: markers,
                circles: circles,
                onTap: _onMapTap,
                myLocationEnabled: true,
                myLocationButtonEnabled: false,
                zoomControlsEnabled: false,
                mapToolbarEnabled: false,
              ),

              // Top Bar
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _NeoCard(
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                  width: 20,
                                  height: 20,
                                  decoration: const BoxDecoration(
                                      color: AppColors.primary,
                                      shape: BoxShape.circle)),
                              const SizedBox(width: 8),
                              const Text('HEAT WATCH',
                                  style: TextStyle(
                                      fontWeight: FontWeight.w900,
                                      letterSpacing: 1.2,
                                      color: AppColors.textPrimary)),
                            ],
                          ),
                        ),
                        if (provider.isLoading)
                          _NeoCard(
                              child: const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: AppColors.primary))),
                      ],
                    ),
                  ),
                ),
              ),

              // Right Controls
              Positioned(
                top: 80,
                right: 16,
                child: Column(
                  children: [
                    _NeoIconBtn(
                      icon: _currentMapType == MapType.normal
                          ? Icons.satellite_alt
                          : Icons.map,
                      onTap: () => setState(() => _currentMapType =
                          _currentMapType == MapType.normal
                              ? MapType.satellite
                              : MapType.normal),
                    ),
                    const SizedBox(height: 12),
                    _NeoIconBtn(
                      icon: Icons.brightness_6,
                      onTap: () => provider.toggleNightHeat(),
                      isActive: provider.showNightHeat,
                    ),
                    const SizedBox(height: 12),
                    _NeoIconBtn(
                      icon: Icons.my_location,
                      onTap: _goToUserLocation,
                    ),
                  ],
                ),
              ),

              // Hint
              if (_selectedLocation == null)
                Positioned(
                  bottom: 30,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                          color: Colors.black54,
                          borderRadius: BorderRadius.circular(20)),
                      child: const Text('Tap anywhere to analyze & simulate',
                          style: TextStyle(color: Colors.white, fontSize: 12)),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

class _NeoCard extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;
  const _NeoCard({required this.child, this.onTap});
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.glassBorder),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 8,
                offset: const Offset(0, 4))
          ],
        ),
        child: child,
      ),
    );
  }
}

class _NeoIconBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final bool isActive;
  const _NeoIconBtn(
      {required this.icon, required this.onTap, this.isActive = false});
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isActive ? AppColors.primary : AppColors.cardBackground,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
              color: isActive ? AppColors.primary : AppColors.glassBorder),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 8,
                offset: const Offset(0, 4))
          ],
        ),
        child: Icon(icon,
            color: isActive ? AppColors.darkBackground : AppColors.textPrimary),
      ),
    );
  }
}
