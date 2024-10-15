import 'package:flutter/material.dart';

AppBar buildAppBar(
  String title,
  TextEditingController controller,
  Function(String) onSearch,
  Function()? onBack, // Change to Function()? to allow null
) {
  return AppBar(
    backgroundColor: Colors.transparent,
    elevation: 0,
    title: Text(
      title,
      style: const TextStyle(color: Colors.white, fontSize: 18),
    ),
    actions: [
      // Only show the back button if onBack is not null
      if (onBack != null)
        IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => onBack(), // Call the onBack function when pressed
        ),
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
            onSubmitted: onSearch, // Call the search function on submit
          ),
        ),
      ),
    ],
  );
}
