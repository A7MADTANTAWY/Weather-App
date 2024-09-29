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
  String lottieAnimation =
      "assets/default_weather.json"; // Default Lottie asset
  bool isNight = false; // Add the isNight variable

  @override
  void dispose() {
    timer?.cancel(); // Cancel the timer when the widget is disposed
    super.dispose();
  }

  void getCurrentTime() {
    DateTime now = DateTime.now();
    String formattedTime =
        DateFormat('hh:mm a').format(now); // Format to hh:mm a
    setState(() {
      currentTime = formattedTime;
    });
  }

  void getCurrentDate() {
    DateTime now = DateTime.now();
    String formattedDate =
        DateFormat('EEEE, MMMM d, yyyy').format(now); // Example format
    setState(() {
      date = formattedDate; // Update state with formatted date
    });
  }

  void fetchUserLocation() async {
    try {
      Position pos = await getCurrentLocation();

      // Print the fetched position to verify that the location is dynamic
      print(
          'User location fetched: Latitude ${pos.latitude}, Longitude ${pos.longitude}');

      setState(() {
        position = pos;
      });

      if (position != null) {
        convertCoordinatesToAddress(position!.latitude, position!.longitude);
        getWeather(position!.latitude,
            position!.longitude); // Ensure dynamic location is used
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
      // Print the dynamic location coordinates
      print('Fetching weather for latitude: $latitude, longitude: $longitude');

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
        if (w != null) {
          w.temp = convertTemperature(w.temp);
          w.maxTemp = convertTemperatureMax(w.maxTemp);
          w.minTemp = convertTemperatureMin(w.minTemp);
        }
        isLoading = false;

        // Calculate sunset time and update isNight based on it
        DateTime sunsetTime = getSunsetTime(latitude, longitude);
        isNight = isNightTime(sunsetTime); // Update the isNight variable
      });

      // Fetch the appropriate Lottie animation based on the isNight value
      w?.getCurrentLottie(isNight).then((animation) {
        setState(() {
          lottieAnimation = animation;
        });
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

  // Helper function to create WeatherCard widget
  Widget buildWeatherCard(String title, String info, Icon icon) {
    return WeatherCard(
      color: isNight ? consts.night_gradient2 : constants.day_gradient2,
      icon: icon,
      info: info,
      title: title,
    );
  }

  @override
  void initState() {
    super.initState();
    checkLocationPermission();
    fetchUserLocation();
    getCurrentTime();
    getCurrentDate(); // Call to initialize date
    timer = Timer.periodic(const Duration(minutes: 5), (Timer t) {
      if (position != null) {
        getWeather(position!.latitude, position!.longitude); // Update weather periodically
      }
    });
    timer = Timer.periodic(const Duration(seconds: 1),
        (Timer t) => getCurrentTime()); // Update time every second
  }

  @override
  Widget build(BuildContext context) {
    // Ensure to re-fetch weather based on dynamic position if it changes
    if (position != null) {
      getWeather(
          position!.latitude,
          position!
              .longitude); // Update weather every time the position changes
    }

    // Get the sunset time (replace this with your actual logic)
    DateTime sunsetTime =
        getSunsetTime(position?.latitude ?? 0, position?.longitude ?? 0);

    isNight = isNightTime(sunsetTime); // Check if it's night

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
                          '${weather?.temp.toInt() ?? 0}°',
                          style: const TextStyle(
                            fontSize: 80,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(height: 5),
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
                      const SizedBox(height: 60),
                      Lottie.asset(
                        lottieAnimation, // Use the updated Lottie animation
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            weather?.weatherCondition ?? "Unknown",
                            style: const TextStyle(
                              fontSize: 30,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(width: 10),
                          isNight
                              ? const Icon(
                                  Icons.nights_stay_outlined,
                                  color: Color(0xffffffff),
                                  size: 30,
                                )
                              : const Icon(
                                  Icons.wb_sunny_outlined,
                                  color: Color(0xffffffff),
                                  size: 30,
                                )
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          buildWeatherCard(
                            'Wind speed',
                            '${weather?.windSpeed ?? nullValue} km/h',
                            const Icon(
                              Icons.wind_power_outlined,
                              color: Colors.white,
                            ),
                          ),
                          buildWeatherCard(
                            'Humidity',
                            '${weather?.humidity.toInt() ?? nullValue}%',
                            const Icon(
                              Icons.water_drop_outlined,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          buildWeatherCard(
                            'Min',
                            '${weather?.minTemp.toInt() ?? nullValue}°',
                            const Icon(
                              Icons.arrow_drop_down,
                              color: Colors.white,
                            ),
                          ),
                          buildWeatherCard(
                            'Max',
                            '${weather?.maxTemp.toInt() ?? nullValue}°',
                            const Icon(
                              Icons.arrow_drop_up,
                              color: Colors.white,
                            ),
                          ),
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
