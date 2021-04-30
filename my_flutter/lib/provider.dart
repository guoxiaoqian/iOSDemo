import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';
import 'package:provider/provider.dart';

class CartModel extends ChangeNotifier {
  double price = 1;
  void add() {
    price ++;
    notifyListeners();
  }
}

void testNotifier() {
 final CartModel model = CartModel();
    print('testNotifier addListener');
    model.addListener((){
      print('testNotifier price=${model.price}');
    });
    model.add();
}

class CartHomePage extends StatelessWidget {

  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
        create: (context)=>CartModel(),
        child: CartList(),
    );
    // return MultiProvider(providers: [
    //   ChangeNotifierProvider(create: (context)=>CartModel()),
    // ],
    // child: CartList());
  }
}

class CartList extends StatelessWidget {
  Widget build(BuildContext context) {
    return Consumer<CartModel>(
      builder: (context, cart, child) {
        return Column(
          children: [
            Text('consumer=${cart.price} provider=${Provider.of<CartModel>(context).price}'),
            GestureDetector(
              child: Text('click me'),
              onTap: () {
                cart.add();
              },
            )
          ],
        );
      },
    );

  }
}