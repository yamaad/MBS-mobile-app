import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:mbs_fyp/components/reportDialog.dart';
import 'package:mbs_fyp/models/orderInfo.dart';
import 'package:mbs_fyp/models/shopInfo.dart';
import 'package:mbs_fyp/screens/client/dashBoardFunctions.dart';
import 'package:mbs_fyp/services/authService.dart';
import 'package:mbs_fyp/services/orderServcies.dart';

class ShowOrderState extends StatefulWidget {
  final String currentUserUid;
  final OrderInfo order;

  const ShowOrderState({required this.currentUserUid, required this.order});

  @override
  State<ShowOrderState> createState() => _ShowOrderStateState();
}

class _ShowOrderStateState extends State<ShowOrderState> {
  final orderServices = OrderServices();
  final auth = AuthSevrices();
  String shopName = '-';
  LatLng shopLocation = LatLng(0, 0);
  num pricingRate = 0;
  num serviceRate = 0;
  

  void initState() {
    super.initState();
    getShopName();
  }

  Future<void> getShopName() async {
    if (widget.order.shopUid!.isNotEmpty) {
      ShopInfo shopInfo = await auth.getShopData(widget.order.shopUid!);
      if (mounted) {
        setState(() {
        shopName = shopInfo.shopName;

        shopLocation = shopInfo.location;
        });
      }
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.order.status == 'ongoing'
        ? Container(
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
                  style:
                      TextStyle(color: Colors.yellow.shade900, fontSize: 16.0),
                ),
                SizedBox(height: 9.0),
                Row(
                  children: [
                    Text("Estimated Time: "),
                    Spacer(),
                    Text("11 minutes"), //Todo get Estimated Time to arrive
                  ],
                ),
                SizedBox(height: 20.0),
                Expanded(
                  child: GoogleMap(
                    initialCameraPosition: CameraPosition(
                      target: shopLocation,
                      zoom: 15.0,
                    ),
                    markers: {
                      Marker(
                        markerId: MarkerId(shopName),
                        position: shopLocation,
                      ),
                    },
                  ),
                ),
                SizedBox(height: 20.0),
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
                        ElevatedButton(
                          onPressed: () async {
                            // Accept button action
                            // Implement your logic here
                            await orderServices.updateOrderStatus(
                                widget.order,
                                widget.order.shopUid,
                                widget.order.shopPhone,
                                'completed');
                            Navigator.pop(context);
                            Navigator.pop(context);
                          },
                          child: Text('Mark As Completed'),
                          style: ButtonStyle(
                            backgroundColor:
                                MaterialStateProperty.all<Color>(Colors.green),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          )
        : Container(
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
                    Text(shopName),
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
                SizedBox(height: 9.0),
                Column(
                  children: [
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
                          // Todo cancel pending Orders
                          // Implement your logic here
                          await orderServices.updateOrderStatus(
                              widget.order,
                              widget.order.shopUid,
                              widget.order.shopPhone,
                              'canceled');
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
                                      serviceRate);
                                  Navigator.pop(context);
                                  Navigator.pop(context);
                                },
                          child: Text("submit rating")),
                          
                    ],
                  )
              ],
            ),
          );
  }
}
