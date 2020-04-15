
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';


//usage: flutter pub run build_runner build
part 'states.g.dart';

abstract class MatchingState implements Built<MatchingState, MatchingStateBuilder> {
	BuiltList<String> get queries;
	BuiltList<String> get answers;
	BuiltMap<int, int> get connections;

	MatchingState._();
	factory MatchingState([void Function(MatchingStateBuilder) updates]) = _$MatchingState;
}

abstract class MatchingStateBuilder implements Builder<MatchingState, MatchingStateBuilder> {

	ListBuilder<String> queries = ListBuilder<String>();
	ListBuilder<String> answers = ListBuilder<String>();
	MapBuilder<int, int> connections = MapBuilder<int, int>();

	factory MatchingStateBuilder() = _$MatchingStateBuilder;
	MatchingStateBuilder._();
}

abstract class AppState implements Built<AppState, AppStateBuilder> {
	BuiltList<MatchingState> get matchingStates;

	AppState._();
	factory AppState([void Function(AppStateBuilder) updates]) = _$AppState;
}

abstract class AppStateBuilder implements Builder<AppState, AppStateBuilder> {

	ListBuilder<MatchingState> matchingStates = ListBuilder<MatchingState>(<MatchingState>[]);

	factory AppStateBuilder() = _$AppStateBuilder;
	AppStateBuilder._();
}