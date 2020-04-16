import 'package:built_collection/built_collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_qa/qa_widgets/qa_matching.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Verify Platform version', (WidgetTester tester) async {

    await tester.pumpWidget(MatchingTestApp());

    expect(find.text('Query 2'), findsOneWidget);
  });
}

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
  final int matchingIndex;

  MatchingTestPage({Key key, this.matchingIndex}) : super(key: key);

  @override
  State<MatchingTestPage> createState() {
    return MatchingTestPageState();
  }
}

class MatchingTestPageState extends State<MatchingTestPage> {
  final matchingKey = MatchingWidget.createGlobalKey();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Expanded(
          child: MatchingWidget(
            key: matchingKey,
            builder: MatchingWidgetBuilder(
                activeColor: Theme.of(context).primaryColor.withOpacity(0.25),
                connectedColor: Theme.of(context).primaryColor,
                onAddConnection: null,
                onRemoveConnection: null,
                onClearAll: null,
                sourcesCount: 3,
                destinationsCount: 4,
                build: (BuildContext context, bool query, int index) =>
                    (query ? _query(index) : _answer(index)),
                connections: MapBuilder<int,int>(<int, int>{0: 1, 1: 2, 2: 0}).build()),
          ),
        ),
        Padding(
            padding: EdgeInsets.only(bottom: 16),
            child: RaisedButton(
              child: Text('Clear'),
              onPressed: () {
                matchingKey.currentState.clear();
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


