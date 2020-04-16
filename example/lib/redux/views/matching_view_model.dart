//flutter pub run build_runner build.
import 'package:built_value/built_value.dart';
import 'package:redux/redux.dart';

import '../actions.dart';
import '../states.dart';

part 'matching_view_model.g.dart';

abstract class MatchingViewModel
    implements Built<MatchingViewModel, MatchingViewModelBuilder> {
  MatchingState get matching;

  Function(int source, int destination) get addConnection;

  Function(int source) get removeConnection;

  Function get clearAll;

  MatchingViewModel._();

  factory MatchingViewModel([void Function(MatchingViewModelBuilder) updates]) =
      _$MatchingViewModel;

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    final dynamic _$dynamicOther = other;
    return other is MatchingViewModel && matching == other.matching;
  }

  @override
  int get hashCode {
    return $jf($jc(0, matching.hashCode));
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper('MatchingViewModel')
          ..add('matching', matching))
        .toString();
  }

  static MatchingViewModel fromStore(
          Store<AppState> store, int matchingIndex) =>
      MatchingViewModel((b) => b
        ..matching.replace(store.state.matchingStates[matchingIndex])
        ..addConnection = (source, destination) {
          store.dispatch(AddConnection(source, destination, matchingIndex));
        }
        ..removeConnection = (int source) {
          store.dispatch(RemoveConnection(source, matchingIndex));
        }
        ..clearAll = () {
          store.dispatch(RemoveAllConnections(matchingIndex));
        });
}
