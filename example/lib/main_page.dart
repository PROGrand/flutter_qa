import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_qa_example/matching_page.dart';
import 'package:flutter_qa_example/ordering_page.dart';

class MainPage extends StatelessWidget {
  const MainPage({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) => DefaultTabController(
      length: 2,
      child: CustomScrollView(
        slivers: <Widget>[_appBar(context), _tabs(context)],
      ));

  Widget _appBar(BuildContext context) {
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
                child: TabBar(isScrollable: true, tabs: [
                  Tab(
                    text: 'Ordering',
                  ),
                  Tab(text: 'Matching')
                ]),
              )
            ],
          ),
        ));
  }

  Widget _tabs(BuildContext context) => SliverToBoxAdapter(
      child: Container(
          height: 640,
          color: Colors.white,
          child: TabBarView(children: <Widget>[
            OrderingPage(),
            MatchingPage(),
          ])));
}
