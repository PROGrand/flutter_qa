import 'package:redux/redux.dart';

import '../actions.dart';
import '../states.dart';

class MatchingViewModel {
  final MatchingState matching;

  final Function(int source, int destination) addConnection;

  final Function(int source) removeConnection;

  final Function clearAll;

  MatchingViewModel(
      {this.matching,
      this.addConnection,
      this.removeConnection,
      this.clearAll});

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is MatchingViewModel && matching == other.matching;
  }

  @override
  int get hashCode {
    return matching.hashCode;
  }

  @override
  String toString() {
    return matching.toString();
  }

  static MatchingViewModel fromStore(
          Store<AppState> store, int matchingIndex) =>
      MatchingViewModel(
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
