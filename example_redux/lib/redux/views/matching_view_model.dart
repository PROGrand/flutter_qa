import 'package:redux/redux.dart';

import '../actions.dart';
import '../states.dart';

class MatchingViewModel {
  MatchingViewModel({
    required this.matching,
    required this.addConnection,
    required this.removeConnection,
    required this.clearAll,
  });

  final MatchingState matching;
  final void Function(int source, int destination) addConnection;
  final void Function(int source) removeConnection;
  final void Function() clearAll;

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
      Store<AppState> store, int stateIndex) {
    return MatchingViewModel(
      matching: store.state.states[stateIndex] as MatchingState,
      addConnection: (source, destination) {
        store.dispatch(AddConnection(source, destination, stateIndex));
      },
      removeConnection: (int source) {
        store.dispatch(RemoveConnection(source, stateIndex));
      },
      clearAll: () {
        store.dispatch(RemoveAllConnections(stateIndex));
      },
    );
  }
}
