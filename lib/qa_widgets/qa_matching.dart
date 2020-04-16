library flutter_qa;

import 'dart:async';

import 'package:built_collection/built_collection.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:rect_getter/rect_getter.dart';

class MatchingWidgetBuilder {
  final int sourcesCount;
  final int destinationsCount;
  final BuiltMap<int, int> connections;
  final Function onClearAll;
  final Function(int sourceIndex, int destinationIndex) onAddConnection;
  final Function(int sourceIndex) onRemoveConnection;
  final Widget Function(BuildContext context, bool query, int index) build;
  final Color activeColor;
  final Color connectedColor;

  MatchingWidgetBuilder(
      {Color activeColor,
      Color connectedColor,
      @required this.onClearAll,
      @required this.onAddConnection,
      @required this.onRemoveConnection,
      @required this.sourcesCount,
      @required this.destinationsCount,
      @required this.connections,
      @required this.build})
      : this.activeColor = activeColor ?? Color.fromARGB(255, 255, 0, 0),
        this.connectedColor = connectedColor ?? Color.fromARGB(255, 0, 0, 255);
}

class MatchingWidget extends StatefulWidget {
  static GlobalKey<_MatchingWidgetState> createGlobalKey() =>
      GlobalKey<_MatchingWidgetState>();

  final MatchingWidgetBuilder builder;

