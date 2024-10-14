import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:testing/const/const.dart' as constants;
import 'package:testing/models/weather_model.dart';
import 'package:testing/services/get_current_city_name.dart';
import 'package:testing/services/get_current_location_as_lat_lon.dart';
import 'package:testing/services/weather_service.dart';
import 'package:testing/views/loading.dart';
import 'package:testing/widgets/appbar.dart'; // Ensure to import your buildAppBar
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
        cityName = city; // Update the cityName state variable with the searched city
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

  Widget buildWeatherCard(String title, String info, Icon icon) {
    return WeatherCard(
      color: isNight ? constants.night_gradient2 : constants.day_gradient2,
      icon: icon,
      info: info,
      title: title,
    );
  }

  @override
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
                  ? () => goBackToCurrentLocation() // Use a lambda for the back button
                  : null, // Set to null if the cityName is empty
            ),
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
            // Display the city name here
            Text(cityName.isNotEmpty ? cityName : (address?.locality ?? ""),
                style: const TextStyle(fontSize: 16, color: Colors.white)),
            Text(date,
                style: const TextStyle(fontSize: 16, color: Colors.white)),
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
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            buildWeatherCard(
                'Pressure',
                '${weather?.pressure.toInt() ?? nullValue} hPa',
                const Icon(Icons.speed_outlined, color: Colors.white)),
          ],
        ),
      ],
    );
  }
}
