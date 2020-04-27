import 'package:built_collection/built_collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_qa_example_redux/redux/reducers.dart';
import 'package:flutter_qa_example_redux/redux/states.dart';
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
  static final Store<AppState> store = Store(
    appReducer,
    initialState: AppState((b) => b
      ..states = ListBuilder<QABaseState>(<QABaseState>[
        OrderingState((b) => b
          ..title = 'Ordering'
          ..items = ListBuilder<OrderableItem>(<OrderableItem>[
            OrderableItem((b) => b
              ..title = 'Item 1'
              ..color = Colors.blue[300]),
            OrderableItem((b) => b
              ..title = 'Item 2'
              ..color = Colors.blue[400]),
            OrderableItem((b) => b
              ..title = 'Item 3'
              ..color = Colors.blue[500]),
            OrderableItem((b) => b
              ..title = 'Item 4'
              ..color = Colors.blue[600]),
            OrderableItem((b) => b
              ..title = 'Item 5'
              ..color = Colors.blue[700]),
            OrderableItem((b) => b
              ..title = 'Item 6'
              ..color = Colors.blue[800]),
          ])
          ..ordered = ListBuilder<int>(<int>[5, 4, 3, 2, 1, 0])),
        MatchingState((b) => b
          ..title = 'Matching'
          ..sources =
              ListBuilder<String>(<String>['Query 1', 'Query 2', 'Query 3'])
          ..destinations = ListBuilder<String>(<String>[
            'Answer 1',
            'Answer 2',
            'Answer 3',
            'Answer 4',
            'Answer 5',
            'Answer 6'
          ])
          ..connections = MapBuilder<int, int>(<int, int>{0: 0, 1: 1, 2: 2})),
      ])),
    distinct: true,
    middleware: [],
  );

  @override
  Widget build(BuildContext context) => StoreProvider<AppState>(
      store: store,
      child: MaterialApp(
        theme: _buildTheme(),
        home: MainPage(),
      ));

  ThemeData _buildTheme() =>
      ThemeData(brightness: Brightness.light, primarySwatch: Colors.blue);
}

//////////////////////////////////////////
