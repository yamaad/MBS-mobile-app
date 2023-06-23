import 'package:flutter/material.dart';
import 'package:mbs_fyp/components/viewStoreCard.dart';
import 'package:mbs_fyp/models/shopInfo.dart';

import '../../services/authService.dart';

class ViewStore extends StatefulWidget {
  final List<ShopInfo> shopInfo;
  const ViewStore({required this.shopInfo});

  @override
  State<ViewStore> createState() => _ViewStoreState();
}

class _ViewStoreState extends State<ViewStore> {
  final AuthSevrices _auth = AuthSevrices();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.brown[50],
      appBar: AppBar(
        backgroundColor: Colors.brown[400],
        elevation: 0.0,
        title: Text("STORES"),
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
        child: ListView.separated(
          itemCount: widget.shopInfo.length,
          itemBuilder: (context, index) {
            return Builder(builder: (context) {
              return CustomCardWidget(
                shopName: widget.shopInfo[index].shopName,
                pricing: widget.shopInfo[index].pricing,
                service: widget.shopInfo[index].service,
                pricingCount: widget.shopInfo[index].pricingCount,
                serviceCount: widget.shopInfo[index].serviceCount,
                address: widget.shopInfo[index].address,
                onPress: () {
                  if (widget.shopInfo[index].services.isEmpty) {
                    // Handle empty list scenario
                    showDialog(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          title: Text('No services options'),
                          content: Text(
                              'There are no services options available for this shop at the moment.'),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                              child: Text('OK'),
                            ),
                          ],
                        );
                      },
                    );
                  } else {
                    final RenderBox button =
                        context.findRenderObject() as RenderBox;
                    final Offset offset = button.localToGlobal(Offset.zero);

                    // Show the menu
                    showMenu<String>(
                      context: context,
                      position: RelativeRect.fromLTRB(
                        offset.dx,
                        offset.dy + button.size.height,
                        offset.dx + button.size.width,
                        offset.dy + button.size.height * 2,
                      ),
                      items:
                          widget.shopInfo[index].services.map((String option) {
                        return PopupMenuItem<String>(
                          value: option,
                          child: Row(
                            children: [
                              Text(option),
                            ],
                          ),
                          onTap: () {},
                        );
                      }).toList(),
                    );
                  }
                },
              );
            });
          },
          separatorBuilder: (context, index) =>
              SizedBox(height: 10), // Adjust the height as needed
        ),
      ),
    );
  }
}
