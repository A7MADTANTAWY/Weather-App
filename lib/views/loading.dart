import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:testing/const/const.dart';

class Loading extends StatefulWidget {
  const Loading({super.key});

  @override
  State<Loading> createState() => _LoadingState();
}

class _LoadingState extends State<Loading> {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            night_gradient1,
            night_gradient2,
            night_gradient3,
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
