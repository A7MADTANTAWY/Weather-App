import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geocoding_platform_interface/src/models/placemark.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:testing/const/const.dart';
import 'package:testing/models/weather_model.dart';
import 'package:testing/services/get_current_city_name.dart'; // For reverse geocoding
import 'package:testing/services/get_current_location_as_lat_lon.dart';
import 'package:testing/services/weather_service.dart';
import 'package:testing/views/loading.dart';
import 'package:testing/widgets/card.dart'; // For fetching lat/lon
import 'package:testing/const/const.dart' as consts;
import 'package:testing/const/const.dart' as constants;

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

  @override
  void initState() {
    super.initState();
    checkLocationPermission();
    fetchUserLocation();
    getCurrentTime();
    getCurrentDate(); // Call to initialize date
    timer = Timer.periodic(const Duration(seconds: 1),
        (Timer t) => getCurrentTime()); // Update every second
  }

  void getCurrentTime() {
    DateTime now = DateTime.now();
    String formattedTime =
        DateFormat('hh:mm a').format(now); // Format to hh:mm:ss
    setState(() {
      currentTime = formattedTime;
    });
  }

  @override
  void dispose() {
    timer?.cancel(); // Cancel the timer when the widget is disposed
    super.dispose();
  }

  void fetchUserLocation() async {
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
      print('Error: $e');
    }
  }

  void convertCoordinatesToAddress(double latitude, double longitude) async {
    try {
      Placemark? addr = await getAddressFromCoordinates(latitude, longitude);
      setState(() {
        address = addr;
      });
    } catch (e) {
      print('Error: $e');
    }
  }

  void getWeather(double latitude, double longitude) async {
    try {
      WeatherModel? w = await WeatherService()
          .getCurrentWeather(lat: latitude, lon: longitude);
      double convertTemperature(double temp) {
        return (temp - 273.15).floorToDouble();
      }

      double convertTemperatureMax(double temp) {
        return (temp - 273.15).ceilToDouble();
      }

      double convertTemperatureMin(double temp) {
        return (temp - 273.15).floorToDouble();
      }

      setState(() {
        weather = w;
        w.temp = convertTemperature(w.temp);
        w.maxTemp = convertTemperatureMax(w.maxTemp);
        w.minTemp = convertTemperatureMin(w.minTemp);
        isLoading = false;
      });
    } catch (e) {
      print('Error: $e');
    }
  }

  // Function to check if it's night based on sunset time
  bool isNightTime(DateTime sunset) {
    DateTime now = DateTime.now();
    return now
        .isAfter(sunset); // returns true if the current time is after sunset
  }

  // Example sunset time calculation (replace with actual logic)
  DateTime getSunsetTime(double latitude, double longitude) {
    // Replace this with actual sunset calculation based on latitude and longitude
    DateTime now = DateTime.now();
    return DateTime(
        now.year, now.month, now.day, 18, 0); // Example: Sunset at 18:00
  }

  void getCurrentDate() {
    DateTime now = DateTime.now();
    String formattedDate =
        DateFormat('EEEE, MMMM d, yyyy').format(now); // Example format
    setState(() {
      this.date = formattedDate; // Update state with formatted date
    });
  }

  @override
  Widget build(BuildContext context) {
    // Get the sunset time (replace this with your actual logic)
    DateTime sunsetTime =
        getSunsetTime(position?.latitude ?? 0, position?.longitude ?? 0);

    bool isNight = isNightTime(sunsetTime); // Check if it's night

    return isLoading
        ? const Loading()
        : Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  isNight ? consts.night_gradient1 : constants.day_gradient1,
                  isNight ? consts.night_gradient2 : constants.day_gradient2,
                  isNight ? consts.night_gradient3 : constants.day_gradient3,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Scaffold(
              backgroundColor: Colors.transparent,
              appBar: AppBar(
                backgroundColor: Colors.transparent,
                elevation: 0,
                title: Text(
                  address?.subAdministrativeArea ?? '',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                  ),
                ),
                actions: const [
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 15),
                    child: Icon(
                      Icons.search,
                      color: Color(0xffffffff),
                      size: 26,
                    ),
                  )
                ],
              ),
              body: ListView(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 0),
                        child: Text(
                          '${weather!.temp.toInt()}°',
                          style: const TextStyle(
                            fontSize: 80,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 5,
                      ),
                      Text(
                        address?.locality ?? "",
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        date,
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(
                        height: 15,
                      ),
                      Lottie.asset(isNight
                          ? 'assets/night.json'
                          : 'assets/sunWithClouds.json'),
                      Text(
                        weather?.weatherCondition ?? "",
                        style: const TextStyle(
                          fontSize: 30,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          WeatherCard(
                            color: isNight ? night_gradient2 : day_gradient2,
                            icon: const Icon(
                              Icons.wind_power_outlined,
                              color: Color(0xffffffff),
                            ),
                            info: '${weather?.windSpeed ?? nullValue} km/h',
                            title: 'Wind speed',
                          ),
                          WeatherCard(
                            color: isNight ? night_gradient2 : day_gradient2,
                            icon: const Icon(
                              Icons.water_drop_outlined,
                              color: Color(0xffffffff),
                            ),
                            info: '${weather?.humidity ?? nullValue}%',
                            title: 'Humidity',
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          WeatherCard(
                            color: isNight ? night_gradient2 : day_gradient2,
                            icon: const Icon(
                              Icons.wb_sunny,
                              color: Color(0xffffffff),
                            ),
                            info: '${weather?.minTemp ?? nullValue}°',
                            title: 'Min Temp',
                          ),
                          WeatherCard(
                            color: isNight ? night_gradient2 : day_gradient2,
                            icon: const Icon(
                              Icons.wb_sunny,
                              color: Color(0xffffffff),
                            ),
                            info: '${weather?.maxTemp ?? nullValue}°',
                            title: 'Max Temp',
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          WeatherCard(
                              color: isNight ? night_gradient2 : day_gradient2,
                              icon: const Icon(
                                Icons.cloud,
                                color: Color(0xffffffff),
                              ),
                              info:
                                  '${weather?.weatherConditionDis ?? nullValue}',
                              title: "cloud description"),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
  }
}
