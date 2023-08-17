import 'dart:async';
import 'package:flutter/material.dart';
import 'package:mbs_fyp/models/shopInfo.dart';
import 'package:mbs_fyp/models/user.dart';
import 'package:mbs_fyp/screens/client/viewOrderDetials.dart';
import 'package:mbs_fyp/services/authService.dart';
import 'package:mbs_fyp/services/shopServices.dart';
import 'package:provider/provider.dart';
import '../../models/orderInfo.dart';
import '../../services/locationServeices.dart';
import '../../services/orderServcies.dart';
import '../../components/OrderRequest.dart';
import 'dashBoardFunctions.dart';

class Dashboard extends StatefulWidget {
  final currentUserUid;
  const Dashboard({required this.currentUserUid});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  final AuthSevrices _auth = AuthSevrices();
  final ShopServices _shopServices = ShopServices();
  final OrderServices _orderServices = OrderServices();

  StreamController<List<OrderInfo>> _ordersStreamController =
      StreamController<List<OrderInfo>>.broadcast();
  Stream<List<OrderInfo>> get ordersStream => _ordersStreamController.stream;
  late StreamSubscription _ordersSubscription;

  // bool status = true;
  String? clientID;
  bool status = false;
  String switchStatus = "go online";
  List<Map<String, dynamic>> servicesList = [
    {'services': "on spot checkout", 'availability': false},
    {'services': "insurance renewal", 'availability': false},
    {'services': "gasoline", 'availability': false},
    {'services': "battery", 'availability': false},
    {'services': "spare parts", 'availability': false},
  ];

  List<OrderInfo> orders = [];
  ScrollController _scrollController = ScrollController();
  LocationServices _locationServices = LocationServices();






  @override
  void initState() {
    requestLocationPermission();
    super.initState();
    getshopStatus();
    fetchOrdersStream(widget.currentUserUid);
    fectchOrdersHistory(widget.currentUserUid);

    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        // Fetch more orders
        if (mounted) {
          fectchOrdersHistory(widget.currentUserUid);
        }
      }
    });
  }

  void requestLocationPermission() async {
    await _locationServices.requestLocationPermission();
  }

  void getshopStatus() async {
    ShopInfo shop = await _auth.getCurrentShopData();
    status = shop.status;
    if (status) {
      setState(() {
        switchStatus = "go offline";
      });
    }
    for (int i = 0; i < servicesList.length; i++) {
      String service = servicesList[i]['services'];
      bool isAvailable = shop.services.contains(service);
      setState(() {
        servicesList[i]['availability'] = isAvailable;
      });
    }
  }
  


  void fectchOrdersHistory(final currentUserUid) async {
    if (mounted) {
      List<OrderInfo> fetchedOrders =
          await _orderServices.getOrdersHistory(currentUserUid);
      setState(() {
        orders = fetchedOrders;
      });
    }
  }

  void fetchOrdersStream(final currentUserUid) async {
    if (mounted) {
      Stream<List<OrderInfo>> ordersStream =
          await _orderServices.streamPendingOrders();
      final shop = await _auth.getCurrentShopData();

      _ordersSubscription = ordersStream.listen((List<OrderInfo> orders) {
        if (orders.isNotEmpty) {
          if (orders.last.shopUid == currentUserUid ||
              orders.last.shopUid == '')
            showOrdersDialog(context, orders.last, shop);
        }
      });
    }
  }

  void onSignOut(String userID) async {
    await _shopServices.updateClientStatus(userID, false);
  }

  @override
  void dispose() {
    _ordersStreamController.close();
    _scrollController.dispose();
    _ordersSubscription.cancel();
    onSignOut(widget.currentUserUid);

    super.dispose();


  }

  void toggleSwitch(String userID) async {
    await _shopServices.updateClientStatus(userID, !status);
    status = await _shopServices.getStatus(userID);
    if (status) {
      setState(() {
        switchStatus = "go offline";
      });
    } else {
      setState(() {
        switchStatus = "go online";
      });
    }
  }

  List<String> updateSrvicesList() {
    List<String> availableServices = servicesList
        .where((service) => service['availability'] == true)
        .map((service) => service['services'] as String)
        .toList();
    return availableServices;
  }

  void fetchServicesList(String clientID) async {
    List<String> firestoreServices = await _shopServices.getServices(clientID);
    for (var service in servicesList) {
      final serviceName = service['services'];
      final isAvailable = firestoreServices.contains(serviceName);
      service['availability'] = isAvailable;
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<MbsUser?>(context);
    return Scaffold(
      backgroundColor: Colors.brown[50],
      appBar: AppBar(
        backgroundColor: Colors.brown[400],
        elevation: 0.0,
        title: Text("Dashboard"),
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
      body: Container(
        margin: EdgeInsets.fromLTRB(15.0, 150.0, 15.0, 0.0),
        decoration: BoxDecoration(
          color: Colors.brown[100],
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(10.0),
            topRight: Radius.circular(10.0),
          ),
        ),
        child: Column(children: [
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: EdgeInsets.fromLTRB(10.0, 20.0, 10.0, 15.0),
                  child: Container(
                    child: Column(
                      // mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          status ? "online" : "offline",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 24.0,
                            color: DashboardFunctions.shopStatusColor(status),
                          ),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            toggleSwitch(user!.uid);
                          },
                          child: Text(
                            switchStatus,
                            style: TextStyle(
                              fontSize: 16.0,
                              color: Colors.black87,
                            ),
                          ),
                          style: ButtonStyle(
                            backgroundColor: MaterialStateProperty.all<Color>(
                                Colors.grey
                                    .shade300), // Set the button color here
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          Wrap(
            children: List.generate(servicesList.length, (index) {
              bool availability = servicesList[index]['availability'] ?? false;
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Checkbox(
                    value: availability,
                    onChanged: (bool? value) async {
                      setState(() {
                        servicesList[index]['availability'] = value;
                      });
                      await _shopServices.updateClientServices(
                          user!.uid, updateSrvicesList());
                    },
                  ),
                  Text(servicesList[index]['services']),
                ],
              );
            }),
          ),
          Text(
            "Orders History",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          Expanded(
            child: CustomScrollView(
              controller: _scrollController,
              slivers: [
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (BuildContext context, int index) {
                      OrderInfo order = orders[index];
                      return ListTile(
                        title: Text('Order ${order.orderNo}'),
                        subtitle: Text(
                          '${order.status}',
                          style: TextStyle(
                              color: DashboardFunctions.orderStatusColor(
                                  order.status)),
                        ),
                        onTap: () {
                          // Handle order tap event
                          viewOrderDetails(context, order);
                        },
                      );
                    },
                    childCount: orders.length,
                  ),
                ),
              ],
            ),
          )
        ]),
      ),
    );
  }
}
