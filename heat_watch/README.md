# Heat Watch 🔥

Heat Watch is a comprehensive mobile application designed to monitor, analyze, and mitigate urban heat inequality in New Delhi. It combines live weather data with static vulnerability metrics to provide actionable insights and simulate the impact of urban interventions.

## 🌟 Key Features

### 1. 🌡️ Live Heat Monitoring
*   **Real-time Data**: Integrates with the **Open-Meteo API** to fetch live temperature updates for specific wards.
*   **Dynamic HII**: The **Heat Inequality Index (HII)** is recalculated on-the-fly, combining live temperature with population density, green cover, and hospital access metrics.
*   **Night Mode**: Toggle between Day and Night heat risks to see how thermal load persists after sunset.

### 2. 🗺️ Interactive Heat Map
*   **Visual Layers**: Color-coded heat map overlay indicating risk levels from Low (Green) to Extreme (Red).
*   **Custom Controls**: Switch between **Satellite** and **Normal** views, toggle **Night Mode**, and jump to your **Live Location**.
*   **Ward Insights**: Tap on any ward marker to see specific details like Temperature, Ward Name, and Risk Level.

### 3. 🏗️ Smart Intervention Simulator
*   **Site Analysis**: Tap any location on the map to get an instant analysis of the Ward's specific vulnerabilities (e.g., "High Density: 60k/km²" or "Low Green Cover: 5%").
*   **Intelligent Recommendations**: The app automatically suggests the most effective intervention based on the site analysis:
    *   **Cool Roofs** 🏠: Recommended for high-density areas (>20k/km²).
    *   **Urban Forestry** 🌳: Recommended for areas with critical green cover gaps (<15%).
    *   **Green Spaces** 🌿: Recommended for general cooling in moderate density zones.
*   **Impact Simulation**: Run simulations to see the potential impact of these interventions:
    *   **Temperature Drop**: Estimated cooling effect (e.g., -1.2°C).
    *   **Affected Population**: Number of citizens benefiting from the change.
    *   **Cost Estimation**: Budgetary projections for the intervention.

### 4. 📊 Data-Driven Inequality Index
*   **Realistic Data**: Powered by research-backed population density figures for New Delhi wards (e.g., Shahdara, Narela, Paharganj).
*   **Vulnerability Metrics**: 
    *   Population Density
    *   Green Cover Percentage
    *   Socio-Economic Factors (Income levels)
    *   Hospital Accessibility

## 🎨 Design & UI
*   **Glassmorphism**: Mdern, translucent UI elements for a premium feel.
*   **Neo-Brutalism**: Bold, tactile buttons and controls.
*   **Smooth Animations**: Fluid transitions using `flutter_animate` for a polished user experience.

## 🛠️ Tech Stack
*   **Framework**: Flutter (Dart)
*   **State Management**: Provider
*   **Maps**: Google Maps Flutter
*   **API**: Open-Meteo (Weather Data)
*   **Services**: Geolocator (Location Services)

## 🚀 Getting Started

1.  **Clone the repository**.
2.  **Install Dependencies**:
    ```bash
    flutter pub get
    ```
3.  **Run the App**:
    ```bash
    flutter run
    ```
