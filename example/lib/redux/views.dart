import 'package:built_collection/built_collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_qa_example/matching_page.dart';
import 'package:flutter_qa_example/qa_page.dart';
import 'package:flutter_qa_example/redux/actions.dart';
import 'package:flutter_qa_example/redux/states.dart';
import 'package:redux/redux.dart';

class MatchingViewModel {
  final MatchingState matching;

  final Function(int source, int destination) addConnection;

  final Function(int source) removeConnection;

  final Function clearAll;

  MatchingViewModel(
      {@required this.matching,
      @required this.addConnection,
      @required this.removeConnection,
      @required this.clearAll});

  static MatchingViewModel fromStore(Store<AppState> store, int matchingIndex) {
    return MatchingViewModel(
        matching: store.state.matchingStates[matchingIndex],
        addConnection: (source, destination) {
          store.dispatch(AddConnection(source, destination, matchingIndex));
        },
        removeConnection: (int source) {
          store.dispatch(RemoveConnection(source, matchingIndex));
        },
        clearAll: () {
          store.dispatch(RemoveAllConnections(matchingIndex));
        });
  }
}

class PagesViewModel {
  BuiltList<Page> pages;

  PagesViewModel(this.pages);

  static PagesViewModel fromStore(Store<AppState> store) {
    int matchingIndex = 0;

    final pages = ListBuilder<Page>(<Page>[
      for (final item in store.state.matchingStates)
        Page((b) => b
          ..title = (item as MatchingState).title
          ..builder = (context) => MatchingPage(matchingIndex: matchingIndex++))
    ]).build();

    return PagesViewModel(pages);
  }
}
