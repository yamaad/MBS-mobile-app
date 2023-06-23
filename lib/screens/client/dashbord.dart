import 'package:flutter/material.dart';
import 'package:mbs_fyp/models/user.dart';
import 'package:mbs_fyp/services/authService.dart';
import 'package:mbs_fyp/services/shopServices.dart';
import 'package:provider/provider.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({Key? key}) : super(key: key);

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  final AuthSevrices _auth = AuthSevrices();
  final ShopServices _shopServices = ShopServices();
  bool status = true;
  String? clientID;
  String switchStatus = "go offline";
  // List<bool> checkboxValues = List<bool>.filled(6, false);
  List<Map<String, dynamic>> servicesList = [
    {'services': "on spot checkout", 'availablity': false},
    {'services': "insurance renewal", 'availablity': false},
    {'services': "gasoline", 'availablity': false},
    {'services': "battery", 'availablity': false},
    {'services': "spare parts", 'availablity': false},
    {'services': "others", 'availablity': false},
  ];

  List<String> orders = [
    "order1",
    "order1",
    "order1",
  ];
  Color textColor() {
    return status ? Colors.green : Colors.red;
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
                            color: textColor(),
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
          Text("Orders"),
          Expanded(
            child: CustomScrollView(
              slivers: [
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (BuildContext context, int index) {
                      String order = orders[index];
                      return ListTile(
                        title: Text('Order ${index + 1}'),
                        subtitle: Text('Status: ${index + 1} status'),
                        onTap: () {
                          // Handle order tap event
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
