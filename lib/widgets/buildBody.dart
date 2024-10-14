 import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:testing/widgets/buildWeatherStatus.dart';

Widget buildBody({required dynamic weather,required dynamic cityName,required dynamic address, required String date,required String lottieAnimation,required dynamic isNight,required dynamic nullValue}) {
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
            buildWeatherStats(isNight: isNight, nullValue: nullValue, weather: weather),
          ],
        ),
      ],
    );
  }