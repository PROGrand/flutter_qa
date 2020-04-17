import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
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
        converter: (store) => PagesViewModel.fromStore(store), builder: _build);
  }

  Widget _build(BuildContext context, PagesViewModel vm) =>
      DefaultTabController(
          length: vm.pages.length,
          child: CustomScrollView(
            slivers: <Widget>[_appBar(context, vm), _tabs(vm, context)],
          ));

  Widget _appBar(BuildContext context, PagesViewModel vm) {
    return SliverAppBar(
      //floating: false,
      stretch: true,
      onStretchTrigger: () {
        return;
      },
      expandedHeight:
          MediaQuery.of(context).orientation == Orientation.landscape
              ? 80
              : 80.0,

      title: const Text('Exam'),
      flexibleSpace: FlexibleSpaceBar(
        stretchModes: <StretchMode>[
          StretchMode.zoomBackground,
          StretchMode.blurBackground,
          StretchMode.fadeTitle,
        ],
        centerTitle: true,
        background: Stack(
          fit: StackFit.expand,
          children: [
//                  Image(
//                          image: CachedNetworkImageProvider(
//                                  widget.trainer.image),
//                          fit: BoxFit.cover,
//                  ),
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment(0.0, 0.5),
                  end: Alignment(0.0, 0.0),
                  colors: <Color>[
                    Color(0x60000000),
                    Color(0x00000000),
                  ],
                ),
              ),
            ),
            Positioned(
                bottom: 0,
                child: TabBar(
                  isScrollable: true,
                  tabs: vm.pages.map((Page page) {
                    return Tab(
                      text: page.title,
                    );
                  }).toList(),
                ))
          ],
        ),
      ),
    );
  }

  Widget _tabs(PagesViewModel vm, BuildContext context) => SliverToBoxAdapter(
      child: Container(
          height: 640,
          color: Colors.white,
          child: TabBarView(children: <Widget>[
            for (int n = 0; n < vm.pages.length; n++)
              vm.pages[n].builder(context),
          ])));
}
