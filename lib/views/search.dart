import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geocoding_platform_interface/src/models/placemark.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:testing/const/const.dart' as constants;
import 'package:testing/models/weather_model.dart';
import 'package:testing/services/get_current_city_name.dart';
import 'package:testing/services/weather_service.dart';
import 'package:testing/views/loading.dart';
import 'package:testing/widgets/appbar.dart';
import 'package:testing/widgets/card.dart';

class SearchResult extends StatefulWidget {
  final double latitude;
  final double longitude;

  const SearchResult(
      {super.key, required this.latitude, required this.longitude});

  @override
  State<SearchResult> createState() => _SearchResultState();
}

class _SearchResultState extends State<SearchResult> {
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
  void initState() {
    super.initState();
    initializeTimeAndDate();
    fetchWeather();
    startTimers();
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  // Time and Date Initialization
  void initializeTimeAndDate() {
    getCurrentTime();
    getCurrentDate();
  }

  void startTimers() {
    // Update time every second
    timer = Timer.periodic(const Duration(seconds: 1), (_) => getCurrentTime());
  }

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
    final TextEditingController _controller = TextEditingController();
  String _result = '';

  Future<void> _convertAddressToLatLon(String address) async {
    try {
      List<Location> locations = await locationFromAddress(address);
      if (locations.isNotEmpty) {
        final lat = locations.first.latitude;
        final lon = locations.first.longitude;
        setState(() {
          _result = 'Latitude: $lat, Longitude: $lon';
        });
      } else {
        setState(() {
          _result = 'No locations found.';
        });
      }
    } catch (e) {
      setState(() {
        _result = 'Error: $e';
      });
    }
  }

  // Method to return the latitude and longitude as a tuple
  Future<List<double>?> getLatLon(String address) async {
    try {
      List<Location> locations = await locationFromAddress(address);
      if (locations.isNotEmpty) {
        return [locations.first.latitude, locations.first.longitude];
      }
    } catch (e) {
      print('Error: $e');
    }
    return null; // Return null if no locations found or error occurs
  }

  Future<void> fetchWeather() async {
    await convertCoordinatesToAddress(widget.latitude, widget.longitude);
    await getWeather(widget.latitude, widget.longitude);
  }

  Future<void> convertCoordinatesToAddress(
      double latitude, double longitude) async {
    try {
      Placemark? addr = await getAddressFromCoordinates(latitude, longitude);
      setState(() {
        address = addr;
      });
    } catch (e) {
      debugPrint('Error converting coordinates to address: $e');
    }
  }

  Future<void> getWeather(double latitude, double longitude) async {
    try {
      WeatherModel? w = await WeatherService()
          .getCurrentWeather(lat: latitude, lon: longitude);
      updateWeather(w, latitude, longitude);
    } catch (e) {
      debugPrint('Error fetching weather: $e');
    }
  }

  void updateWeather(WeatherModel? w, double latitude, double longitude) {
    if (w != null) {
      setState(() {
        weather = w
          ..temp = _convertTemperature(w.temp)
          ..maxTemp = _convertTemperatureMax(w.maxTemp)
          ..minTemp = _convertTemperatureMin(w.minTemp);
        isLoading = false;
        isNight = _isNightTime(_getSunsetTime(latitude, longitude),
            _getSunriseTime(latitude, longitude));
      });

      weather?.getCurrentLottie(isNight).then((animation) {
        setState(() {
          lottieAnimation = animation;
        });
      });
    }
  }

  double _convertTemperature(double temp) => (temp - 273.15).roundToDouble();
  double _convertTemperatureMax(double temp) => (temp - 273.15).ceilToDouble();
  double _convertTemperatureMin(double temp) => (temp - 273.15).floorToDouble();

  bool _isNightTime(DateTime sunset, DateTime sunrise) {
    DateTime now = DateTime.now();
    return now.isAfter(sunset) || now.isBefore(sunrise);
  }

  DateTime _getSunsetTime(double latitude, double longitude) {
    return DateTime.now()
        .copyWith(hour: 18, minute: 0); // Example sunset at 18:00
  }

  DateTime _getSunriseTime(double latitude, double longitude) {
    return DateTime.now()
        .copyWith(hour: 6, minute: 0); // Example sunrise at 6:00 AM
  }

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
    return isLoading
        ? Loading(isNight: isNight)
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
              appBar: buildAppBar(address?.subAdministrativeArea ?? ''),
              body: _buildBody(),
            ),
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
            const SizedBox(height: 20),
            const SizedBox(height: 60),
            Lottie.asset(lottieAnimation),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(weather?.weatherConditionDis ?? "Unknown",
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
