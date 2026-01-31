# Heat Watch - Urban Heat Intelligence Platform 🌿🌡️

A professional Flutter application designed to map urban heat islands, identify vulnerable populations, and simulate green interventions for a cooler, more equitable city.

![App Splash Screen](assets/images/splash.png)

## 🚀 Key Features

### 🗺️ Interactive Heat Map
- **Real-time Visualization**: View temperature gradients across city wards.
- **Toggle Modes**: Switch between Day and Night heat distribution.
- **Smart Markers**: Tap any zone to see detailed temperature metrics.
- **Dynamic Legend**: Color-coded scale from Cool (<35°C) to Extreme (>43°C).

### 📊 Heat Inequality Index (HII)
- **Vulnerability Analysis**: Ranks wards based on a composite risk score.
- **Comprehensive Metrics**: Analyzes factors like:
  - Population Density
  - Green Cover %
  - Vulnerable Age Groups
  - Hospital Access
- **Visual Analytics**: Beautiful bar charts and risk distribution graphs.

### 🌳 Simulation & Intervention
- **Impact Prediction**: Simulate planting trees or installing cool roofs.
- **Before/After Comparisons**: Instant feedback on temperature reduction.
- **Cost Estimation**: Projected budget requirements for interventions.
- **Interactive Placement**: Drag-and-drop interface for planning green zones.

### 📱 Modern & Beautiful UI/UX
- **Nature-Themed Design**: Soothing greens and earth tones.
- **Glassmorphism**: Modern, translucent UI elements.
- **Smooth Animations**: Professional transitions and interactive feedback.
- **Dark Mode**: Eye-friendly dark forest theme.

---

## 🛠️ Tech Stack

- **Framework**: Flutter (Dart)
- **Maps**: `flutter_map` with OpenStreetMap
- **State Management**: `provider`
- **Charts**: `fl_chart`
- **Animations**: `flutter_animate`
- **Icons**: `flutter_launcher_icons` (Custom Adaptive Icons)
- **backend**: (Mocked for Demo) Satellite & Weather Data Service

---

## 📸 Screenshots

| Splash Screen | Heat Map | Inequality Analysis | Simulation |
|:---:|:---:|:---:|:---:|
| <img src="assets/images/splash.png" width="200" /> | <img src="assets/images/logo.png" width="200" /> | <img src="assets/images/logo.png" width="200" /> | <img src="assets/images/logo.png" width="200" /> |

---

## 🏁 Getting Started

### Prerequisites
- [Flutter SDK](https://flutter.dev/docs/get-started/install) (3.0+)
- Android Studio / VS Code

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/yourusername/heat-watch.git
   cd heat_watch
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Run the app**
   ```bash
   flutter run
   ```

---

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

1. Fork the project
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

---

## 📄 License

Distributed under the MIT License. See `LICENSE` for more information.

---

**Heat Watch** — Cooling our cities, one pixel at a time. 🌍✨
