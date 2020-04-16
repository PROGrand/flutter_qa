import 'package:built_collection/built_collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_qa_example/redux/reducers.dart';
import 'package:flutter_qa_example/redux/states.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:redux/redux.dart';

import 'main_page.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return MyAppState();
  }
}

class MyAppState extends State<MyApp> {
  final Store<AppState> store = Store(
    appReducer,
    initialState: AppState((b) => b
      ..matchingStates = ListBuilder<MatchingState>(<MatchingState>[
        MatchingState((b) => b
          ..title = 'Question 1'
          ..sources =
              ListBuilder<String>(<String>['Query 1', 'Query 2', 'Query 3'])
          ..destinations = ListBuilder<String>(
              <String>['Answer 1', 'Answer 2', 'Answer 3', 'Answer 4'])
          ..connections = MapBuilder<int, int>(<int, int>{0: 0, 1: 1, 2: 2})),
        MatchingState((b) => b
          ..title = 'Test 2'
          ..sources =
              ListBuilder<String>(<String>['Query I', 'Query II', 'Query III'])
          ..destinations = ListBuilder<String>(
              <String>['Answer I', 'Answer II', 'Answer III', 'Answer IV'])),
        MatchingState((b) => b
          ..title = 'Test 3'
          ..sources =
              ListBuilder<String>(<String>['Query A', 'Query B', 'Query C'])
          ..destinations = ListBuilder<String>(
              <String>['Answer A', 'Answer B', 'Answer C', 'Answer D']))
      ])),
    distinct: true,
    middleware: [],
  );

  @override
  Widget build(BuildContext context) => StoreProvider<AppState>(
      store: store,
      child: MaterialApp(
        home: MainPage(),
      ));
}

//////////////////////////////////////////
