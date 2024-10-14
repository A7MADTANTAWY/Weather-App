import 'package:flutter/material.dart';

AppBar buildAppBar(String address) {
  return AppBar(
    backgroundColor: Colors.transparent,
    elevation: 0,
    title: Text(
      address,
      style: const TextStyle(color: Colors.white, fontSize: 20),
    ),
    actions: [
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10), // Adjusted padding
        child: SizedBox(
          width: 200, // Maintained width
          height: 35, // Slightly increased height for more space
          child: TextField(
            style: const TextStyle(
                color: Colors.white, fontSize: 16), // Increased font size
            decoration: InputDecoration(
              hintText: 'Search...',
              hintStyle: const TextStyle(
                  color: Colors.white70,
                  fontSize: 14), // Increased hint text size
              filled: true,
              fillColor:
                  Colors.white12, // Keeps the same slightly darker background
              contentPadding: const EdgeInsets.symmetric(
                  vertical: 8), // Adjusted padding for more space
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20), // Same rounded corners
                borderSide: BorderSide.none,
              ),
              prefixIcon: const Icon(Icons.search,
                  color: Colors.white, size: 20), // Increased icon size
            ),
          ),
        ),
      ),
    ],
  );
}
