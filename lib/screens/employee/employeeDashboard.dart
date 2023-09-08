import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:mbs_fyp/models/employeeModel.dart';
import 'package:mbs_fyp/models/orderInfo.dart';
import 'package:mbs_fyp/screens/client/dashBoardFunctions.dart';
import 'package:mbs_fyp/services/authService.dart';
import 'package:mbs_fyp/services/orderServcies.dart';

class EmployeeDashboard extends StatefulWidget {
  const EmployeeDashboard({super.key});

  @override
  State<EmployeeDashboard> createState() => _EmployeeDashboardState();
}

class _EmployeeDashboardState extends State<EmployeeDashboard> {
  AuthSevrices _auth = AuthSevrices();
  OrderServices _orderServices = OrderServices();
  EmployeeUser? user;
  List<OrderInfo> orders = [];
  @override
  void initState() {
    super.initState();
    getUser();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void getUser() async {
    user = await _auth.getCurrentEmployee();
    if (!user!.isActive) {
      await _auth.signOut();
    }
    getOrders();
    if (mounted) setState(() {});
  }

  void getOrders() async {
    orders = await _orderServices.getOrderAssignedToMe(user!.phone);
    if (mounted) setState(() {});
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.brown[50],
        appBar: AppBar(
          backgroundColor: Colors.brown[400],
          elevation: 0.0,
          title: Text(user != null ? user!.name : "x"),
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
          padding: EdgeInsets.all(10.0),
          child: SingleChildScrollView(
              child: Wrap(
            children: List.generate(orders.length, (index) {
              return Column(
                children: [
                  Divider(
                    thickness: 2,
                  ),
                  ListTile(
                    title: Text(orders[index].serviceRequired),
                    subtitle: Text(orders[index].creationTime.toString()),
                    trailing: Text(
                      orders[index].status,
                      style: TextStyle(
                          color: DashboardFunctions.orderStatusColor(
                              orders[index].status)),
                    ),
                    onTap: () async {
                      showDialog(
                        context: context,
                        builder: (context) {
                          return Material(
                            type: MaterialType.transparency,
                            child: Center(
                              child: Container(
                                margin: EdgeInsets.all(20.0),
                                padding: EdgeInsets.all(20.0),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(10.0),
                                ),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text('Order #${orders[index].orderNo}'),
                                    Text(
                                      '${orders[index].status}',
                                      style: TextStyle(
                                          color: DashboardFunctions
                                              .orderStatusColor(
                                                  orders[index].status),
                                          fontSize: 16.0),
                                    ),
                                    SizedBox(height: 9.0),
                                    Row(
                                      children: [
                                        Text("Name: "),
                                        Spacer(),
                                        Text(orders[index].bikerName),
                                      ],
                                    ),
                                    SizedBox(height: 9.0),
                                    Row(
                                      children: [
                                        Text("Brand: "),
                                        Spacer(),
                                        Text(orders[index].motorcycleType),
                                      ],
                                    ),
                                    SizedBox(height: 9.0),
                                    Row(
                                      children: [
                                        Text("Plate No: "),
                                        Spacer(),
                                        Text(orders[index].motorcycleNumber),
                                      ],
                                    ),
                                    SizedBox(height: 9.0),
                                    Row(
                                      children: [
                                        Text("Service required: "),
                                        Spacer(),
                                        Text(orders[index].serviceRequired),
                                      ],
                                    ),
                                    SizedBox(height: 20.0),
                                    Expanded(
                                      child: GoogleMap(
                                        initialCameraPosition: CameraPosition(
                                          target: orders[index].location,
                                          zoom: 15.0,
                                        ),
                                        markers: {
                                          Marker(
                                            markerId:
                                                MarkerId(orders[index].orderNo),
                                            position: orders[index].location,
                                          ),
                                        },
                                      ),
                                    ),
                                    SizedBox(height: 20.0),
                                    if (orders[index].status != "completed")
                                      ElevatedButton(
                                        onPressed: () async {
                                          // Accept button action
                                          // Implement your logic here
                                          await _orderServices
                                              .updateOrderStatus(
                                                  orders[index],
                                                  orders[index].shopUid,
                                                  orders[index].shopPhone,
                                                  'completed',
                                                  orders[index].assignedTo);
                                          Navigator.pop(context);
                                          getOrders();
                                        },
                                        child: Text('Mark As Completed'),
                                        style: ButtonStyle(
                                          backgroundColor:
                                              MaterialStateProperty.all<Color>(
                                                  Colors.green),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                  Divider(
                    thickness: 2,
                  ),
                ],
              );
            }),
          )),
        ));
  }
}
