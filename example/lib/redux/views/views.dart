import 'package:built_collection/built_collection.dart';
import 'package:flutter_qa_example/matching_page.dart';
import 'package:flutter_qa_example/qa_page.dart';
import 'package:flutter_qa_example/redux/states.dart';
import 'package:redux/redux.dart';

class PagesViewModel {
  PagesViewModel(this.pages);

  BuiltList<Page> pages;

  static PagesViewModel fromStore(Store<AppState> store) {
    final pages = ListBuilder<Page>();

    for (int matchingIndex = 0;
        matchingIndex < store.state.matchingStates.length;
        matchingIndex++) {
      pages.add(Page(store.state.matchingStates[matchingIndex].title,
          (context) => MatchingPage(matchingIndex: matchingIndex)));
    }

    return PagesViewModel(pages.build());
  }
}
