import 'package:flutter/material.dart';
import 'package:testing/views/home_page.dart';

void main() {
  runApp(const GetLocation());
}

class GetLocation extends StatelessWidget {
  const GetLocation({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: HomePage(),
    );
  }
}
