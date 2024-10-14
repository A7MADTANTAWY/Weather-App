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
  double pressure;
  // double visibility;

  WeatherModel({
    // required this.feelsLike,
    required this.pressure,
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
      pressure:
          (json['main']['pressure'] as num).toDouble(), // Explicit conversion
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
  // https://openweathermap.org/weather-conditions
  Future<String> getCurrentLottie(bool insight) async {
    if (id >= 200 && id <= 232) {
      // Thunderstorm
      if (insight) {
        return "assets/thunderAndRain.json";
      } else {
        return "assets/sunCloudRainThunder.json";
      }
    } else if (id >= 300 && id <= 321) {
      // Drizzle
      if (insight) {
        return "assets/nightCloudRain.json";
      } else {
        return "assets/sunCloudRain.json";
      }
    } else if (id >= 500 && id <= 531) {
      // Rain
      if (insight) {
        return "assets/nightCloudRain.json";
      } else {
        return "assets/sunCloudRain.json";
      }
    } else if (id >= 600 && id <= 622) {
      // Snow
      if (insight) {
        return "assets/nightCloudSnow.json";
      } else {
        return "assets/sunCloudSnow.json";
      }
    } else if (id >= 701 && id <= 781) {
      // Atmosphere (e.g., fog, mist)
      return 'assets/mist.json';
    } else if (id == 800) {
      // Clear sky
      if (insight) {
        return "assets/night .json";
      } else {
        return "assets/sunny.json";
      }
    } else if (id >= 801 && id <= 804) {
      // Clouds
      if (insight) {
        return "assets/nightWithClouds.json";
      } else {
        return "assets/sunWithClouds.json";
      }
    } else {
      // Default
      if (insight) {
        return "assets/night .json";
      } else {
        return "assets/sunny.json";
      }
    }
  }
}
