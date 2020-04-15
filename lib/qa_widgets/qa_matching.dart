library flutter_qa;

import 'dart:async';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:rect_getter/rect_getter.dart';

typedef MatchingBuilder = Widget Function(
    BuildContext context, bool query, int index);

class MatchingWidgetBuilder {
  final int queriesCount;
  final int answersCount;
  final MatchingBuilder builder;

  MatchingWidgetBuilder(
      {@required this.queriesCount,
      @required this.answersCount,
      @required this.builder});
}

class MatchingWidget extends StatefulWidget {
  static GlobalKey<_MatchingWidgetState> createGlobalKey() =>
      GlobalKey<_MatchingWidgetState>();

  final MatchingWidgetBuilder builder;

  MatchingWidget({Key key, @required this.builder}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _MatchingWidgetState(builder);
  }

  static _MatchingWidgetState of(BuildContext context) {
    assert(context != null);
    final state = context.findAncestorStateOfType<_MatchingWidgetState>();
    if (state != null) return state;
    throw FlutterError.fromParts(<DiagnosticsNode>[
      ErrorSummary(
          'MatchingWidget.of() called with a context that does not contain a MatchingWidget.'),
      ErrorDescription(
          'No MatchingWidget ancestor could be found starting from the context that was passed '
          'to MatchingWidget.of(). This can happen because you do not have a WidgetsApp or '
          'MaterialApp widget (those widgets introduce a MatchingWidget), or it can happen '
          'if the context you use comes from a widget above those widgets.'),
      context.describeElement('The context used was')
    ]);
  }
}

class _MatchingWidgetState extends State<MatchingWidget> {
  StreamController<_ConnectionLine> controller;
  final MatchingWidgetBuilder builder;

  _MatchingWidgetState(this.builder);

  GlobalKey<_LinesState> _linesKey = new GlobalKey<_LinesState>();
  final _rectKey = RectGetter.createGlobalKey();

  @override
  void initState() {
    super.initState();
    controller = StreamController<_ConnectionLine>();
  }

  @override
  void dispose() {
    controller.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => RectGetter(
        child: Stack(
          //overflow: Overflow.clip,
          children: <Widget>[
            _Boxes(controller: controller),
            SizedBox.shrink(
                child: IgnorePointer(
              child: _Lines(
                key: _linesKey,
                stream: controller.stream,
              ),
            )),
          ],
        ),
        key: _rectKey,
      );

  Map<int, _ConnectionLine> lines() => _linesKey?.currentState?._lines;

  void clear() {
    controller.add(_ConnectionLineClear());
  }
}

class _Boxes extends StatefulWidget {
  final StreamController<_ConnectionLine> controller;

  _Boxes({@required this.controller});

  @override
  _BoxesState createState() => _BoxesState();
}

class _BoxesState extends State<_Boxes> with TickerProviderStateMixin {
  @override
  Widget build(BuildContext context) => Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[_queries(), _answers()],
      );

  Widget _queries() => Padding(
      padding: EdgeInsets.all(16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: _buildQueries(),
      ));

  List<Widget> _buildQueries() {
    final builder = MatchingWidget.of(context).builder;
    return <Widget>[
      for (int n = 0; n < builder.queriesCount; n++)
        Padding(
            padding: EdgeInsets.all(16),
            child: _QueryWidget(
              index: n,
              controller: widget.controller,
              child: builder.builder(context, true, n),
            ))
    ];
  }

  Widget _answers() => Padding(
      padding: EdgeInsets.all(16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: _buildAnswers(),
      ));

  List<Widget> _buildAnswers() {
    final builder = MatchingWidget.of(context).builder;
    return <Widget>[
      for (int n = 0; n < builder.answersCount; n++)
        Padding(
          padding: EdgeInsets.all(16),
          child: _AnswerWidget(
              index: n,
              builder: (context) => builder.builder(context, false, n)),
        )
    ];
  }
}

class _QueryWidget extends StatefulWidget {
  final int _index;