  MatchingWidget({Key key, @required this.builder}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _MatchingWidgetState();
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

  _MatchingWidgetState();

  final sourceRects = Map<int, Rect>();
  final destinationRects = Map<int, Rect>();
  final _linesKey = new GlobalKey<_LinesState>();
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
  Widget build(BuildContext context) {
    sourceRects.clear();
    destinationRects.clear();

    final ret = RectGetter(
      child: Stack(
        //overflow: Overflow.clip,
        children: <Widget>[
          _Boxes(controller: controller),
          SizedBox.shrink(
              child: IgnorePointer(
            child: _Lines(
              key: _linesKey,
              stream: controller.stream,
              activeColor: widget.builder.activeColor,
              connectedColor: widget.builder.connectedColor,
            ),
          )),
        ],
      ),
      key: _rectKey,
    );

    return ret;
  }

  get lines => _linesKey?.currentState?._lines;

  void clear() {
    controller.add(_ConnectionLineClear());

    if (null != widget.builder.onClearAll) {
      widget.builder.onClearAll();
    }
  }

  void addRect(
      {@required bool isSource, @required int index, @required Rect rect}) {
    final rects = isSource ? sourceRects : destinationRects;
    rects[index] = rect;

    if (sourceRects.length == widget.builder.sourcesCount &&
        destinationRects.length == widget.builder.destinationsCount) {
      _initLines();
    }
  }

  _initLines() async {
    print('INIT LINES: ${widget.builder.connections.entries.length}');

    final offset = RectGetter.getRectFromKey(_rectKey).topLeft;

    final list = [
      for (final connection in widget.builder.connections.entries)
        _ConnectionLineCreated(
            sourceRects[connection.key].centerRight - offset,
            destinationRects[connection.value].centerLeft - offset,
            connection.key)
    ];

    controller.add(_ConnectionInitLines(list));
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
    final builder = MatchingWidget.of(context).widget.builder;
    return <Widget>[
      for (int n = 0; n < builder.sourcesCount; n++)
        Padding(
            padding: EdgeInsets.all(16),
            child: _QueryWidget(
              index: n,
              controller: widget.controller,
              child: builder.build(context, true, n),
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
    final builder = MatchingWidget.of(context).widget.builder;
    return <Widget>[
      for (int n = 0; n < builder.destinationsCount; n++)
        Padding(
          padding: EdgeInsets.all(16),
          child: _AnswerWidget(
              index: n, builder: (context) => builder.build(context, false, n)),
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
  final _rectKey = RectGetter.createGlobalKey();
  var _lastPosition = Offset(0, 0);

  @override
  Widget build(BuildContext context) {
    final ret = RectGetter(
      key: _rectKey,
      child: _buildGestureDetector(),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final rect = RectGetter.getRectFromKey(_rectKey);
      MatchingWidget.of(context)
          .addRect(isSource: true, index: widget._index, rect: rect);
    });

    return ret;
  }

  Widget _buildGestureDetector() {
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
    final renderBox = context.findRenderObject() as RenderBox;
    assert(null != renderBox);
    return null != renderBox?.globalToLocal(position);
  }

  void _onPanUpdate(Offset position) {
    final rectQuery = RectGetter.getRectFromKey(_rectKey);
    final rectWidget =
        RectGetter.getRectFromKey(MatchingWidget.of(context)._rectKey);
    _lastPosition = position - rectWidget.topLeft;
    final line = _ConnectionLineActive(
        rectQuery.centerRight - rectWidget.topLeft, _lastPosition);
    widget._controller.add(line);
  }

  void _onPanEnd(Offset offset) {
    final rectQuery = RectGetter.getRectFromKey(_rectKey);
    final matchingWidget = MatchingWidget.of(context);
    final rectWidget = RectGetter.getRectFromKey(matchingWidget._rectKey);

    final result = HitTestResult();
    WidgetsBinding.instance.hitTest(result, _lastPosition + rectWidget.topLeft);

    var found = false;

    final sourceIndex = widget._index;

    for (HitTestEntry entry in result.path) {
      if (entry.target is RenderMetaData) {
        final RenderMetaData renderMetaData = entry.target;
        if (renderMetaData.metaData is _AnswerWidgetState) {
          var metaData = renderMetaData.metaData as _AnswerWidgetState;
          final destinationIndex = metaData.index;

          final rectAnswer = RectGetter.getRectFromKey(metaData._rectKey);
          final line = _ConnectionLineCreated(
              rectQuery.centerRight - rectWidget.topLeft,
              rectAnswer.centerLeft - rectWidget.topLeft,
              sourceIndex);

          widget._controller.add(line);

          if (null != matchingWidget.widget.builder.onAddConnection) {
            matchingWidget.widget.builder
                .onAddConnection(sourceIndex, destinationIndex);
          }

          found = true;
          break;
        }
      }
    }

    if (!found) {
      widget._controller.add(_ConnectionLineRemoved(sourceIndex));

      if (null != matchingWidget.widget.builder.onRemoveConnection) {
        matchingWidget.widget.builder.onRemoveConnection(sourceIndex);
      }
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
  get index => widget._index;

  final _rectKey = RectGetter.createGlobalKey();

  @override
  Widget build(BuildContext context) {
    final ret = MetaData(
        metaData: this,
        behavior: HitTestBehavior.translucent,
        child: RectGetter(
          key: _rectKey,
          child: widget._builder(context),
        ));

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final rect = RectGetter.getRectFromKey(_rectKey);
      MatchingWidget.of(context)
          .addRect(isSource: false, index: widget._index, rect: rect);
    });

    return ret;
  }
}

class _Lines extends StatefulWidget {
  final Stream<_ConnectionLine> stream;
  final Color activeColor;
  final Color connectedColor;

  _Lines(
      {@required GlobalKey<_LinesState> key,
      @required this.stream,
      @required this.activeColor,
      @required this.connectedColor})
      : super(key: key);

  @override
  createState() => _LinesState();
}

class _LinesState extends State<_Lines> {
  final _lines = Map<int, _ConnectionLine>();

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
          } else if (snapshot.data is _ConnectionInitLines) {
            for (final line in (snapshot.data as _ConnectionInitLines)._lines) {
              _lines[line._index] = line;
            }
          } else if (snapshot.data is _ConnectionLineRemoved) {
            _lines.remove((snapshot.data as _ConnectionLineRemoved)._index);
          } else if (snapshot.data is _ConnectionLineClear) {
            _lines.clear();
          }

          return CustomPaint(
            size: Size.zero,
            painter: LinesPainter(
                _lines, activeLink, widget.activeColor, widget.connectedColor),
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
  final Offset _start;
  final Offset _end;

  _ConnectionLine(this._start, this._end);
}

class _ConnectionLineActive extends _ConnectionLine {
  _ConnectionLineActive(Offset start, Offset end) : super(start, end);
}

class _ConnectionLineCreated extends _ConnectionLine {
  final int _index;

  _ConnectionLineCreated(Offset start, Offset end, this._index)
      : super(start, end);
}

class _ConnectionInitLines extends _ConnectionLine {
  final Iterable<_ConnectionLineCreated> _lines;

  _ConnectionInitLines(this._lines) : super(null, null);
}

class _ConnectionLineRemoved extends _ConnectionLine {
  final int _index;

  _ConnectionLineRemoved(this._index) : super(null, null);
}

class _ConnectionLineClear extends _ConnectionLine {
  _ConnectionLineClear() : super(null, null);
}

class LinesPainter extends CustomPainter {
  final Map<int, _ConnectionLine> _lines;
  final _ConnectionLine _activeLink;
  final Color activeColor;
  final Color connectedColor;

  LinesPainter(
      this._lines, this._activeLink, this.activeColor, this.connectedColor);

  @override
  void paint(Canvas canvas, Size size) {
    _drawLine(
        canvas,
        _activeLink,
        Paint()
          ..strokeWidth = 4
          ..color = activeColor);

    for (_ConnectionLine line in _lines.values) {
      _drawLine(
          canvas,
          line,
          Paint()
            ..strokeWidth = 4
            ..color = connectedColor);
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
