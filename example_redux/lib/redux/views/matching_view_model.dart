import 'package:redux/redux.dart';

import '../actions.dart';
import '../states.dart';

class MatchingViewModel {
  MatchingViewModel(
      {this.matching,
      this.addConnection,
      this.removeConnection,
      this.clearAll});

  final MatchingState matching;

  final Function(int source, int destination) addConnection;

  final Function(int source) removeConnection;

  final Function clearAll;

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
          Store<AppState> store, int stateIndex) =>
      MatchingViewModel(
          matching: store.state.states[stateIndex] as MatchingState,
          addConnection: (source, destination) {
            store.dispatch(AddConnection(source, destination, stateIndex));
          },
          removeConnection: (int source) {
            store.dispatch(RemoveConnection(source, stateIndex));
          },
          clearAll: () {
            store.dispatch(RemoveAllConnections(stateIndex));
          });
}
