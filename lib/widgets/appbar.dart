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
    title: Text(
      title,
      style: const TextStyle(color: Colors.white, fontSize: 18),
    ),
    leading: onBack != null // Adds leading for the back button, if applicable
        ? IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => onBack(),
          )
        : null,
    actions: [
      Padding(
        padding: const EdgeInsets.only(right: 10),
        child: SizedBox(
          width: 200,
          height: 35,
          child: TextField(
            controller: controller,
            style: const TextStyle(color: Colors.white, fontSize: 16),
            decoration: InputDecoration(
              hintText: 'Search...',
              hintStyle: const TextStyle(color: Colors.white70, fontSize: 14),
              filled: true,
              fillColor: Colors.white12,
              contentPadding: const EdgeInsets.symmetric(vertical: 8),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20),
                borderSide: BorderSide.none,
              ),
              prefixIcon:
                  const Icon(Icons.search, color: Colors.white, size: 20),
            ),
            onSubmitted: onSearch, // Trigger search on submit
          ),
        ),
      ),
    ],
  );
}
