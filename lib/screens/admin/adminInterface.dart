import 'package:flutter/material.dart';
import 'package:mbs_fyp/models/customerUser.dart';
import 'package:mbs_fyp/models/orderInfo.dart';
import 'package:mbs_fyp/models/reportinfo.dart';
import 'package:mbs_fyp/models/shopInfo.dart';
import 'package:mbs_fyp/services/adminServices.dart';
import 'package:mbs_fyp/services/authService.dart';
import 'package:mbs_fyp/services/orderServcies.dart';
import 'package:mbs_fyp/services/reportServices.dart';

class AdminInterface extends StatefulWidget {
  const AdminInterface({super.key});

  @override
  State<AdminInterface> createState() => _AdminInterfaceState();
}

class _AdminInterfaceState extends State<AdminInterface> {
  AuthSevrices _auth = AuthSevrices();
  AdminServices _adminServices = AdminServices();
  List<ReportInfo> reports = [];
  ScrollController _scrollController = ScrollController();
  ReportServices _reportServices = ReportServices();
  OrderServices _orderServices = OrderServices();

  @override
  void initState() {
    super.initState();
    fetchReports();

    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        // Fetch more orders
        if (mounted) {
          fetchReports();
        }
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future deActivateAccount(String uid, String userType) async {
    await _adminServices.deActivateAcounts(uid, userType);
  }

  Future fetchReports() async {
    if (mounted) {
      List<ReportInfo> fetchedReports =
          await _reportServices.getUnresovledReports();
      setState(() {
        reports = fetchedReports;
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
                    title: Text('Suspended Accounts'),
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
                                        child: Text("re-activate")),
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
                                        child: Text("re-activate")),
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
                "New Reports",
                style: TextStyle(
                  fontSize: 24.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              
            ],
          ),
          SizedBox(
            height: 10,
          ),
          Expanded(
            child: CustomScrollView(
              controller: _scrollController,
              slivers: [
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (BuildContext context, int index) {
                      ReportInfo report = reports[index];

                      return Column(
                        children: [
                          ListTile(
                            leading: CircleAvatar(
                              backgroundColor: Colors.brown[100],
                              child: Text(
                                (index + 1).toString(),
                                style: TextStyle(color: Colors.black),
                              ),
                            ),
                            trailing: Text(
                                '${report.creationTime.day}-${report.creationTime.month}-${report.creationTime.year} ${report.creationTime.hour}:' +
                                    (report.creationTime.minute < 10
                                        ? '0${report.creationTime.minute}'
                                        : "${report.creationTime.minute}")),
                            title: Text(report.title),
                            subtitle: Text(
                              report.description,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            onTap: () async {
                              await showDialog(
                                  context: context,
                                  builder: (context) {
                                    return AlertDialog(
                                      title: Text(report.title),
                                      content: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [Text(report.description)]),
                                      actions: [
                                        Column(
                                          children: [
                                            if (report.orderUid != "")
                                              Row(
                                                children: [
                                                  TextButton(
                                                    onPressed: () async {
                                                      final userType = await _auth
                                                          .getUserType(report
                                                              .reportedUid!);
                                                      String name = "-";
                                                      String email = "-";
                                                      num phone = 0;
                                                      if (userType ==
                                                          "client") {
                                                        final user = await _auth
                                                            .getShopData(report
                                                                .reportedUid!);
                                                        name = user.shopName;
                                                        email = user.email;
                                                        phone = user.phone;
                                                      }
                                                      if (userType ==
                                                          "customer") {
                                                        final user = await _auth
                                                            .getBikerData(report
                                                                .reporterUid);
                                                        name = user.firstName +
                                                            " " +
                                                            user.lastName;
                                                        email = user.email;
                                                        phone = user.phone;
                                                      }
                                                      await viewUser(
                                                          context,
                                                          name,
                                                          email,
                                                          userType,
                                                          phone,
                                                          await deActivateAccount(
                                                              report
                                                                  .reportedUid!,
                                                              userType));
                                                    },
                                                    child: Text(
                                                        "Reported detials"),
                                                  ),
                                                  Spacer(),
                                                  TextButton(
                                                    onPressed: () async {
                                                      final order =
                                                          await _orderServices
                                                              .getSingleOrder(
                                                                  report
                                                                      .orderUid!);
                                                      showDialog(
                                                          context: context,
                                                          builder: (context) {
                                                            return AlertDialog(
                                                              content: Column(
                                                                  mainAxisSize:
                                                                      MainAxisSize
                                                                          .min,
                                                                  children: [
                                                                    Row(
                                                                      children: [
                                                                        Text(
                                                                            "Order NO.:"),
                                                                        SizedBox(
                                                                          width:
                                                                              10.0,
                                                                        ),
                                                                        Text(order
                                                                            .orderNo),
                                                                      ],
                                                                    ),
                                                                    SizedBox(
                                                                      height:
                                                                          20,
                                                                    ),
                                                                    Row(
                                                                      children: [
                                                                        Text(
                                                                            "Service:"),
                                                                        SizedBox(
                                                                          width:
                                                                              10.0,
                                                                        ),
                                                                        Text(order
                                                                            .serviceRequired),
                                                                      ],
                                                                    ),
                                                                    SizedBox(
                                                                      height:
                                                                          20,
                                                                    ),
                                                                    Row(
                                                                      children: [
                                                                        Text(
                                                                            "Time:"),
                                                                        SizedBox(
                                                                          width:
                                                                              10.0,
                                                                        ),
                                                                        Text(order
                                                                            .creationTime
                                                                            .toString()),
                                                                      ],
                                                                    )
                                                                  ]),
                                                              actions: [
                                                                TextButton(
                                                                    onPressed: () =>
                                                                        Navigator.pop(
                                                                            context),
                                                                    child: Text(
                                                                        "close"))
                                                              ],
                                                            );
                                                          });
                                                    },
                                                    child:
                                                        Text("Order Detials"),
                                                  ),
                                                ],
                                              ),
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                TextButton(
                                                  onPressed: () async {
                                                    final userType =
                                                        await _auth.getUserType(
                                                            report.reporterUid);
                                                    String name = "-";
                                                    String email = "-";
                                                    num phone = 0;
                                                    if (userType == "client") {
                                                      final user = await _auth
                                                          .getShopData(report
                                                              .reporterUid);
                                                      name = user.shopName;
                                                      email = user.email;
                                                      phone = user.phone;
                                                    }
                                                    if (userType ==
                                                        "customer") {
                                                      final user = await _auth
                                                          .getBikerData(report
                                                              .reporterUid);
                                                      name = user.firstName +
                                                          " " +
                                                          user.lastName;
                                                      email = user.email;
                                                      phone = user.phone;
                                                    }
                                                    await viewUser(
                                                        context,
                                                        name,
                                                        email,
                                                        userType,
                                                        phone,
                                                        await deActivateAccount(
                                                            report.reporterUid,
                                                            userType));
                                                  },
                                                  child:
                                                      Text("Reporter detials"),
                                                ),
                                              ],
                                            ),
                                            SizedBox(height: 10.0),
                                            TextButton(
                                              onPressed: () async {
                                                await _reportServices
                                                    .resolveReport(report.uid);
                                                await fetchReports();
                                                Navigator.pop(context);
                                              },
                                              child: Text("mark as resolved"),
                                            )
                                          ],
                                        ),
                                      ],
                                    );
                                  });
                            },
                          ),
                          Divider(
                            thickness: 2,
                          ),
                        ],
                      );
                    },
                    childCount: reports.length,
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}

Future viewUser(context, String name, String email, String userType, num phone,
    void deActivateAcount) async {
  showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Column(mainAxisSize: MainAxisSize.min, children: [
            Row(
              children: [
                Text("Name:"),
                SizedBox(
                  width: 20.0,
                ),
                Text(name),
              ],
            ),
            SizedBox(
              height: 10.0,
            ),
            Row(
              children: [
                Text("Email:"),
                SizedBox(
                  width: 20.0,
                ),
                Text(email),
              ],
            ),
            SizedBox(
              height: 10.0,
            ),
            Row(
              children: [
                Text("Phone:"),
                SizedBox(
                  width: 20.0,
                ),
                Text(phone.toString()),
              ],
            ),
            SizedBox(
              height: 10.0,
            ),
            Row(
              children: [
                Text("User:"),
                SizedBox(
                  width: 20.0,
                ),
                Text(userType),
              ],
            )
          ]),
          actions: [
            Row(
              children: [
                TextButton(
                    onPressed: () async {
                      deActivateAcount;
                      Navigator.pop(context);
                    },
                    child: Text("Suspend Account")),
                Spacer(),
                TextButton(
                    onPressed: () async {
                      Navigator.pop(context);
                    },
                    child: Text("close")),
              ],
            )
          ],
        );
      });
}
