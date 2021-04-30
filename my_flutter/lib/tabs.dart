import 'package:flutter/material.dart';
import 'provider.dart';

Widget buildTabController(BuildContext context) {

  var tabTitles = ['tab1','tab2'];
  var tabItems = tabTitles.map((e){
    return Tab(text: e);
  }).toList();
   return DefaultTabController(
     length: tabItems.length,
     child: Scaffold(
       appBar: AppBar(
         bottom: TabBar(
           tabs:tabItems,
           onTap: (int index) {
             print('clip tab: ${tabTitles[index]}');
             testNotifier();
           },
           ),
       ),
     ),
   );
}