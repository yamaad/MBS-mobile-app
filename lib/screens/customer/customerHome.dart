import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:mbs_fyp/components/loading.dart';
import 'package:mbs_fyp/models/shopInfo.dart';
import 'package:mbs_fyp/screens/customer/viewStores.dart';
import 'package:mbs_fyp/services/authService.dart';

import '../../services/locationServeices.dart';

class CustomerHome extends StatefulWidget {
  const CustomerHome({Key? key}) : super(key: key);

  @override
  State<CustomerHome> createState() => _CustomerHomeState();
}

class _CustomerHomeState extends State<CustomerHome> {
  final AuthSevrices _auth = AuthSevrices();
  GoogleMapController? _mapController;
  Position? _currentPosition;
bool loading = false;
  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  void _getCurrentLocation() async {
    Position position = await LocationServices.getCurrentLocation();
    setState(() {
      _currentPosition = position;
    });

    if (_mapController != null) {
      _mapController!.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: LatLng(position.latitude, position.longitude),
            zoom: 12.0,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.brown[50],
      appBar: AppBar(
        backgroundColor: Colors.brown[400],
        elevation: 0.0,
        title: Text("Home"),
        centerTitle: true,
        actions: <Widget>[
          TextButton.icon(
            onPressed: () async {
              await _auth.signOut();
            },
            icon: Icon(Icons.person),
            label: Text("logout"),
            style: ButtonStyle(
              foregroundColor: MaterialStateProperty.all<Color>(Colors.white),
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          GoogleMap(
            onMapCreated: (controller) {
              setState(() {
                _mapController = controller;
              });
            },
            initialCameraPosition: CameraPosition(
              target: LatLng(37.7749, -122.4194),
              zoom: 12.0,
            ),
            markers: _currentPosition != null
                ? {
                    Marker(
                      markerId: MarkerId('marker_1'),
                      position: LatLng(
                        _currentPosition!.latitude,
                        _currentPosition!.longitude,
                      ),
                      infoWindow: InfoWindow(title: 'Marker 1'),
                    ),
                  }
                : {},
          ),
          Positioned(
            bottom: 0.0,
            left: 55.0,
            right: 55.0,
            child: Container(
              padding: EdgeInsets.fromLTRB(10.0, 10.0, 15.0, 20.0),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(10.0),
                  topRight: Radius.circular(10.0),
                ),
              ),
              child: loading
                  ? Container(height: 80.0, child: Loading())
                  : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    height: 80.0,
                    alignment: Alignment.center,
                    child: ElevatedButton(
                            onPressed: () async {
                              setState(() {
                                loading = true;
                              });
                              final List<ShopInfo> shopInfo =
                                  await _auth.getClientUsers();
                              setState(() {
                                loading = false;
                              });
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        ViewStore(shopInfo: shopInfo)),
                              );

                      },
                      child: Container(
                        width: 120.0,
                        height: 60.0,
                        alignment: Alignment.center,
                        child: Text(
                          'View Stores',
                          style: TextStyle(
                            color: Colors.brown,
                            fontSize: 20.0,
                          ),
                        ),
                      ),
                      style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all<Color>(
                            Colors.grey.shade300),
                      ),
                    ),
                  ),
                  SizedBox(width: 16.0),
                  ElevatedButton(
                    onPressed: () {
                      // Button 2 action...
                    },
                    child: Container(
                      width: 120.0,
                      height: 48.0,
                      alignment: Alignment.center,
                      child: Text(
                        'Make Order',
                        style: TextStyle(
                          fontSize: 20.0,
                        ),
                      ),
                    ),
                    style: ButtonStyle(
                      backgroundColor:
                          MaterialStateProperty.all<Color>(Colors.brown),
                    ),
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