  _QueryWidget(
      {Key key,
      @required int index,
      @required StreamController<_ConnectionLine> controller,
      @required Widget child})
      : _index = index,
        _controller = controller,
        _child = child,
        super(key: key);

  final StreamController<_ConnectionLine> _controller;
  final Widget _child;

  @override
  State<StatefulWidget> createState() {
    return _QueryWidgetState();
  }
}

class _QueryWidgetState extends State<_QueryWidget> {
  var _rectKey = RectGetter.createGlobalKey();
  Offset _lastPosition = Offset(0, 0);

  @override
  Widget build(BuildContext context) {
    return RectGetter(
      key: _rectKey,
      child: _buildGestureDetector(),
    );
  }

  Widget _buildGestureDetector() {
//    return GestureDetector(
//      onPanUpdate: _onPanUpdate,
//      onPanEnd: _onPanEnd,
//      child: widget._child,
//    );

    return RawGestureDetector(gestures: <Type, GestureRecognizerFactory>{
      CustomPanGestureRecognizer:
          GestureRecognizerFactoryWithHandlers<CustomPanGestureRecognizer>(
        () => CustomPanGestureRecognizer(
          onPanDown: _onPanDown,
          onPanUpdate: _onPanUpdate,
          onPanEnd: _onPanEnd,
        ),
        (CustomPanGestureRecognizer instance) {},
      ),
    }, child: widget._child);
  }

  bool _onPanDown(Offset position) {
    RenderBox renderBox = context.findRenderObject();
    return renderBox.globalToLocal(position) != null;
  }

  void _onPanUpdate(Offset position) {
    Rect rectQuery = RectGetter.getRectFromKey(_rectKey);
    Rect rectWidget =
        RectGetter.getRectFromKey(MatchingWidget.of(context)._rectKey);
    var line = _ConnectionLineActive();
    line._start = rectQuery.centerRight - rectWidget.topLeft;
    _lastPosition = position - rectWidget.topLeft;
    line._end = _lastPosition;
    widget._controller.add(line);
  }

  void _onPanEnd(Offset offset) {
    Rect rectQuery = RectGetter.getRectFromKey(_rectKey);

    Rect rectWidget =
    RectGetter.getRectFromKey(MatchingWidget.of(context)._rectKey);

    final HitTestResult result = HitTestResult();
    WidgetsBinding.instance.hitTest(result, _lastPosition + rectWidget.topLeft);

    var found = false;

    for (HitTestEntry entry in result.path) {
      if (entry.target is RenderMetaData) {
        final RenderMetaData renderMetaData = entry.target;
        if (renderMetaData.metaData is _AnswerWidgetState) {
          var metaData = renderMetaData.metaData as _AnswerWidgetState;
          final index = metaData.index;

          var line = _ConnectionLineCreated();
          line._index = widget._index;
          line._start = rectQuery.centerRight - rectWidget.topLeft;
          Rect rectAnswer = RectGetter.getRectFromKey(metaData.render_key);
          line._end = rectAnswer.centerLeft - rectWidget.topLeft;

          widget._controller.add(line);
          found = true;
        }
      }
    }

    if (!found) {
      var line = _ConnectionLineRemoved();
      line._index = widget._index;
      widget._controller.add(line);
    }
  }
}

typedef _AnswerWidgetBuilder = Widget Function(BuildContext context);

class _AnswerWidget extends StatefulWidget {
  final _AnswerWidgetBuilder _builder;

  final int _index;

  _AnswerWidget(
      {Key key, @required int index, @required _AnswerWidgetBuilder builder})
      : _index = index,
        _builder = builder,
        super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _AnswerWidgetState();
  }
}

class _AnswerWidgetState extends State<_AnswerWidget> {
  int get index => widget._index;

  GlobalKey render_key = RectGetter.createGlobalKey();

