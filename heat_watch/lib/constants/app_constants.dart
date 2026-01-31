class AppConstants {
  // App Info
  static const String appName = 'Heat Watch';
  static const String appTagline = 'Urban Heat Intelligence Platform';

  // API Endpoints (Mock for now)
  static const String baseUrl = 'https://api.heatwatch.com';
  static const String heatDataEndpoint = '/api/heat-data';
  static const String weatherEndpoint = '/api/weather';
  static const String demographicsEndpoint = '/api/demographics';

  // Heat Inequality Index Weights
  static const double temperatureWeight = 0.35;
  static const double populationDensityWeight = 0.20;
  static const double vulnerablePopulationWeight = 0.20;
  static const double greenCoverWeight = 0.15;
  static const double hospitalAccessWeight = 0.10;

  // Temperature Constants
  static const double minTemp = 25.0; // Celsius
  static const double maxTemp = 50.0; // Celsius
  static const double comfortableTemp = 30.0;
  static const double dangerousTemp = 42.0;

  // Simulation Constants
  static const double treeCoolingEffect = 2.5; // °C reduction per tree cluster
  static const double coolRoofEffect = 3.0; // °C reduction
  static const double greenSpaceEffect = 1.8; // °C per 100m² park

  // Map Defaults
  static const double defaultLat = 28.6139; // New Delhi
  static const double defaultLng = 77.2090;
  static const double defaultZoom = 12.0;

  // UI Constants
  static const double cardElevation = 0.0;
  static const double borderRadius = 16.0;
  static const double spacing = 16.0;
  static const double smallSpacing = 8.0;

  // Animation Durations
  static const int shortAnimationMs = 200;
  static const int mediumAnimationMs = 300;
  static const int longAnimationMs = 500;
}
