import 'package:flutter/material.dart';
import 'package:flutter_qa/qa_widgets/qa_matching.dart';

class MatchingPage extends StatelessWidget {
  final matching_key = MatchingWidget.createGlobalKey();

  MatchingPage({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Expanded(
          child: MatchingWidget(
            key: matching_key,
            builder: MatchingWidgetBuilder(
                queriesCount: 3,
                answersCount: 4,
                builder: (BuildContext context, bool query, int index) =>
                    (query ? _query(index) : _answer(index))),
          ),
        ),
        Padding(
            padding: EdgeInsets.only(bottom: 16),
            child: RaisedButton(
              child: Text('Clear'),
              onPressed: () {
                matching_key.currentState.clear();
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
        child: Text('Query ${index + 1}',
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
      child: Text('Answer ${index + 1}',
          style: TextStyle(color: Colors.black, fontSize: 12.0)),
    ),
  );
}