  @override
  Widget build(BuildContext context) {
    return MetaData(
        metaData: this,
        behavior: HitTestBehavior.translucent,
        child: RectGetter(
          key: render_key,
          child: widget._builder(context),
        ));
  }
}

class _Lines extends StatefulWidget {
  final Stream<_ConnectionLine> stream;

  _Lines({@required GlobalKey<_LinesState> key, @required this.stream})
      : super(key: key);

  @override
  createState() => _LinesState();
}

class _LinesState extends State<_Lines> {
  Map<int, _ConnectionLine> _lines = Map();

  @override
  build(_) => StreamBuilder<_ConnectionLine>(
      stream: widget.stream,
      builder: (BuildContext context, AsyncSnapshot<_ConnectionLine> snapshot) {
        if (snapshot.connectionState == ConnectionState.active) {
          final activeLink =
              (snapshot.data is _ConnectionLineActive) ? snapshot.data : null;

          if (snapshot.data is _ConnectionLineCreated) {
            final line = snapshot.data as _ConnectionLineCreated;
            _lines[line._index] = line;
          } else if (snapshot.data is _ConnectionLineRemoved) {
            _lines.remove((snapshot.data as _ConnectionLineRemoved)._index);
          } else if (snapshot.data is _ConnectionLineClear) {
            _lines.clear();
          }

          return CustomPaint(
            size: Size.zero,
            painter: LinesPainter(_lines, activeLink),
          );
        } else
          return Container();
      });

  void clear() {
    setState(() {
      _lines.clear();
    });
  }
}

abstract class _ConnectionLine {
  Offset _start;
  Offset _end;
}

class _ConnectionLineActive extends _ConnectionLine {}

class _ConnectionLineCreated extends _ConnectionLine {
  int _index;
}

class _ConnectionLineRemoved extends _ConnectionLine {
  int _index;
}

class _ConnectionLineClear extends _ConnectionLine {}

class LinesPainter extends CustomPainter {
  final Map<int, _ConnectionLine> _lines;
  _ConnectionLine _activeLink;

  LinesPainter(this._lines, this._activeLink);

  @override
  void paint(Canvas canvas, Size size) {
    _drawLine(
        canvas,
        _activeLink,
        Paint()
          ..strokeWidth = 4
          ..color = Colors.redAccent);

    for (_ConnectionLine line in _lines.values) {
      _drawLine(
          canvas,
          line,
          Paint()
            ..strokeWidth = 4
            ..color = Colors.blueAccent);
    }
  }

  void _drawLine(Canvas canvas, _ConnectionLine line, Paint paint) {
    if (null != line && null != line._start) {
      canvas.drawCircle(line._start, 8, paint);

      if (null != line._end) {
        canvas.drawLine(line._start, line._end, paint);
        canvas.drawCircle(line._end, 8, paint);
      }
    }
  }

  @override
  bool shouldRepaint(LinesPainter oldDelegate) {
    return oldDelegate._lines != _lines ||
        oldDelegate._activeLink != _activeLink;
  }
}

class CustomPanGestureRecognizer extends OneSequenceGestureRecognizer {
  final bool Function(Offset offset) onPanDown;
  final Function(Offset offset) onPanUpdate;
  final Function(Offset offset) onPanEnd;

  CustomPanGestureRecognizer({
    @required this.onPanDown,
    @required this.onPanUpdate,
    @required this.onPanEnd,
  });

  @override
  void addPointer(PointerEvent event) {
    if (onPanDown(event.position)) {
      startTrackingPointer(event.pointer);
      resolve(GestureDisposition.accepted);
    } else {
      stopTrackingPointer(event.pointer);
    }
  }

  @override
  void handleEvent(PointerEvent event) {
    if (event is PointerMoveEvent) {
      onPanUpdate(event.position);
    }
    if (event is PointerUpEvent) {
      onPanEnd(event.position);
      stopTrackingPointer(event.pointer);
    }
  }

  @override
  String get debugDescription => 'customPan';

  @override
  void didStopTrackingLastPointer(int pointer) {}
}
