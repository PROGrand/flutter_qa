import 'package:built_collection/built_collection.dart';
import 'package:flutter_qa_example/matching_page.dart';
import 'package:flutter_qa_example/ordering_page.dart';
import 'package:flutter_qa_example/qa_page.dart';
import 'package:flutter_qa_example/redux/states.dart';
import 'package:redux/redux.dart';

class PagesViewModel {
  PagesViewModel(this.pages);

  BuiltList<Page> pages;

  static PagesViewModel fromStore(Store<AppState> store) {
    final pages = ListBuilder<Page>();

    for (int qaIndex = 0; qaIndex < store.state.states.length; qaIndex++) {
      var state = store.state.states[qaIndex];
      pages.add(Page(
          state.title,
          (context) => (state is MatchingState)
              ? MatchingPage(qaIndex: qaIndex)
              : OrderingPage(qaIndex: qaIndex)));
    }

    return PagesViewModel(pages.build());
  }
}
