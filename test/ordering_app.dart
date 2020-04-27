part of 'widget_test.dart';

bool onOrderCalled = false;

class OrderingTestApp extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return OrderingTestAppState();
  }
}

class OrderingTestAppState extends State<OrderingTestApp> {
  @override
  Widget build(BuildContext context) => MaterialApp(
        home: OrderingTestPage(),
      );
}

class OrderingTestPage extends StatefulWidget {
  OrderingTestPage({Key key, this.matchingIndex}) : super(key: key);

  final int matchingIndex;

  @override
  State<OrderingTestPage> createState() {
    return OrderingTestPageState();
  }
}

class OrderingTestPageState extends State<OrderingTestPage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return IndexedStack(
      children: <Widget>[
        Visibility(
          child: _buildColumn(
              'Clear',
              context,
              Theme.of(context).primaryColor.withOpacity(0.25),
              Theme.of(context).primaryColor),
        ),
        Visibility(
          child: _buildColumn('Clear2', context, null, null),
          visible: false,
        )
      ],
    );
  }

  Column _buildColumn(String ct, BuildContext context, Color c1, Color c2) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Expanded(
          child: DragListWidget<String>(
            builder: DragListWidgetBuilder<String>(
              ordered: ListBuilder<int>(<int>[3, 2, 1, 0]).build(),
              items: <String>['3', '2', '1', '0'],
              onOrder: (List<int> ordered) {
                onOrderCalled = true;
              },
              build: (BuildContext context, String s) => Text(s),
            ),
          ),
        )
      ],
    );
  }
}
