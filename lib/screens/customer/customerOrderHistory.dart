import 'package:flutter/material.dart';
import 'package:mbs_fyp/screens/customer/showOrderState.dart';
import 'package:mbs_fyp/services/orderServcies.dart';
import '../../models/orderInfo.dart';
import '../client/dashBoardFunctions.dart';

void showOrdersHistory(BuildContext context, String currentUserUid) async {
  final _orderServices = OrderServices();
  List<OrderInfo> orders =
      await _orderServices.getCustOrdersHistory(currentUserUid);
  ScrollController _scrollController = ScrollController();

  showDialog(
    context: context,
    // barrierDismissible: false,
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
              children: [
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
                                showDialog(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    content: ShowOrderState(
                                      currentUserUid: currentUserUid,
                                      order: order,
                                    ),
                                  ),
                                );
                              },
                            );
                          },
                          childCount: orders.length,
                        ),
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      );
    },
  );
}
