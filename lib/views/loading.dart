import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:testing/const/const.dart' as constants;

class Loading extends StatefulWidget {
  final bool isNight;
  const Loading(
      {super.key,
      required this.isNight}); // Pass isNight as a constructor parameter

  @override
  State<Loading> createState() => _LoadingState();
}

class _LoadingState extends State<Loading> {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            widget.isNight
                ? constants.night_gradient1
                : constants.day_gradient1,
            widget.isNight
                ? constants.night_gradient2
                : constants.day_gradient2,
            widget.isNight
                ? constants.night_gradient3
                : constants.day_gradient3,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Lottie.asset('assets/loading.json'),
              const Text(
                'Loading weather ...',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 30,
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
