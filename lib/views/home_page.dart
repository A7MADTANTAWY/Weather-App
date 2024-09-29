import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geocoding_platform_interface/src/models/placemark.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:testing/const/const.dart' as constants;
import 'package:testing/models/weather_model.dart';
import 'package:testing/services/get_current_city_name.dart'; // For reverse geocoding
import 'package:testing/services/get_current_location_as_lat_lon.dart';
import 'package:testing/services/weather_service.dart';
import 'package:testing/views/loading.dart';
import 'package:testing/widgets/card.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Position? position;
  Placemark? address;
  WeatherModel? weather;
  String date = '';
  String currentTime = '';
  Timer? timer;
  bool isLoading = true;
  double nullValue = 0.0;
  String lottieAnimation = "assets/default_weather.json";
  bool isNight = false;

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    checkLocationPermission();
    fetchUserLocation();
    initializeTimeAndDate();
    startTimers();
  }

  // Time and Date Initialization
  void initializeTimeAndDate() {
    getCurrentTime();
    getCurrentDate();
  }

  void startTimers() {
    timer = Timer.periodic(const Duration(minutes: 5), (_) {
      if (position != null) getWeather(position!.latitude, position!.longitude);
    });
    timer = Timer.periodic(const Duration(seconds: 1), (_) => getCurrentTime());
  }

  // Time and Date Formatting
  void getCurrentTime() {
    setState(() {
      currentTime = DateFormat('hh:mm a').format(DateTime.now());
    });
  }

  void getCurrentDate() {
    setState(() {
      date = DateFormat('EEEE, MMMM d, yyyy').format(DateTime.now());
    });
  }

  // User Location and Address
  Future<void> fetchUserLocation() async {
    try {
      Position pos = await getCurrentLocation();
      setState(() {
        position = pos;
      });

      if (position != null) {
        convertCoordinatesToAddress(position!.latitude, position!.longitude);
        getWeather(position!.latitude, position!.longitude);
      }
    } catch (e) {
      debugPrint('Error: $e');
    }
  }

  Future<void> convertCoordinatesToAddress(
      double latitude, double longitude) async {
    try {
      Placemark? addr = await getAddressFromCoordinates(latitude, longitude);
      setState(() {
        address = addr;
      });
    } catch (e) {
      debugPrint('Error: $e');
    }
  }

  // Weather Data
  Future<void> getWeather(double latitude, double longitude) async {
    try {
      WeatherModel? w = await WeatherService()
          .getCurrentWeather(lat: latitude, lon: longitude);
      if (w != null) updateWeather(w, latitude, longitude);
    } catch (e) {
      debugPrint('Error: $e');
    }
  }

  void updateWeather(WeatherModel w, double latitude, double longitude) {
    setState(() {
      weather = w
        ..temp = _convertTemperature(w.temp)
        ..maxTemp = _convertTemperatureMax(w.maxTemp)
        ..minTemp = _convertTemperatureMin(w.minTemp);
      isLoading = false;
      isNight = _isNightTime(_getSunsetTime(latitude, longitude));
    });

    weather?.getCurrentLottie(isNight).then((animation) {
      setState(() {
        lottieAnimation = animation;
      });
    });
  }

  double _convertTemperature(double temp) => (temp - 273.15).roundToDouble();
  double _convertTemperatureMax(double temp) => (temp - 273.15).ceilToDouble();
  double _convertTemperatureMin(double temp) => (temp - 273.15).floorToDouble();

  // Night Detection
  bool _isNightTime(DateTime sunset) => DateTime.now().isAfter(sunset);

  DateTime _getSunsetTime(double latitude, double longitude) {
    return DateTime.now()
        .copyWith(hour: 18, minute: 0); // Example sunset at 18:00
  }

  // UI Helper for WeatherCard
  Widget buildWeatherCard(String title, String info, Icon icon) {
    return WeatherCard(
      color: isNight ? constants.night_gradient2 : constants.day_gradient2,
      icon: icon,
      info: info,
      title: title,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (position != null) {
      getWeather(position!.latitude, position!.longitude);
    }

    isNight = _isNightTime(
        _getSunsetTime(position?.latitude ?? 0, position?.longitude ?? 0));

    return isLoading
        ? const Loading()
        : Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  isNight ? constants.night_gradient1 : constants.day_gradient1,
                  isNight ? constants.night_gradient2 : constants.day_gradient2,
                  isNight ? constants.night_gradient3 : constants.day_gradient3,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Scaffold(
              backgroundColor: Colors.transparent,
              appBar: _buildAppBar(),
              body: _buildBody(),
            ),
          );
  }

  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      title: Text(
        address?.subAdministrativeArea ?? '',
        style: const TextStyle(color: Colors.white, fontSize: 20),
      ),
      actions: const [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 15),
          child: Icon(Icons.search, color: Colors.white, size: 26),
        )
      ],
    );
  }

  Widget _buildBody() {
    return ListView(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text('${weather?.temp.toInt() ?? 0}°',
                style: const TextStyle(fontSize: 80, color: Colors.white)),
            const SizedBox(height: 5),
            Text(address?.locality ?? "",
                style: const TextStyle(fontSize: 16, color: Colors.white)),
            Text(date,
                style: const TextStyle(fontSize: 16, color: Colors.white)),
            const SizedBox(height: 60),
            Lottie.asset(lottieAnimation),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(weather?.weatherCondition ?? "Unknown",
                    style: const TextStyle(fontSize: 30, color: Colors.white)),
                const SizedBox(width: 10),
                Icon(
                  isNight
                      ? Icons.nights_stay_outlined
                      : Icons.wb_sunny_outlined,
                  color: Colors.white,
                  size: 30,
                ),
              ],
            ),
            const SizedBox(height: 10),
            _buildWeatherStats(),
          ],
        ),
      ],
    );
  }

  Widget _buildWeatherStats() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            buildWeatherCard(
                'Wind speed',
                '${weather?.windSpeed ?? nullValue} km/h',
                const Icon(Icons.wind_power_outlined, color: Colors.white)),
            buildWeatherCard(
                'Humidity',
                '${weather?.humidity.toInt() ?? nullValue}%',
                const Icon(Icons.water_drop_outlined, color: Colors.white)),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            buildWeatherCard('Min', '${weather?.minTemp.toInt() ?? nullValue}°',
                const Icon(Icons.arrow_drop_down, color: Colors.white)),
            buildWeatherCard('Max', '${weather?.maxTemp.toInt() ?? nullValue}°',
                const Icon(Icons.arrow_drop_up, color: Colors.white)),
          ],
        ),
      ],
    );
  }
}
