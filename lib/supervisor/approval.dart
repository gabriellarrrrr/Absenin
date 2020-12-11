import 'package:absenin/supervisor/accpermission.dart';
import 'package:absenin/supervisor/accswitch.dart';
import 'package:flutter/material.dart';
import 'package:md2_tab_indicator/md2_tab_indicator.dart';

class Approval extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return ApprovalState();
  }
}

class ApprovalState extends State<Approval>
    with SingleTickerProviderStateMixin {
  TabController tabController;

  @override
  void initState() {
    super.initState();
    tabController = new TabController(length: 2, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Approval'),
        bottom: TabBar(
          controller: tabController, 
          unselectedLabelColor: Theme.of(context).disabledColor,
          indicator: MD2Indicator(
            indicatorHeight: 3.0,
            indicatorColor: Theme.of(context).accentColor,
            indicatorSize: MD2IndicatorSize.normal
          ),
          tabs: [
            Tab(
              text: 'Permission',
            ),
            Tab(
              text: 'Switch',
            )
          ]
        ),
      ),
      body: TabBarView(controller: tabController, children: [
        AccPermission(),
        AccSwitch(),
      ]),
    );
  }
}
