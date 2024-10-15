import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:testing/widgets/buildWeatherStatus.dart';

Widget buildBody({
  required dynamic weather,
  required dynamic cityName,
  required dynamic address,
  required String date,
  required String lottieAnimation,
  required dynamic isNight,
  required dynamic nullValue,
}) {
  return ListView(
    children: [
      Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 20),
          // Temperature Display
          Text(
            '${weather?.temp?.toInt() ?? 0}°',
            style: TextStyle(
              fontSize: 100,
              color: Colors.white,
              fontWeight: FontWeight.bold,
              shadows: [
                Shadow(
                  color: Colors.black.withOpacity(0.5),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),

          // City Name
          Text(
            cityName.isNotEmpty ? cityName : (address?.locality ?? ""),
            style: const TextStyle(
              fontSize: 24,
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 5),

          // Date
          Text(
            date,
            style: const TextStyle(
              fontSize: 18,
              color: Colors.white70,
              fontStyle: FontStyle.italic,
            ),
          ),
          const SizedBox(height: 20),

          // Weather Animation
          SizedBox(
            width: 250,
            height: 250,
            child: Lottie.asset(lottieAnimation),
          ),
          const SizedBox(height: 20),

          // Weather Condition and Icon
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                weather?.weatherConditionDis ?? "Unknown",
                style: const TextStyle(
                  fontSize: 28,
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(width: 10),
              Icon(
                isNight ? Icons.nights_stay_rounded : Icons.wb_sunny_rounded,
                color: Colors.white,
                size: 35,
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Weather Stats
          buildWeatherStats(
            isNight: isNight,
            nullValue: nullValue,
            weather: weather,
          ),
        ],
      ),
    ],
  );
}
