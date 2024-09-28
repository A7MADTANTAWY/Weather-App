import 'package:dio/dio.dart';
import 'package:testing/models/weather_model.dart';

class WeatherService {
  final Dio dio = Dio();
  Future<WeatherModel> getCurrentWeather(
      {required double lat, required double lon}) async {
    Response response = await dio.get(
        'https://api.openweathermap.org/data/2.5/weather?lat=29&lon=31&appid=65b66e13e6cb6fcc6f455569594db9b1');
    WeatherModel weatherModel = WeatherModel.fromJson(response.data);
    return weatherModel;
  }
}
