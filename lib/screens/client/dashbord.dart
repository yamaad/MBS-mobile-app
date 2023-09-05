import 'dart:async';
import 'package:flutter/material.dart';
import 'package:mbs_fyp/components/reportDialog.dart';
import 'package:mbs_fyp/models/employeeModel.dart';
import 'package:mbs_fyp/models/shopInfo.dart';
import 'package:mbs_fyp/models/user.dart';
import 'package:mbs_fyp/screens/client/viewOrderDetials.dart';
import 'package:mbs_fyp/services/authService.dart';
import 'package:mbs_fyp/services/shopServices.dart';
import 'package:provider/provider.dart';
import 'package:toast/toast.dart';
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
  TextEditingController brandController = TextEditingController();

  List<dynamic> addedBrands = [];
  List<EmployeeUser> employees = [];

  final AuthSevrices _auth = AuthSevrices();
  final ShopServices _shopServices = ShopServices();
  final OrderServices _orderServices = OrderServices();
  String shopName = "";

  TextEditingController phoneController = TextEditingController();
  TextEditingController fullNameController = TextEditingController();
  TextEditingController otpController = TextEditingController();

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
    getAvaiableBrands();
    getEmployees();
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

  Future getEmployees() async {
    employees = await _auth.getEmployees();
    if (mounted) setState(() {});
  }

  void getAvaiableBrands() async {
    addedBrands = await _auth.getAvaiableBrands();
  }

  void requestLocationPermission() async {
    await _locationServices.requestLocationPermission();
  }

  void getshopStatus() async {
    ShopInfo shop = await _auth.getCurrentShopData();
    status = shop.status;
    shopName = shop.shopName;
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
            showOrdersDialog(context, orders.last, shop, employees);
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
    ToastContext().init(context);

    final user = Provider.of<MbsUser?>(context);
    return Scaffold(
      backgroundColor: Colors.brown[50],
      appBar: AppBar(
        backgroundColor: Colors.brown[400],
        elevation: 0.0,
        title: Text("Dashboard"),
        centerTitle: true,
        actions: <Widget>[
          PopupMenuButton<int>(
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 1,
                child: Text("report an issue"),
              ),
              PopupMenuItem(
                value: 2,
                child: Text("Logout"),
              ),
            ],
            onSelected: (value) async {
              if (value == 1) {
                showReportDialog(context, user!.uid, null, null);
              } else if (value == 2) {
                await _auth.signOut();
              }
            },
            icon: Icon(Icons.person),
            offset: Offset(0, 50), // Adjust the offset if needed
          ),
        ],
      ),
      body: Container(
        child: Column(
          children: [
            SizedBox(
              height: 20,
            ),
            ElevatedButton(
                onPressed: () async {
                  showDialog(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          actions: [
                            TextButton(
                              onPressed: () async {
                                showDialog(
                                    context: context,
                                    builder: (context) {
                                      return AlertDialog(
                                        title: Text("New employee"),
                                        content: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            TextField(
                                              controller: fullNameController,
                                              decoration: InputDecoration(
                                                  labelText: 'Full Name'),
                                            ),
                                            TextField(
                                              controller: phoneController,
                                              keyboardType: TextInputType.phone,
                                              decoration: InputDecoration(
                                                  labelText: 'Phone'),
                                            ),
                                          ],
                                        ),
                                        actions: [
                                          TextButton(
                                              onPressed: () async {
                                                final message =
                                                    await _auth.createEmployee(
                                                        fullNameController.text,
                                                        phoneController.text
                                                            .trim());

                                                Toast.show(
                                                  message,
                                                  gravity: Toast.top,
                                                  duration: 25,
                                                );

                                                Navigator.pop(context);
                                                Navigator.pop(context);
                                              },
                                              child: Text("add"))
                                        ],
                                      );
                                    });
                              },
                              child: Text("add new employee"),
                            ),
                          ],
                          title: Text("Employees"),
                          content: employees.isEmpty
                              ? Text("you have no active employees")
                              : SingleChildScrollView(
                                  child: Wrap(
                                    children: List.generate(employees.length,
                                        (index) {
                                      return Column(
                                        children: [
                                          ListTile(
                                            title: Text(employees[index].name),
                                            subtitle:
                                                Text(employees[index].phone),
                                            trailing: IconButton(
                                              icon: Icon(
                                                Icons.delete,
                                                color: Colors.red[900],
                                              ),
                                              onPressed: () async {
                                                await _auth.deActiveEmployee(
                                                    employees[index].phone);
                                                Navigator.of(context).pop();
                                              },
                                            ),
                                          )
                                        ],
                                      );
                                    }),
                                  ),
                                ),
                        );
                      });
                },
                child: Text("Employees")),
            SizedBox(
              height: 20,
            ),
            Expanded(
              child: Container(
                margin: EdgeInsets.fromLTRB(15.0, 0, 15.0, 0.0),
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
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  shopName,
                                  style: TextStyle(
                                      fontSize: 24.0,
                                      fontWeight: FontWeight.w600),
                                ),
                                Text(
                                  status ? "online" : "offline",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 16.0,
                                    color: DashboardFunctions.shopStatusColor(
                                        status),
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
                                    backgroundColor:
                                        MaterialStateProperty.all<Color>(Colors
                                            .grey
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
                  // Add Brand Button
                  ElevatedButton(
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all<Color>(
                          Colors.brown), // Set the button color here
                    ),
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: Text("add spare-parts available brands"),
                            content: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                TextField(
                                  controller: brandController,
                                  decoration:
                                      InputDecoration(labelText: 'brand'),
                                ),
                              ],
                            ),
                            actions: [
                              TextButton(
                                onPressed: () async {
                                  setState(() {
                                    addedBrands.add(brandController.text);
                                  });
                                  await _auth.addBrand(addedBrands);
                                  brandController.text = '';
                                  Navigator.pop(context);
                                },
                                child: Text("add"),
                              ),
                            ],
                          );
                        },
                      );
                    },
                    child: Text("Add Brand"),
                  ),

                  // List of Added Brands
                  Wrap(
                    children: List.generate(addedBrands.length, (index) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                addedBrands[index].toString(),
                                style: TextStyle(
                                  fontSize: 16.0,
                                  color: Colors.blueGrey.shade800,
                                ),
                              ), // Display brand name
                              IconButton(
                                icon: Icon(
                                  Icons.delete,
                                  color: Colors.red[900],
                                ),
                                onPressed: () async {
                                  // Remove the brand from the list when delete button is pressed
                                  setState(() {
                                    addedBrands.remove(addedBrands[index]);
                                  });
                                  await _auth.addBrand(addedBrands);
                                },
                              ),
                            ],
                          )
                        ],
                      );
                    }),
                  ),
                  Wrap(
                    children: List.generate(servicesList.length, (index) {
                      bool availability =
                          servicesList[index]['availability'] ?? false;
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
                                trailing: Text(order.creationTime.toString()),
                                subtitle: Text(
                                  '${order.status}',
                                  style: TextStyle(
                                      color:
                                          DashboardFunctions.orderStatusColor(
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
            ),
          ],
        ),
      ),
    );
  }
}
