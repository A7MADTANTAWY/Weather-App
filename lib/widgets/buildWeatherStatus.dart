import 'package:flutter/material.dart';
import 'package:testing/widgets/card.dart';
import 'package:testing/const/const.dart' as constants;

Widget buildWeatherCard({
  required String title,
  required String info,
  required Icon icon,
  required bool isNight,
}) {
  return WeatherCard(
    color: isNight ? constants.night_gradient2 : constants.day_gradient2,
    icon: icon,
    info: info,
    title: title,
  );
}

Widget buildWeatherStats({
  required dynamic weather,
  required bool isNight,
  required nullValue,
}) {
  // Convert temperature from Kelvin to Celsius
  double convertTemp(double kelvin) => (kelvin - 273.15).roundToDouble();

  // Convert wind speed from m/s to km/h
  double convertWindSpeed(double speed) => (speed * 3.6).roundToDouble();

  return Column(
    children: [
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          buildWeatherCard(
            title: 'Wind Speed',
            info:
                '${weather != null ? convertWindSpeed(weather.windSpeed) : nullValue} km/h',
            icon: const Icon(Icons.wind_power_outlined, color: Colors.white),
            isNight: isNight,
          ),
          buildWeatherCard(
            title: 'Humidity',
            info: '${weather?.humidity ?? nullValue} %',
            icon: const Icon(Icons.water, color: Colors.white),
            isNight: isNight,
          ),
        ],
      ),
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          buildWeatherCard(
            title: 'Min Temp',
            info:
                '${weather != null ? convertTemp(weather.minTemp) : nullValue} °C',
            icon: const Icon(Icons.thermostat, color: Colors.white),
            isNight: isNight,
          ),
          buildWeatherCard(
            title: 'Max Temp',
            info:
                '${weather != null ? convertTemp(weather.maxTemp) : nullValue} °C',
            icon: const Icon(Icons.thermostat, color: Colors.white),
            isNight: isNight,
          ),
        ],
      ),
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          buildWeatherCard(
            title: 'Pressure',
            info: '${weather?.pressure ?? nullValue} hPa',
            icon: const Icon(Icons.compress, color: Colors.white),
            isNight: isNight,
          ),
        ],
      ),
    ],
  );
}
