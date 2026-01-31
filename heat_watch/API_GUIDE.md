# 🔑 API Keys Guide for Heat Watch

This document explains where and how to obtain the required API keys for the Heat Watch app.

## Required APIs

### 1. Google Maps API 🗺️
**Purpose**: Display interactive heat maps with location markers

**How to obtain:**
1. Go to [Google Cloud Console](https://console.cloud.google.com/)
2. Create a new project or select existing one
3. Enable these APIs:
   - Maps SDK for Android
   - Maps SDK for iOS (if building for iOS)
4. Go to "Credentials" → "Create Credentials" → "API Key"
5. Copy the API key
6. **Add to your app:**
   - Android: `android/app/src/main/AndroidManifest.xml`
     ```xml
     <meta-data
         android:name="com.google.android.geo.API_KEY"
         android:value="YOUR_API_KEY_HERE" />
     ```
   - iOS: `ios/Runner/AppDelegate.swift` (add `GMSServices.provideAPIKey("YOUR_API_KEY")`)

**Cost**: Free tier includes $200/month credit (approximately 28,000 map loads/month)

**Alternative (Free)**: Use `flutter_map` with OpenStreetMap instead of Google Maps

---

### 2. Weather Data API ☀️
**Purpose**: Real-time temperature and weather data

**Recommended: OpenWeatherMap**
1. Sign up at [OpenWeatherMap](https://openweathermap.org/api)
2. Free tier: 1,000 API calls/day
3. Select "Current Weather Data" API
4. Copy your API key from dashboard

**How to use in app:**
```dart
// In lib/services/heat_service.dart
const String weatherApiKey = 'YOUR_OPENWEATHER_API_KEY';
final url = 'https://api.openweathermap.org/data/2.5/weather?lat=$lat&lon=$lon&appid=$weatherApiKey';
```

**Alternatives:**
- **Weather.gov API** (USA only, FREE, no key required)
- **Weatherbit** (Free tier: 500 calls/day)
- **Tomorrow.io** (Free tier: 500 calls/day)

---

### 3. Satellite Imagery API 🛰️
**Purpose**: Land surface temperature data

**Option A: NASA MODIS (FREE)**
1. Register at [NASA Earthdata](https://urs.earthdata.nasa.gov/users/new)
2. Access MODIS LST data via [AppEEARS](https://appeears.earthdatacloud.nasa.gov/)
3. No API key needed for basic access
4. Download data in GeoTIFF format

**Option B: Sentinel Hub (Paid)**
1. Sign up at [Sentinel Hub](https://www.sentinel-hub.com/)
2. Get API credentials
3. Access Landsat 8/9 thermal data
4. Free trial available

**For Demo**: The app currently uses mock data, no API needed immediately

---

### 4. Demographics/Census API 📊
**Purpose**: Population density, age distribution, income data

**India (FREE)**:
- [Census India Open Data](https://censusindia.gov.in/census.website/)
- [data.gov.in](https://data.gov.in/) - No API key required
- Download datasets and import to app

**USA (FREE)**:
- [US Census Bureau API](https://www.census.gov/data/developers.html)
- Register for free API key
- 500 queries per day

**Global**:
- [UN Data API](http://data.un.org/) - Free, no key required
- [World Bank Open Data](https://data.worldbank.org/) - Free, no key required

---

## Current App Status 📱

**GOOD NEWS**: The app works perfectly RIGHT NOW with **MOCK DATA** - no APIs required for testing!

### What works without APIs:
- ✅ All UI screens and navigation
- ✅ Heat Inequality Index calculations
- ✅ Simulation engine
- ✅ Charts and visualizations
- ✅ 12 mock Delhi wards with realistic data

### What needs API keys:
- ⚠️ **Google Maps** - Required for map display (or switch to free OpenStreetMap)
- ⚠️ **Real weather data** - Optional, mock data works fine
- ⚠️ **Satellite imagery** - Optional for production deployment

---

## Setup Priority

### Phase 1 - Get Started (5 minutes)
1. **Google Maps API** - Most important for visual appeal
2. Run the app with mock data
3. Everything else works!

### Phase 2 - Add Real Data (Optional)
1. OpenWeatherMap API (free)
2. Census data downloads
3. Satellite imagery (advanced)

---

## Free Alternatives

If you want a **100% free app with no API setup**:

1. Replace `google_maps_flutter` with `flutter_map`:
   ```yaml
   # In pubspec.yaml
   # Remove: google_maps_flutter
   # Add: 
   flutter_map: ^6.0.0
   ```

2. Use OpenStreetMap (completely free, no key needed)

3. Use mock/downloaded data instead of live APIs

---

## Quick Start Command

For immediate testing without ANY API keys:

```bash
cd heat_watch
flutter run
```

The app will work with beautiful mock data for Delhi NCR! 🎉

---

## Need Help?

- **Google Maps Issues**: Check [official docs](https://developers.google.com/maps/documentation/android-sdk/get-api-key)
- **API Errors**: Most free tier limits are generous (1000+ calls/day)
- **Mock Data**: Current implementation in `lib/services/heat_service.dart`

---

**Remember**: For your hackathon/demo, the mock data is **MORE than sufficient** and looks completely realistic! Focus on the features and UI first. 🚀
