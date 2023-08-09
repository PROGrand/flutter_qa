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
  State<MyApp> createState() => MyAppState();
}

class MyAppState extends State<MyApp> {
  final Store<AppState> store = Store<AppState>(
    appReducer,
    initialState: AppState(
          (b) => b
        ..states = ListBuilder<QABaseState>(
          <QABaseState>[
            OrderingState(
                  (b) => b
                ..title = 'Ordering'
                ..items = ListBuilder<OrderableItem>(
                  <OrderableItem>[
                    OrderableItem(
                          (b) => b
                        ..title = 'Item 1'
                        ..color = Colors.blue[300],
                    ),
                    // Add other OrderableItems similarly
                  ],
                )
                ..ordered = ListBuilder<int>(
                  <int>[5, 4, 3, 2, 1, 0],
                ),
            ),
            MatchingState(
                  (b) => b
                ..title = 'Matching'
                ..sources = ListBuilder<String>(
                  <String>['Query 1', 'Query 2', 'Query 3'],
                )
                ..destinations = ListBuilder<String>(
                  <String>[
                    'Answer 1',
                    'Answer 2',
                    'Answer 3',
                    'Answer 4',
                    'Answer 5',
                    'Answer 6',
                  ],
                )
                ..connections = MapBuilder<int, int>(
                  <int, int>{0: 0, 1: 1, 2: 2},
                ),
            ),
          ],
        ),
    ),
    distinct: true,
    middleware: [],
  );

  @override
  Widget build(BuildContext context) {
    return StoreProvider<AppState>(
      store: store,
      child: MaterialApp(
        theme: _buildTheme(),
        home: MainPage(),
      ),
    );
  }

  ThemeData _buildTheme() {
    return ThemeData(
      brightness: Brightness.light,
      primarySwatch: Colors.blue,
    );
  }
}
