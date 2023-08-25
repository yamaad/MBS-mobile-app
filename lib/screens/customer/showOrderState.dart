import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
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

  void initState() {
    super.initState();
    getShopName();
  }

  Future<void> getShopName() async {
    if (widget.order.shopUid!.isNotEmpty) {
    ShopInfo shopInfo = await auth.getShopData(widget.order.shopUid!);
    setState(() {
        shopName = shopInfo.shopName;

        shopLocation = shopInfo.location;
    });
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
                    ElevatedButton(
                      onPressed: () async {
                        // Accept button action
                        // Implement your logic here
                        await orderServices.updateOrderStatus(
                            widget.order,
                            widget.order.shopUid,
                            widget.order.shopPhone,
                            'completed');
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
                    Text("rate: "),
                    Spacer(),
                    Text(widget.order.rating == null
                        ? "-"
                        : widget.order.rating.toString()),
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
              ],
            ),
          );
  }
}
