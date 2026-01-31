# 🌡️ Heat Watch - Urban Heat Intelligence Platform

A professional Flutter application that maps urban heat islands, identifies vulnerable populations through a **Heat Inequality Index (HII)**, and simulates intervention impacts.

![Flutter](https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white)
![Dart](https://img.shields.io/badge/Dart-0175C2?style=for-the-badge&logo=dart&logoColor=white)

## ✨ Features

### 🏠 Dashboard
- Real-time city heat overview with critical alerts
- Key statistics with animated cards
- Quick action navigation

### 🗺️ Interactive Heat Map
- Google Maps integration with heat overlay
- Day/Night temperature toggle
- Ward-level temperature markers

### 📊 Heat Inequality Index (HII)
- **Unique vulnerability scoring** combining temperature, demographics, and infrastructure
- Risk level classification (Low/Moderate/High/Extreme)
- Ranked ward visualization

### 🌳 Intervention Simulator
- Interactive simulation of cooling interventions (Trees, Cool Roofs, Green Spaces)
- Real-time impact calculation and ROI analysis
- Before/after temperature comparison

## 🚀 Getting Started

```bash
cd heat_watch
flutter pub get
flutter run
```

**Note**: App works perfectly with mock data. See [API_GUIDE.md](API_GUIDE.md) for optional API setup.

## 🧮 Heat Inequality Index Algorithm

```
HII = Temperature(35%) + PopDensity(20%) + Vulnerable(20%) + 
      (100-GreenCover)(15%) + (100-HospitalAccess)(10%)

Risk: Extreme ≥75, High ≥50, Moderate ≥25, Low <25
```

## 📊 Mock Data

Includes realistic data for 12 Delhi NCR wards with demographics, temperature, and infrastructure metrics.

## 🛠️ Technologies

Flutter • Provider • Google Maps • FL Chart • Google Fonts • Flutter Animate

---

**Built with ❤️ for smarter, cooler cities**
