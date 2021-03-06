import 'package:built_collection/built_collection.dart';
import 'package:flutter_qa_example_redux/matching_page.dart';
import 'package:flutter_qa_example_redux/ordering_page.dart';
import 'package:flutter_qa_example_redux/qa_page.dart';
import 'package:flutter_qa_example_redux/redux/states.dart';
import 'package:redux/redux.dart';

class PagesViewModel {
  PagesViewModel(this.pages);

  BuiltList<QAPage> pages;

  static PagesViewModel fromStore(Store<AppState> store) {
    final pages = ListBuilder<QAPage>();

    for (int qaIndex = 0; qaIndex < store.state.states.length; qaIndex++) {
      var state = store.state.states[qaIndex];
      pages.add(QAPage(
          state.title,
          (context) => (state is MatchingState)
              ? MatchingPage(qaIndex: qaIndex)
              : OrderingPage(qaIndex: qaIndex)));
    }

    return PagesViewModel(pages.build());
  }
}
