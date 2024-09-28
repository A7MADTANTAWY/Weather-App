class WeatherModel {
  String weatherCondition;
  String weatherConditionDis;
  double temp;
  double maxTemp;
  double minTemp;
  double humidity;
  double windSpeed;
  double id;
  // double feelsLike;
  // double pressure;
  // double visibility;

  WeatherModel({
    // required this.feelsLike,
    // required this.pressure,
    // required this.visibility,
    required this.weatherCondition,
    required this.weatherConditionDis,
    required this.humidity,
    required this.id,
    required this.maxTemp,
    required this.minTemp,
    required this.temp,
    required this.windSpeed,
  });

  factory WeatherModel.fromJson(Map<String, dynamic> json) {
    return WeatherModel(
      weatherCondition: json['weather'][0]['main'],
      weatherConditionDis: json['weather'][0]['description'],
      // feelsLike:
      //     (json['main']['feelsLike'] as num).toDouble(), // Explicit conversion
      // pressure:
      //     (json['main']['pressure'] as num).toDouble(), // Explicit conversion
      // visibility:
      //     (json['main']['visibility'] as num).toDouble(), // Explicit conversion
      humidity:
          (json['main']['humidity'] as num).toDouble(), // Explicit conversion
      id: (json['weather'][0]['id'] as num).toDouble(), // Explicit conversion
      maxTemp:
          (json['main']['temp_max'] as num).toDouble(), // Explicit conversion
      minTemp:
          (json['main']['temp_min'] as num).toDouble(), // Explicit conversion
      temp: (json['main']['temp'] as num).toDouble(), // Explicit conversion
      windSpeed:
          (json['wind']['speed'] as num).toDouble(), // Explicit conversion
    );
  }
}
