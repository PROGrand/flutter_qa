import 'package:built_collection/built_collection.dart';
import 'package:flutter_qa_example/matching_page.dart';
import 'package:flutter_qa_example/qa_page.dart';
import 'package:flutter_qa_example/redux/states.dart';
import 'package:redux/redux.dart';

class PagesViewModel {
	BuiltList<Page> pages;

	PagesViewModel(this.pages);

	static PagesViewModel fromStore(Store<AppState> store) {
		int matchingIndex = 0;

		final pages = ListBuilder<Page>(<Page>[
			for (final item in store.state.matchingStates)
				Page((b) =>
				b
					..title = (item as MatchingState).title
					..builder = (context) =>
						MatchingPage(
							matchingIndex: matchingIndex++))
		]).build();

		return PagesViewModel(pages);
	}
}
