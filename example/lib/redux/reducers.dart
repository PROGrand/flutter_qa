import 'package:flutter_qa_example/redux/states.dart';

import 'actions.dart';

QABaseState qaReducer(QABaseState state, dynamic action) {
  if (action is AddConnection) {
    return (state as MatchingState).rebuild(
        (b) => b..connections[action.sourceIndex] = action.destinationIndex);
  } else if (action is RemoveConnection) {
    return (state as MatchingState).rebuild((b) => b..connections.remove(action.sourceIndex));
  } else if (action is RemoveAllConnections) {
    return (state as MatchingState).rebuild((b) => b..connections.clear());
  } else if (action is Order) {
    return (state as OrderingState).rebuild((b) => b..ordered.replace(action.order));
  } else {
    return state;
  }
}

AppState appReducer(AppState state, dynamic action) {
  if (action is QAInplaceAction) {
    return state.rebuild((b) {
      b.states.clear();

      for (int n = 0; n < state.states.length; n++) {
        final index = action.index;
        final m = state.states[n];

        b.states.add(n == index ? qaReducer(m, action) : m);
      }
    });
  } else {
    return state;
  }
}
