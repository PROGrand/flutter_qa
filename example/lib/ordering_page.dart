import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_qa/qa_widgets/qa_draglist.dart';
import 'package:flutter_qa_example/redux/states.dart';
import 'package:flutter_qa_example/redux/views/ordering_view_model.dart';
import 'package:flutter_redux/flutter_redux.dart';

class OrderingPage extends StatefulWidget {
  OrderingPage({Key key, this.qaIndex}) : super(key: key);

  final int qaIndex;

  @override
  State<OrderingPage> createState() {
    return OrderingPageState();
  }
}

class OrderingPageState extends State<OrderingPage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, OrderingViewModel>(
        converter: (store) =>
            OrderingViewModel.fromStore(store, widget.qaIndex),
        builder: _build,
        distinct: true,
        //in this example it is for mark only.
        rebuildOnChange: false);
  }

  Widget _build(BuildContext context, OrderingViewModel vm) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        SizedBox(
          height: 8,
        ),
        Text('Lorem ipsum dolor sit amet.',
            style: Theme.of(context).textTheme.title),
        DragListWidget<OrderableItem>(
            builder: DragListWidgetBuilder<OrderableItem>(
                onOrder: vm.order,
                ordered: vm.ordering.ordered,
                items: vm.ordering.items,
                build: (BuildContext context, OrderableItem item) =>
                    _builtItem(item))),
      ],
    );
  }

  Widget _builtItem(OrderableItem item) {
    return Container(padding: EdgeInsets.only(left: 32, right: 32),
        child: Card(
          color: item.color,
      child: ListTile(
        title: Text(item.title, style: TextStyle(color: Colors.white),),
      ),
    ));
  }
}


