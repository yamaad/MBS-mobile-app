import 'dart:async';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:mbs_fyp/components/reportDialog.dart';
import 'package:mbs_fyp/models/orderInfo.dart';
import 'package:mbs_fyp/models/shopInfo.dart';
import 'package:mbs_fyp/screens/client/dashBoardFunctions.dart';
import 'package:mbs_fyp/services/authService.dart';
import 'package:mbs_fyp/services/liveLocation.dart';
import 'package:mbs_fyp/services/orderServcies.dart';

class ShowOrderState extends StatefulWidget {
  final String currentUserUid;
  final OrderInfo order;
  final Position currentUserLocation;

  const ShowOrderState(
      {required this.currentUserUid,
      required this.order,
      required this.currentUserLocation});

  @override
  State<ShowOrderState> createState() => _ShowOrderStateState();
}

class _ShowOrderStateState extends State<ShowOrderState> {
  final orderServices = OrderServices();
  final auth = AuthSevrices();
  LiveLocationServices _locationServices = LiveLocationServices();
  final Completer<GoogleMapController> _controller = Completer();
  ShopInfo? shopInfo;
  LatLng? employeeLocation;
  num pricingRate = 0;
  num serviceRate = 0;
  double zoomLevel = 14;
  LatLng? target;
  final apiKey = dotenv.env['GOOGLE_API_KEY'] ?? '';
  dynamic travelTime;



  void initState() {
    super.initState();
    getShopName();
    fetchLocation();
    fetchOrderStream();
    getPolyPoints();
  }

  @override
  void dispose() {
    super.dispose();
    _orderSubscription.cancel();
  }

  void fetchLocation() {
    employeeLocation = widget.order.assignedTo.location;
  }

  late StreamSubscription _orderSubscription;
  void updateZoomLevel(GoogleMapController googleMapController) async {
    zoomLevel = await googleMapController.getZoomLevel();
    if (mounted) setState(() {});
  }

