import 'dart:async';

import 'package:geolocator/geolocator.dart';

class LiveLocationServices {
  StreamController<Position> positionStreamController =
      StreamController<Position>();

  Stream<Position> get positionStream => positionStreamController.stream;

  void listenToLocationChanges(void Function(Position) locationCallback) {
    Geolocator.getPositionStream().listen((position) {
      positionStreamController.add(position);
      locationCallback(position);
    });
  }
}
