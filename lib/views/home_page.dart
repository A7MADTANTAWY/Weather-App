import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:testing/const/const.dart' as constants;
import 'package:testing/models/weather_model.dart';
import 'package:testing/services/get_current_city_name.dart';
import 'package:testing/services/get_current_location_as_lat_lon.dart';
import 'package:testing/services/weather_service.dart';
import 'package:testing/views/loading.dart';
import 'package:testing/widgets/appbar.dart';
import 'package:testing/widgets/buildBody.dart';

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
  final TextEditingController _controller = TextEditingController();
  String cityName = ''; // State variable for the city name

  @override
  void initState() {
    super.initState();
    checkLocationPermission();
    fetchUserLocation();
    initializeTimeAndDate();
    startTimers();
  }

  @override
  void dispose() {
    timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void initializeTimeAndDate() {
    getCurrentTime();
    getCurrentDate();
  }

  void startTimers() {
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

  Future<void> fetchUserLocation() async {
    try {
      Position pos = await getCurrentLocation();
      setState(() {
        position = pos;
      });
      convertCoordinatesToAddress(position!.latitude, position!.longitude);
      getWeather(position!.latitude, position!.longitude);
    } catch (e) {
      debugPrint('Error fetching location: $e');
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

  Future<void> getWeatherByCity(String city) async {
    try {
      WeatherModel? w = await WeatherService().getWeatherByCity(city);
      updateWeather(w, position?.latitude ?? 0, position?.longitude ?? 0);
      setState(() {
        cityName = city; // Update the cityName state variable
      });
    } catch (e) {
      debugPrint('Error fetching weather by city: $e');
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

  void goBackToCurrentLocation() {
    setState(() {
      cityName = ''; // Clear the city name
      fetchUserLocation(); // Fetch the weather for the current location
    });
  }

  @override
  Widget build(BuildContext context) {
    if (position != null && weather == null) {
      getWeather(position!.latitude, position!.longitude);
    }

    isNight = _isNightTime(
      _getSunsetTime(position?.latitude ?? 0, position?.longitude ?? 0),
      _getSunriseTime(position?.latitude ?? 0, position?.longitude ?? 0),
    );

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
              appBar: buildAppBar(
                cityName.isNotEmpty
                    ? cityName
                    : (address?.subAdministrativeArea ?? ''),
                _controller,
                (city) {
                  getWeatherByCity(city);
                  _controller.clear(); // Clear the input field after search
                },
                cityName.isNotEmpty
                    ? () =>
                        goBackToCurrentLocation() // Use a lambda for the back button
                    : null, // Set to null if the cityName is empty
              ),
              body: Column(
                children: [
                  Expanded(
                    child: buildBody(
                      date: date,
                      lottieAnimation: lottieAnimation,
                      weather: weather,
                      cityName: cityName.isNotEmpty
                          ? cityName
                          : (address?.locality ?? ''),
                      address: address,
                      isNight: isNight,
                      nullValue: nullValue,
                    ),
                  ),
                ],
              ),
            ),
          );
  }
}