  void getTravelTime(OrderInfo order) async {
    final url = Uri.parse(
        'https://maps.googleapis.com/maps/api/distancematrix/json'
        '?origins=${widget.currentUserLocation.latitude},${widget.currentUserLocation.longitude}'
        '&destinations=${order.assignedTo.location!.latitude},${order.assignedTo.location!.longitude}'
        '&key=${apiKey}');

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      travelTime = data['rows'][0]['elements'][0]['duration']['text'];
    }
  }

  void fetchOrderStream() async {
    GoogleMapController googleMapController = await _controller.future;
    Stream<OrderInfo> ordersStream =
        await _locationServices.streamOrder(widget.order.uid);

    _orderSubscription = ordersStream.listen((OrderInfo order) {
      employeeLocation = LatLng(order.assignedTo.location!.latitude,
          order.assignedTo.location!.longitude);
      updateZoomLevel(googleMapController);
      getTravelTime(order);
      getPolyPoints();
      LatLngBounds bounds = LatLngBounds(
        southwest: LatLng(
          widget.currentUserLocation.latitude <
                  order.assignedTo.location!.latitude
              ? widget.currentUserLocation.latitude
              : order.assignedTo.location!.latitude,
          widget.currentUserLocation.longitude <
                  order.assignedTo.location!.longitude
              ? widget.currentUserLocation.longitude
              : order.assignedTo.location!.longitude,
        ),
        northeast: LatLng(
          widget.currentUserLocation.latitude >
                  order.assignedTo.location!.latitude
              ? widget.currentUserLocation.latitude
              : order.assignedTo.location!.latitude,
          widget.currentUserLocation.longitude >
                  order.assignedTo.location!.longitude
              ? widget.currentUserLocation.longitude
              : order.assignedTo.location!.longitude,
        ),
      );

      googleMapController
          .animateCamera(CameraUpdate.newLatLngBounds(bounds, 50));
      if (mounted) setState(() {});
    });
  }

  Future<void> getShopName() async {
    if (widget.order.shopUid!.isNotEmpty) {
      ShopInfo shopInfo = await auth.getShopData(widget.order.shopUid!);
      if (mounted) {
        setState(() {
          this.shopInfo = shopInfo;

        });
      }
    }
  }

  List<LatLng> polylineCoordinates = [];
  void getPolyPoints() async {
    polylineCoordinates.clear();
    if (mounted) setState(() {});
    PolylinePoints polylinePoints = PolylinePoints();

    PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
        apiKey,
        PointLatLng(employeeLocation!.latitude, employeeLocation!.longitude),
        PointLatLng(widget.currentUserLocation.latitude,
            widget.currentUserLocation.longitude));
    if (result.points.isNotEmpty) {
      result.points.forEach((element) =>
          polylineCoordinates.add(LatLng(element.latitude, element.longitude)));
      if (mounted) setState(() {});
    }
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.brown[400],
          elevation: 0.0,
          title: Text('Order #${widget.order.orderNo}'),
          centerTitle: true,
        ),
        body: widget.order.status == 'ongoing'
        ? Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10.0),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                    SizedBox(
                      height: 20,
                    ),
                Text(
                  '${widget.order.status}',
                  style:
                      TextStyle(color: Colors.yellow.shade900, fontSize: 16.0),
                ),
                SizedBox(height: 9.0),
                Row(
                  children: [
                        SizedBox(
                          width: 7,
                        ),
                    Text("Estimated Time: "),
                    Spacer(),
                        Text(travelTime
                            .toString()), //Todo get Estimated Time to arrive
                        SizedBox(
                          width: 7,
                        ),
                  ],
                ),
                SizedBox(height: 20.0),
                    if (employeeLocation != null)
                Expanded(
                  child: GoogleMap(
                    initialCameraPosition: CameraPosition(
                            target: LatLng(widget.currentUserLocation.latitude,
                                widget.currentUserLocation.longitude),
                            zoom: zoomLevel,
                    ),
                          polylines: {
                            Polyline(
                                polylineId: PolylineId("route"),
                                points: polylineCoordinates,
                                color: Colors.green.shade900,
                                width: 3)
                          },
                    markers: {
                      Marker(
                              markerId: MarkerId("worker"),
                              position: employeeLocation!,
                            ),
                          },
                          onMapCreated: (mapController) async {
                            _controller.complete(mapController);
                            final GoogleMapController controller =
                                await _controller.future;
                            await Future.delayed(Duration(seconds: 5));
                          },
                          myLocationEnabled: true,
                          // myLocationButtonEnabled: true
                  ),
                ),
                    SizedBox(height: 15.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Column(
                      children: [
                        ElevatedButton(
                          onPressed: () async {
                            showReportDialog(context, widget.currentUserUid,
                                widget.order.uid, widget.order.shopUid);
                          },
                          child: Text('report an issue'),
                          style: ButtonStyle(
                            backgroundColor: MaterialStateProperty.all<Color>(
                                Colors.grey.shade500),
                          ),
                        ),
                       
                      ],
                    ),
                  ],
                ),
                    SizedBox(height: 15.0),
              ],
            ),
          )
        : Container(
                padding: EdgeInsets.fromLTRB(10, 15, 10, 15),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10.0),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Order #${widget.order.orderNo}'),
                Text(
                  '${widget.order.status}',
                  style: TextStyle(
                      color: DashboardFunctions.orderStatusColor(
                          widget.order.status),
                      fontSize: 16.0),
                ),
                SizedBox(height: 9.0),
                Row(
                  children: [
                    Text("Shop: "),
                    Spacer(),
                        Text(shopInfo != null ? shopInfo!.shopName : "-"),
                  ],
                ),
               
                SizedBox(height: 9.0),
                Row(
                  children: [
                    Text("Service: "),
                    Spacer(),
                    Text(widget.order.serviceRequired),
                  ],
                ),
                SizedBox(height: 9.0),
                Row(
                  children: [
                    Text("Date: "),
                    Spacer(),
                    Text(widget.order.creationTime.toString()),
                  ],
                ),
                    SizedBox(height: 30.0),
                Column(
                  children: [
                        SizedBox(height: 15.0),
                    Text("rate: "),
                    Row(
                      children: [
                        if (widget.order.pricingRating != null)
                          Text("pricing: " +
                              widget.order.pricingRating.toString()),
                        Spacer(),
                        if (widget.order.serviceRating != null)
                          Text("service: " +
                              widget.order.serviceRating.toString()),
                      ],
                    ),
                  ],
                ),
                if (widget.order.status == "pending")
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                        onPressed: () async {
                          // Implement your logic here
                          await orderServices.updateOrderStatus(
                              widget.order,
                              widget.order.shopUid,
                              widget.order.shopPhone,
                              'canceled',
                              widget.order.assignedTo);
                          Navigator.pop(context);
                          Navigator.pop(context);
                        },
                        child: Text('Cancel'),
                        style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.all<Color>(
                              Colors.red.shade500),
                        ),
                      ),
                      
                      
                    ],
                  ),
                    SizedBox(height: 30.0),
                if (widget.order.status == "completed" &&
                    widget.order.pricingRating == null)
                  Column(
                    children: [
                      SizedBox(height: 10),
                      Text("Rate the pricing:"),
                      RatingBar.builder(
                        initialRating: 0,
                        minRating: 1,
                        direction: Axis.horizontal,
                        allowHalfRating: true,
                        itemCount: 5,
                        itemPadding: EdgeInsets.symmetric(horizontal: 4.0),
                        itemBuilder: (context, _) => Icon(
                          Icons.star,
                          color: Colors.amber,
                        ),
                        onRatingUpdate: (rating) {
                          if (mounted) {
                            setState(() {
                              pricingRate = rating;
                            });
                          }
                        },
                      ),
                      SizedBox(height: 10),
                      Text("Rate the the service provided:"),
                      SizedBox(width: 10),
                      RatingBar.builder(
                        initialRating: 0,
                        minRating: 1,
                        direction: Axis.horizontal,
                        allowHalfRating: true,
                        itemCount: 5,
                        itemPadding: EdgeInsets.symmetric(horizontal: 4.0),
                        itemBuilder: (context, _) => Icon(
                          Icons.star,
                          color: Colors.amber,
                        ),
                        onRatingUpdate: (rating) {
                          if (mounted) {
                            setState(() {
                              serviceRate = rating;
                            });
                          }
                        },
                      ),
                      SizedBox(height: 10),
                      ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            // Customize the button's appearance when disabled
                            backgroundColor: (serviceRate == 0 ||
                                    pricingRate == 0)
                                ? Colors.grey
                                : Colors
                                    .green, // You can change the color to visually indicate it's disabled
                          ),
                          onPressed: (serviceRate == 0 || pricingRate == 0)
                              ? null
                              : () async {
                                  await orderServices.rateOrder(
                                      widget.order.uid,
                                      pricingRate,
                                          serviceRate,
                                          shopInfo!);
                                  Navigator.pop(context);
                                  Navigator.pop(context);
                                },
                          child: Text("submit rating")),
                          SizedBox(height: 30.0),
                          if (widget.order.status == "completed")
                            ElevatedButton(
                              onPressed: () async {
                                showReportDialog(context, widget.currentUserUid,
                                    widget.order.uid, widget.order.shopUid);
                              },
                              child: Text('report an issue'),
                              style: ButtonStyle(
                                backgroundColor:
                                    MaterialStateProperty.all<Color>(
                                        Colors.grey.shade500),
                              ),
                            ),
                          
                    ],
                  )
              ],
            ),
              ));
  }
}
