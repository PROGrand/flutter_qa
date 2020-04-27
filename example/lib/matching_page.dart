import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_qa/qa_widgets/qa_matching.dart';


/// For demo purposes only. Save production data state using appropriate engines like redux.

Map<int, int> connections = <int, int>{0: 1, 1: 2};
List<String> sources = ['Query 1', 'Query 2', 'Query 3'];
List<String> destinations = [
  'Answer 1',
  'Answer 2',
  'Answer 3',
  'Answer 4',
  'Answer 5',
  'Answer 6'
];

///////////////////////////////////////////

class MatchingPage extends StatefulWidget {
  MatchingPage({Key key}) : super(key: key);

  @override
  State<MatchingPage> createState() {
    return MatchingPageState();
  }
}


class MatchingPageState extends State<MatchingPage> {

  final matchingKey = MatchingWidget.createGlobalKey();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        SizedBox(
          height: 8,
        ),
        Text('Lorem ipsum dolor sit amet.',
            style: Theme.of(context).textTheme.title),
        MatchingWidget(
          key: matchingKey,
          builder: MatchingWidgetBuilder(
              activeColor: Theme.of(context).primaryColor.withOpacity(0.25),
              connectedColor: Theme.of(context).primaryColor,
              onAddConnection: (s, d) {
                connections[s] = d;
              },
              onRemoveConnection: (s) {
                connections.remove(s);
              },
              onClearAll: () {
                connections.clear();
              },
              sourcesCount: sources.length,
              destinationsCount: destinations.length,
              build: (BuildContext context, bool query, int index) =>
                  (query ? _query(index) : _answer(index)),
              connections: connections),
        ),
        RaisedButton(
          child: Text('Clear'),
          onPressed: () {
            matchingKey.currentState.clear();
          },
        ),
        SizedBox(
          height: 16,
        )
      ],
    );
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
          child: Text('${sources[index]}',
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
        child: Text('${destinations[index]}',
            style: TextStyle(color: Colors.black, fontSize: 12.0)),
      ),
    );
  }
}
