import 'package:flutter/material.dart';

import 'MatchingPage.dart';

main() {
  runApp(MaterialApp(
    home: DefaultTabController(
      length: pages.length,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Tabbed AppBar'),
          bottom: TabBar(
            isScrollable: true,
            tabs: pages.map((Page page) {
              return Tab(
                text: page.title,
              );
            }).toList(),
          ),
        ),
        body: TabBarView(
          children: pages.map((Page page) {
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: page.builder(),
            );
          }).toList(),
        ),
      ),
    ),
  ));
}

typedef QABuilder = Widget Function();

class Page {
  String title;
  QABuilder builder;

  Page(this.title, this.builder);
}

List<Page> pages = <Page>[
  Page("Matching 1", () => MatchingPage()),
  Page("Matching 2", () => MatchingPage())
];

class App extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return AppState();
  }
}

class AppState extends State<App> with TickerProviderStateMixin {
  TabController controller;

  @override
  void initState() {
    super.initState();

    controller = TabController(vsync: this, length: 2);
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return SafeArea(
            child: Scaffold(
              appBar: TabBar(
                      tabs: <Widget>[Text('Matching'), Text('Order')],
                      controller: controller),
              body: TabBarView(
                children: <Widget>[MatchingPage(), MatchingPage()],
              ),
            ));
  }
}

//////////////////////////////////////////
