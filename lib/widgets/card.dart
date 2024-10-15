import 'package:flutter/material.dart';

// ignore: must_be_immutable
class WeatherCard extends StatelessWidget {
  Icon icon;
  Color color;
  String info;
  String title;
  WeatherCard({
    super.key,
    required this.color,
    required this.icon,
    required this.info,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        child: Container(
          height: 130, // Slightly taller for modern look
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [color.withOpacity(0.8), color], // Gradient effect
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20), // More rounded corners
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.15), // Softer shadow
                spreadRadius: 1,
                blurRadius: 8,
                offset: const Offset(0, 6), // Larger offset for depth
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment:
                  CrossAxisAlignment.start, // Modern left-aligned text
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(
                          8), // Add padding around the icon
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withOpacity(
                            0.3), // Transparent circle behind the icon
                      ),
                      child: icon,
                    ),
                    Text(
                      title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight:
                            FontWeight.w600, // Semi-bold for a modern look
                      ),
                    ),
                  ],
                ),
                const Spacer(), // Space between title and info
                Text(
                  info,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 25, // Larger text size for emphasis
                    fontWeight: FontWeight.bold, // Bold for a modern feel
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
