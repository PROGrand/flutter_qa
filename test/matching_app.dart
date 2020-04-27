part of 'widget_test.dart';

bool onAddCalled = false;
bool onRemoveCalled = false;
bool onClearCalled = false;

class MatchingTestApp extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return MatchingTestAppState();
  }
}

class MatchingTestAppState extends State<MatchingTestApp> {
  @override
  Widget build(BuildContext context) => MaterialApp(
        home: MatchingTestPage(),
      );
}

class MatchingTestPage extends StatefulWidget {
  MatchingTestPage({Key key, this.matchingIndex}) : super(key: key);

  final int matchingIndex;

  @override
  State<MatchingTestPage> createState() {
    return MatchingTestPageState();
  }
}

class MatchingTestPageState extends State<MatchingTestPage> {
  final matchingKey1 = MatchingWidget.createGlobalKey();
  final matchingKey2 = MatchingWidget.createGlobalKey();

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
              matchingKey1,
              'Clear',
              context,
              Theme.of(context).primaryColor.withOpacity(0.25),
              Theme.of(context).primaryColor),
        ),
        Visibility(
          child: _buildColumn(matchingKey2, 'Clear2', context, null, null),
          visible: false,
        )
      ],
    );
  }

  Column _buildColumn(GlobalKey<MatchingWidgetState> k, String ct,
      BuildContext context, Color c1, Color c2) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Expanded(
          child: MatchingWidget(
            key: k,
            builder: MatchingWidgetBuilder(
                activeColor: c1,
                connectedColor: c2,
                onAddConnection: (int s, int d) {
                  onAddCalled = true;
                },
                onRemoveConnection: (int s) {
                  onRemoveCalled = true;
                },
                onClearAll: () {
                  onClearCalled = true;
                },
                sourcesCount: 3,
                destinationsCount: 4,
                build: (BuildContext context, bool query, int index) =>
                    (query ? _query(index) : _answer(index)),
                connections: <int, int>{0: 1, 1: 2, 2: 0}),
          ),
        ),
        Padding(
            padding: EdgeInsets.only(bottom: 16),
            child: RaisedButton(
              child: Text(ct),
              onPressed: () {
                k.currentState.clear();
              },
            ))
      ],
    );
  }
}

Container _query(int index) {
  return Container(
      padding: EdgeInsets.all(16),
      color: const Color(0xffe4f2fd),
      foregroundDecoration: BoxDecoration(
          border: Border.all(
        color: const Color(0xffc2d2e1),
        width: 2,
      )),
      child: Center(
        child: Text('Query $index',
            style: TextStyle(color: Colors.black, fontSize: 12.0)),
      ));
}

Container _answer(int index) {
  return Container(
    padding: EdgeInsets.all(16),
    color: const Color(0xffe4f2fd),
    foregroundDecoration: BoxDecoration(
        border: Border.all(
      color: const Color(0xffc2d2e1),
      width: 2,
    )),
    child: Center(
      child: Text('Answer $index',
          style: TextStyle(color: Colors.black, fontSize: 12.0)),
    ),
  );
}
