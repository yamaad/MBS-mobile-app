import 'package:geocoding/geocoding.dart' as geocoding;
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:google_maps_webservice/places.dart';

class LocationServices {
  static const String apiKey = 'AIzaSyCl5TeBOssEs8oTCXkK4ZBRjRYe4iXQcO0';

  static Future<Position> getCurrentLocation() async {
    PermissionStatus status = await Permission.location.request();
    if (status.isDenied) {
      print("Permission denied");
    }
    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.best,
    );
    return position;
  }

  Future<List<String>> searchPlaces(String address) async {
    // Create a GoogleMapsPlaces instance
    final places = GoogleMapsPlaces(apiKey: apiKey);

    // Perform a place search based on the address
    final response = await places.searchByText(address);

    // Handle the search results
    if (response.status == 'OK') {
      final placesInfo = response.results.map((result) {
        return result.name + " " + result.formattedAddress!;
      }).toList();

      return placesInfo;
    } else {
      return [];
    }
  }

  static Future<LatLng> getLatLngFromAddress(String address) async {
    LatLng location;
    try {
      List<geocoding.Location> locations =
          await geocoding.locationFromAddress(address);
      if (locations.isNotEmpty) {
        geocoding.Location firstLocation = locations.first;
        location = LatLng(firstLocation.latitude, firstLocation.longitude);

        return location;
      }
    } catch (e) {
      print('Error occurred while converting address to LatLng: $e');
    }
    return LatLng(0.0, 0.0); // Default LatLng if conversion fails
  }
}
