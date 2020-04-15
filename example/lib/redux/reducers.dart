import 'package:flutter_qa_example/redux/states.dart';

import 'actions.dart';

MatchingState matchReducer(MatchingState state, dynamic action) {
  if (action is AddConnection) {
    return state
        .rebuild((b) => b..connections[action.queryIndex] = action.answerIndex);
  } else if (action is RemoveConnection) {
    return state.rebuild((b) => b..connections.remove(action.queryIndex));
  } else if (action is RemoveAllConnections) {
    return state.rebuild((b) => b..connections.clear());
  } else {
    return state;
  }
}

AppState appReducer(AppState state, dynamic action) {
  if (action is MatchingInplaceAction) {
    return state.rebuild((b) {
      for (int n = 0; n < state.matchingStates.length; n++) {
        final index = action.matchingIndex;
        final m = state.matchingStates[n];
        b..matchingStates.add(n == index ? matchReducer(m, action) : m);
      }
    });
  } else {
    return state;
  }
}
