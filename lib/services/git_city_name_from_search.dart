import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';

class GeocodingExample extends StatefulWidget {
  @override
  _GeocodingExampleState createState() => _GeocodingExampleState();
}

class _GeocodingExampleState extends State<GeocodingExample> {
  final TextEditingController _controller = TextEditingController();
  String _result = '';

  Future<void> _convertAddressToLatLon(String address) async {
    try {
      List<Location> locations = await locationFromAddress(address);
      if (locations.isNotEmpty) {
        final lat = locations.first.latitude;
        final lon = locations.first.longitude;
        setState(() {
          _result = 'Latitude: $lat, Longitude: $lon';
        });
      } else {
        setState(() {
          _result = 'No locations found.';
        });
      }
    } catch (e) {
      setState(() {
        _result = 'Error: $e';
      });
    }
  }

  // Method to return the latitude and longitude as a tuple
  Future<List<double>?> getLatLon(String address) async {
    try {
      List<Location> locations = await locationFromAddress(address);
      if (locations.isNotEmpty) {
        return [locations.first.latitude, locations.first.longitude];
      }
    } catch (e) {
      print('Error: $e');
    }
    return null; // Return null if no locations found or error occurs
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Geocoding Example'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _controller,
              decoration: const InputDecoration(
                labelText: 'Enter Address',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () async {
                // Call the method to get latitude and longitude
                List<double>? latLon = await getLatLon(_controller.text);
                if (latLon != null) {
                  setState(() {
                    _result = 'Latitude: ${latLon[0]}, Longitude: ${latLon[1]}';
                  });
                } else {
                  setState(() {
                    _result = 'No locations found.';
                  });
                }
              },
              child: const Text('Get Coordinates'),
            ),
            const SizedBox(height: 16.0),
            Text(
              _result,
              style: const TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    title: 'Geocoding Example',
    home: GeocodingExample(),
  ));
}
