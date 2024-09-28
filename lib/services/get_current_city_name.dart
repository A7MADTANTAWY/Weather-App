import 'package:geocoding/geocoding.dart';

Future<Placemark?> getAddressFromCoordinates(
    double latitude, double longitude) async {
  try {
    List<Placemark> placemarks =
        await placemarkFromCoordinates(latitude, longitude);

    if (placemarks.isNotEmpty) {
      Placemark place = placemarks.first;
      return place;
    } else {
      print('No address found for the given coordinates.');
      return null;
    }
  } catch (e) {
    print('Error: $e');
    return null;
  }
}
