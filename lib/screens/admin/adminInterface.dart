import 'package:flutter/material.dart';
import 'package:mbs_fyp/models/customerUser.dart';
import 'package:mbs_fyp/models/shopInfo.dart';
import 'package:mbs_fyp/services/adminServices.dart';
import 'package:mbs_fyp/services/authService.dart';

class AdminInterface extends StatefulWidget {
  const AdminInterface({super.key});

  @override
  State<AdminInterface> createState() => _AdminInterfaceState();
}

class _AdminInterfaceState extends State<AdminInterface> {
  AuthSevrices _auth = AuthSevrices();
  AdminServices _adminServices = AdminServices();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.brown[50],
      appBar: AppBar(
        backgroundColor: Colors.brown[400],
        elevation: 0.0,
        title: Text("ADMIN"),
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
      body: Column(
        children: [
          Container(
            padding: EdgeInsets.all(10.0),
          ),
          ElevatedButton(
            onPressed: () async {
              List<ShopInfo> newShops = await _adminServices.getNewShops();
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: Text('New Shops'),
                    content: Container(
                      width: double.minPositive,
                      child: ListView.builder(
                        itemCount: newShops.length,
                        itemBuilder: (context, index) {
                          return Card(
                            child: Column(
                              children: [
                                ListTile(
                                  title: Text(newShops[index].shopName),
                                  subtitle: Text(newShops[index].address),
                                  trailing:
                                      Text(newShops[index].phone.toString()),
                                ),
                                Row(
                                  children: [
                                    ElevatedButton(
                                        onPressed: () async {
                                          await _adminServices
                                              .accountActivation(
                                                  newShops[index].uid, true);
                                          Navigator.pop(context);
                                        },
                                        child: Text("Approve")),
                                    Spacer(),
                                    ElevatedButton(
                                        onPressed: () async {
                                          await _adminServices
                                              .accountActivation(
                                                  newShops[index].uid, false);
                                          Navigator.pop(context);
                                        },
                                        child: Text("reject")),
                                  ],
                                )
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                    actions: <Widget>[
                      ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: Text('Close'),
                      ),
                    ],
                  );
                },
              );
            },
            child: Text(
              "new shops",
              style: TextStyle(
                fontSize: 16.0,
                color: Colors.black87,
              ),
            ),
            style: ButtonStyle(
              backgroundColor: MaterialStateProperty.all<Color>(
                  Colors.grey.shade300), // Set the button color here
            ),
          ),
          Container(
            padding: EdgeInsets.all(10.0),
          ),
          ElevatedButton(
            onPressed: () async {
              List<ShopInfo> suspenededShops =
                  await _adminServices.getSuspendedShops();
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: Text('Suspeneded Accounts'),
                    content: Container(
                      width: double.minPositive,
                      child: ListView.builder(
                        itemCount: suspenededShops.length,
                        itemBuilder: (context, index) {
                          return Card(
                            child: Column(
                              children: [
                                ListTile(
                                  title: Text(suspenededShops[index].shopName),
                                  subtitle:
                                      Text(suspenededShops[index].address),
                                  trailing: Text(
                                      suspenededShops[index].phone.toString()),
                                ),
                                Row(
                                  children: [
                                    ElevatedButton(
                                        onPressed: () async {
                                          await _adminServices
                                              .reActivateAcounts(
                                                  suspenededShops[index].uid,
                                                  "suspend-client");
                                          Navigator.pop(context);
                                        },
                                        child: Text("re-acativater")),
                                  ],
                                )
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                    actions: <Widget>[
                      ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: Text('Close'),
                      ),
                    ],
                  );
                },
              );
            },
            child: Text(
              "Suspended Shops",
              style: TextStyle(
                fontSize: 16.0,
                color: Colors.black87,
              ),
            ),
            style: ButtonStyle(
              backgroundColor: MaterialStateProperty.all<Color>(
                  Colors.grey.shade300), // Set the button color here
            ),
          ),
          Container(
            padding: EdgeInsets.all(10.0),
          ),
          ElevatedButton(
            onPressed: () async {
              List<CustomerUser> suspenededCustomers =
                  await _adminServices.getSuspendedCustomer();
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: Text('Suspeneded Accounts'),
                    content: Container(
                      width: double.minPositive,
                      child: ListView.builder(
                        itemCount: suspenededCustomers.length,
                        itemBuilder: (context, index) {
                          return Card(
                            child: Column(
                              children: [
                                ListTile(
                                  title: Text(
                                      suspenededCustomers[index].firstName +
                                          suspenededCustomers[index].lastName),
                                  subtitle: Text(suspenededCustomers[index]
                                      .motorcycleNumber),
                                  trailing: Text(suspenededCustomers[index]
                                      .phone
                                      .toString()),
                                ),
                                Row(
                                  children: [
                                    ElevatedButton(
                                        onPressed: () async {
                                          await _adminServices
                                              .reActivateAcounts(
                                                  suspenededCustomers[index]
                                                      .uid,
                                                  "suspend-customer");
                                          Navigator.pop(context);
                                        },
                                        child: Text("re-acativater")),
                                  ],
                                )
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                    actions: <Widget>[
                      ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: Text('Close'),
                      ),
                    ],
                  );
                },
              );
            },
            child: Text(
              "Suspended customer",
              style: TextStyle(
                fontSize: 16.0,
                color: Colors.black87,
              ),
            ),
            style: ButtonStyle(
              backgroundColor: MaterialStateProperty.all<Color>(
                  Colors.grey.shade300), // Set the button color here
            ),
          ),
          Container(
            padding: EdgeInsets.all(10.0),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "Reports",
                style: TextStyle(
                  fontSize: 24.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          )
        ],
      ),
    );
  }
}
