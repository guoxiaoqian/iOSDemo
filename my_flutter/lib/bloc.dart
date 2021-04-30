

import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

abstract class BlocBase {
  void dispose();
} 

class BlocCounter extends BlocBase {

  final StreamController _controller = StreamController<int>();

  void add(i) {
    _controller.sink.add(i+1);
  }

  get counter => _controller.stream;

  @override
  void dispose() {

  }
}

class BlocHomePage extends StatefulWidget {
  @override
  State createState() => BlocHomePageSate(BlocCounter());
}

class BlocHomePageSate extends State<BlocHomePage> {
  int _count = 0;
  final BlocCounter counter;

  BlocHomePageSate(this.counter);

  @override
  void initState(){
    super.initState();

    counter.counter.listen((count){
      setState(() {
        _count = count;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('bloc'),
      ),
      body: Center(
        child: Text('count = ${_count}'),
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: (){
          counter.add(_count);
        },
      ),
    );
  }
}