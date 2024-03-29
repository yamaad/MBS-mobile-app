import 'dart:async';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:geocoding/geocoding.dart' as geocoding;
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart' as maps;
import 'package:permission_handler/permission_handler.dart';
import 'package:google_maps_webservice/places.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../models/shopInfo.dart';

class LocationServices {
  final apiKey = dotenv.env['GOOGLE_API_KEY'] ?? '';

  Future<void> requestLocationPermission() async {
    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Permission still denied, show a message or handle accordingly
        print('Location permission denied.');
      } else if (permission == LocationPermission.deniedForever) {
        // Permission denied forever, handle accordingly
        print('Location permission denied forever.');
      } else {
        // Permission granted, proceed with location-related tasks
        print('Location permission granted.');
      }
    } else if (permission == LocationPermission.deniedForever) {
      // Permission denied forever, handle accordingly
      print('Location permission denied forever.');
    } else {
      // Permission already granted, proceed with location-related tasks
      print('Location permission already granted.');
    }
  }


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

  static Future<maps.LatLng> getLatLngFromAddress(String address) async {
    maps.LatLng location;
    try {
      List<geocoding.Location> locations =
          await geocoding.locationFromAddress(address);
      if (locations.isNotEmpty) {
        geocoding.Location firstLocation = locations.first;
        location = maps.LatLng(firstLocation.latitude, firstLocation.longitude);

        return location;
      }
    } catch (e) {
      print('Error occurred while converting address to LatLng: $e');
    }
    return maps.LatLng(0.0, 0.0); // Default LatLng if conversion fails
  }

  static Future<String?> getAddressFromPosition(Position position) async {
    List<geocoding.Placemark> placemarks = await geocoding
        .placemarkFromCoordinates(position.latitude, position.longitude);
    if (placemarks.isNotEmpty) {
      geocoding.Placemark placemark = placemarks.first;
      String? address = placemark.street;
      return address;
    } else {
      return '';
    }
  }

  static Future<double> calculateDistance(maps.LatLng destination) async {
    Position loc = await getCurrentLocation();
    maps.LatLng origin = maps.LatLng(loc.latitude, loc.longitude);
    final location = LocationServices();
    final api = location.apiKey;
    String url = 'https://maps.googleapis.com/maps/api/distancematrix/json'
        '?origins=${origin.latitude},${origin.longitude}'
        '&destinations=${destination.latitude},${destination.longitude}'
        '&key=$api';

    // Make the HTTP request
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      // Parse the response JSON
      final data = jsonDecode(response.body);

      // Extract the distance value from the response
      String distanceText = data['rows'][0]['elements'][0]['distance']['text'];
      double distanceValue =

          data['rows'][0]['elements'][0]['distance']['value'].toDouble();

      return distanceValue;
    } else {
      // Handle the HTTP request error
      throw Exception('Failed to calculate distance.');
    }
  }

  static Future<List<ShopInfo>> sortShopList(List<ShopInfo> shopList) async {
    // Calculate the distance for each shop in the list
    List<double> distances = [];

    for (var shop in shopList) {
      double distance = await calculateDistance(shop.location);
      distances.add(distance);
    }

    // Create a list of indices and sort it based on distances
    List<int> indices = List.generate(shopList.length, (index) => index);
    indices.sort((a, b) => distances[a].compareTo(distances[b]));

    // Rearrange the shopList based on the sorted indices
    List<ShopInfo> sortedShopList = [];
    for (var index in indices) {
      sortedShopList.add(shopList[index]);
    }

    return sortedShopList;
  }

}
