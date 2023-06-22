import 'package:flutter/material.dart';
import 'package:mbs_fyp/services/authService.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({Key? key}) : super(key: key);

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  final AuthSevrices _auth = AuthSevrices();
  String status = "online";
  String switchStatus = "go offline";
  List<bool> checkboxValues = List<bool>.filled(6, false);
  List<String> servicesList = [
    "on spot checkout",
    "insurance renewal",
    "gasoline",
    "battery",
    "spare parts",
    "others"
  ];
  List<String> orders = [
    "order1",
    "order1",
    "order1",
    "order1",
    "order1",
    "order1",
    "order1",
  ];
  Color textColor() {
    return status == "online" ? Colors.green : Colors.red;
  }

  void toggleSwitch() async {
    if (status == "online") {
      setState(() {
        switchStatus = "go online";
        status = "offline";
      });
    } else {
      setState(() {
        status = "online";
        switchStatus = "go offline";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
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
                          status,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 24.0,
                            color: textColor(),
                          ),
                        ),
                        ElevatedButton(
                          onPressed: toggleSwitch,
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
            children: List.generate(6, (index) {
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Checkbox(
                    value: checkboxValues[index],
                    onChanged: (bool? value) {
                      setState(() {
                        checkboxValues[index] = value ?? false;
                      });
                    },
                  ),
                  Text(servicesList[index]),
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
