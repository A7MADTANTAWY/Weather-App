import 'package:flutter/material.dart';

AppBar buildAppBar(
  String title,
  TextEditingController controller,
  Function(String) onSearch,
  Function()? onBack, // Allows for nullable back button functionality
) {
  return AppBar(
    backgroundColor: Colors.transparent,
    elevation: 0,
    titleSpacing: onBack != null ? 0 : 20, // Reduce spacing when back button is present
    title: Text(
      title,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 20, // Slightly larger font for a modern look
        fontWeight: FontWeight.w500, // Thicker font weight for emphasis
      ),
    ),
    leading: onBack != null // Adds leading for the back button, if applicable
        ? IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
            iconSize: 20, // Modern, minimal back arrow icon
            onPressed: () => onBack(),
            padding: const EdgeInsets.only(left: 15), // Reduced padding for sleek look
          )
        : null,
    actions: [
      Padding(
        padding: const EdgeInsets.only(right: 15), // Standard padding for symmetry
        child: SizedBox(
          width: 180, // Set width for search bar
          height: 42, // Slightly taller for better usability
          child: TextField(
            controller: controller,
            style: const TextStyle(
              color: Colors.white, 
              fontSize: 16,
            ),
            decoration: InputDecoration(
              hintText: 'Search city...',
              hintStyle: const TextStyle(
                color: Colors.white70,
                fontSize: 15, // Slightly larger and thinner for a more modern feel
              ),
              filled: true,
              fillColor: Colors.white12, // More transparent for a sleeker look
              contentPadding: const EdgeInsets.symmetric(vertical: 10),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30), // Modern rounded search field
                borderSide: BorderSide.none, // No border for a clean look
              ),
              prefixIcon: const Icon(
                Icons.search_rounded, // Modern search icon
                color: Colors.white, 
                size: 22,
              ),
              suffixIcon: controller.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(
                        Icons.close_rounded, // Close icon to clear the input
                        color: Colors.white,
                        size: 20,
                      ),
                      onPressed: () {
                        controller.clear(); // Clear search on pressing the close button
                      },
                    )
                  : null, // Show clear button only when there is input
            ),
            onSubmitted: onSearch, // Trigger search on submit
          ),
        ),
      ),
    ],
  );
}
