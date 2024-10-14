import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:testing/models/weather_model.dart';

class WeatherService {
  final String apiKey = '8a4531158055819cb3de0d71caa7f2d4';
  final Dio dio = Dio();

  Future<WeatherModel> getCurrentWeather({
    required double lat,
    required double lon,
  }) async {
    Response response = await dio.get(
        'https://api.openweathermap.org/data/2.5/weather?lat=$lat&lon=$lon&appid=$apiKey');
    return WeatherModel.fromJson(response.data);
  }

  Future<WeatherModel?> getWeatherByCity(String city) async {
    try {
      Response response = await dio.get(
          'https://api.openweathermap.org/data/2.5/weather?q=$city&appid=$apiKey');
      return WeatherModel.fromJson(response.data);
    } catch (e) {
      debugPrint('Error fetching weather by city: $e');
      return null; // Handle errors and return null
    }
  }
}
