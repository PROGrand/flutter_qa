import 'package:redux/redux.dart';

import '../actions.dart';
import '../states.dart';

class OrderingViewModel {
  OrderingViewModel({
    required this.ordering,
    required this.order,
  });

  final OrderingState ordering;
  final void Function(List<int>) order;

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is OrderingViewModel && ordering == other.ordering;
  }

  @override
  int get hashCode {
    return ordering.hashCode;
  }

  @override
  String toString() {
    return ordering.toString();
  }

  static OrderingViewModel fromStore(
      Store<AppState> store, int stateIndex) {
    return OrderingViewModel(
      ordering: store.state.states[stateIndex] as OrderingState,
      order: (List<int> order) {
        store.dispatch(Order(order, stateIndex));
      },
    );
  }
}
