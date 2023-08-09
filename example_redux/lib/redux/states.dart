import 'dart:ui';

import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';

part 'states.g.dart';

abstract class QABaseState {
  String get title;
}

abstract class MatchingState
    with QABaseState
    implements Built<MatchingState, MatchingStateBuilder> {
  MatchingState._();

  factory MatchingState([void Function(MatchingStateBuilder) updates]) =
      _$MatchingState;

  BuiltList<String> get sources;

  BuiltList<String> get destinations;

  BuiltMap<int, int> get connections;
}

abstract class OrderingState
    with QABaseState
    implements Built<OrderingState, OrderingStateBuilder> {
  OrderingState._();

  factory OrderingState([void Function(OrderingStateBuilder) updates]) =
      _$OrderingState;

  BuiltList<OrderableItem> get items;

  BuiltList<int> get ordered;
}

abstract class OrderableItem
    implements Built<OrderableItem, OrderableItemBuilder> {
  OrderableItem._();

  factory OrderableItem([void Function(OrderableItemBuilder) updates]) =
      _$OrderableItem;

  String get title;

  Color get color;
}

abstract class AppState implements Built<AppState, AppStateBuilder> {
  AppState._();

  factory AppState([void Function(AppStateBuilder) updates]) = _$AppState;

  BuiltList<QABaseState> get states;
}
