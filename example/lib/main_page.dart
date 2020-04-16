import 'package:flutter/material.dart';
import 'package:flutter_qa_example/redux/states.dart';
import 'package:flutter_redux/flutter_redux.dart';

import 'qa_page.dart';
import 'redux/views/views.dart';

class MainPage extends StatelessWidget {
  const MainPage({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, PagesViewModel>(
        converter: (store) => PagesViewModel.fromStore(store),
        builder: _build);
  }

  Widget _build(BuildContext context, PagesViewModel vm) =>
      DefaultTabController(
        length: vm.pages.length,
        child: Scaffold(
          appBar: AppBar(
            title: const Text('Exam'),
            bottom: TabBar(
              isScrollable: true,
              tabs: vm.pages.map((Page page) {
                return Tab(
                  text: page.title,
                );
              }).toList(),
            ),
          ),
          body: TabBarView(
            children: vm.pages.map((Page page) {
              return Padding(
                padding: const EdgeInsets.all(16.0),
                child: page.builder(context),
              );
            }).toList(),
          ),
        ),
      );
}
