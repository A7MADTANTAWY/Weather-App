import 'package:flutter/material.dart';

// ignore: must_be_immutable
class WeatherCard extends StatelessWidget {
  Icon icon;
  Color color;
  String info;
  String title;
  WeatherCard(
      {super.key,
      required this.color,
      required this.icon,
      required this.info,
      required this.title});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        child: Container(
          height: 100,
          decoration: BoxDecoration(
            color: color, // Background color
            borderRadius: BorderRadius.circular(12), // Rounded corners
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1), // Shadow color (lighter)
                spreadRadius: 1, // Slight spread
                blurRadius: 4, // Subtle blur
                offset: const Offset(0, 2), // Slight vertical offset
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    icon,
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 5),
                      child: Text(
                        title,
                        style: const TextStyle(
                            color: Color(0xffffffff), fontSize: 18),
                      ),
                    )
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 9),
                  child: Text(
                    info,
                    style:
                        const TextStyle(color: Color(0xffffffff), fontSize: 30),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
