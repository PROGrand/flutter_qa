import 'package:flutter/material.dart';
import 'package:flutter_qa/qa_widgets/qa_matching.dart';
import 'package:flutter_qa_example/redux/states.dart';
import 'package:flutter_qa_example/redux/views/matching_view_model.dart';
import 'package:flutter_redux/flutter_redux.dart';

class MatchingPage extends StatefulWidget {
  final int matchingIndex;

  MatchingPage({Key key, this.matchingIndex}) : super(key: key);

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
    return StoreConnector<AppState, MatchingViewModel>(
        converter: (store) =>
            MatchingViewModel.fromStore(store, widget.matchingIndex),
        builder: _build,
        distinct: true,
        //in this example it is for mark only.
        rebuildOnChange: false);
  }

  Widget _build(BuildContext context, MatchingViewModel vm) {
    return Column(
      children: <Widget>[
        Expanded(
          child: MatchingWidget(
            key: matchingKey,
            builder: MatchingWidgetBuilder(
                activeColor: Theme.of(context).primaryColor.withOpacity(0.25),
                connectedColor: Theme.of(context).primaryColor,
                onAddConnection: vm.addConnection,
                onRemoveConnection: vm.removeConnection,
                onClearAll: vm.clearAll,
                sourcesCount: vm.matching.sources.length,
                destinationsCount: vm.matching.destinations.length,
                build: (BuildContext context, bool query, int index) =>
                    (query ? _query(index, vm) : _answer(index, vm)),
                connections: vm.matching.connections),
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

Container _query(int index, MatchingViewModel vm) {
  return Container(
      padding: EdgeInsets.all(16),
      color: const Color(0xffe4f2fd),
      foregroundDecoration: BoxDecoration(
          border: Border.all(
        color: const Color(0xffc2d2e1),
        width: 2,
      )),
      child: Center(
        child: Text('${vm.matching.sources[index]}',
            style: TextStyle(color: Colors.black, fontSize: 12.0)),
      ));
}

Container _answer(int index, MatchingViewModel vm) {
  return Container(
    padding: EdgeInsets.all(16),
    color: const Color(0xffe4f2fd),
    foregroundDecoration: BoxDecoration(
        border: Border.all(
      color: const Color(0xffc2d2e1),
      width: 2,
    )),
    child: Center(
      child: Text('${vm.matching.destinations[index]}',
          style: TextStyle(color: Colors.black, fontSize: 12.0)),
    ),
  );
}