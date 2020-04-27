library flutter_qa;

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:rect_getter/rect_getter.dart';

/// Parameters used to create [MatchingWidget].
class MatchingWidgetBuilder {
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

  /// Count of source (questions) items.
  final int sourcesCount;

  /// Count of destination (answers) items.
  final int destinationsCount;

  /// Map of connections from source to destinations items.
  ///
  /// Zero based.
  final Map<int, int> connections;

  /// Callback when new connection is created.
  final Function(int sourceIndex, int destinationIndex) onAddConnection;

  /// Callback when connection is removed.
  final Function(int sourceIndex) onRemoveConnection;

  /// Callback when all connections are removed.
  final Function onClearAll;

  /// Constructs source or destination widgets.
  final Widget Function(BuildContext context, bool isSource, int index) build;

  /// Color of line being constructed.
  final Color activeColor;

  /// Color of constructed line.
  final Color connectedColor;
}

/// Matching widget.
///
/// Allows to connect sources and destinations.
class MatchingWidget extends StatefulWidget {
  MatchingWidget({Key key, @required MatchingWidgetBuilder builder})
      : this._builder = builder,
        super(key: key);

  /// Creates global key allowing to use of [MatchingWidget.of]
  static GlobalKey<MatchingWidgetState> createGlobalKey() =>
      GlobalKey<MatchingWidgetState>();

  final MatchingWidgetBuilder _builder;

  @override
  State<StatefulWidget> createState() {
    return MatchingWidgetState();
  }

  /// Allows to get current MatchingWidget in context.
  static MatchingWidgetState of(BuildContext context) {
    try {
      final state = context.findAncestorStateOfType<MatchingWidgetState>();
      if (state != null) return state;
    } catch (e) {}

    return null;
  }
}

class MatchingWidgetState extends State<MatchingWidget> {
  StreamController<_ConnectionLine> _controller;

  final _sourceRects = Map<int, Rect>();
  final _destinationRects = Map<int, Rect>();
  final _linesKey = GlobalKey<_LinesState>();
  final _rectKey = RectGetter.createGlobalKey();

  @override
  void initState() {
    super.initState();
    _controller = StreamController<_ConnectionLine>();
  }

  @override
  void dispose() {
    _controller.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _sourceRects.clear();
    _destinationRects.clear();

    final ret = LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) =>
            RectGetter(
              child: Stack(
                //overflow: Overflow.clip,
                children: <Widget>[
                  _Boxes(controller: _controller),
                  SizedBox.shrink(
                      child: IgnorePointer(
                    child: _Lines(
                      key: _linesKey,
                      stream: _controller.stream,
                      activeColor: widget._builder.activeColor,
                      connectedColor: widget._builder.connectedColor,
                    ),
                  )),
                ],
              ),
              key: _rectKey,
            ));

    return ret;
  }

  //get lines => _linesKey?.currentState?._lines;

  /// Clears connections.
  void clear() {
    _controller.add(_ConnectionLineClear());

    if (null != widget._builder.onClearAll) {
      widget._builder.onClearAll();
    }
  }

  void _addRect(
      {@required bool isSource, @required int index, @required Rect rect}) {
    final rects = isSource ? _sourceRects : _destinationRects;
    rects[index] = rect;

    if (_sourceRects.length == widget._builder.sourcesCount &&
        _destinationRects.length == widget._builder.destinationsCount) {
      _initLines();
    }
  }

  Future<void> _initLines() async {
    final offset = RectGetter.getRectFromKey(_rectKey).topLeft;

    final list = [
      for (final connection in widget._builder.connections.entries)
        _ConnectionLineCreated(
            _sourceRects[connection.key].centerRight - offset,
            _destinationRects[connection.value].centerLeft - offset,
            connection.key)
    ];

    _controller.add(_ConnectionInitLines(list));
  }
}

class _Boxes extends StatefulWidget {
  _Boxes({@required this.controller});

  final StreamController<_ConnectionLine> controller;

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
    var ret = <Widget>[];

    final matchingState = MatchingWidget.of(context);
    if (null != matchingState) {
      final builder = matchingState.widget._builder;
      ret = <Widget>[
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

    return ret;
  }

  Widget _answers() => Padding(
      padding: EdgeInsets.all(16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: _buildAnswers(),
      ));

  List<Widget> _buildAnswers() {
    var ret = <Widget>[];

    final matchingState = MatchingWidget.of(context);

    if (null != matchingState) {
      final builder = matchingState.widget._builder;
      ret = <Widget>[
        for (int n = 0; n < builder.destinationsCount; n++)
          Padding(
            padding: EdgeInsets.all(16),
            child: _AnswerWidget(
                index: n,
                builder: (context) => builder.build(context, false, n)),
          )
      ];
    }

    return ret;
  }
}

class _QueryWidget extends StatefulWidget {
  _QueryWidget(
      {Key key,
      @required int index,
      @required StreamController<_ConnectionLine> controller,
      @required Widget child})
      : _index = index,
        _controller = controller,
        _child = child,
        super(key: key);

  final int _index;

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

  bool _inited;

  @override
  void initState() {
    super.initState();
    _inited = true;
  }

  @override
  void dispose() {
    _inited = false;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ret = RectGetter(
      key: _rectKey,
      child: _buildGestureDetector(),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_inited) {
        final rect = RectGetter.getRectFromKey(_rectKey);
        MatchingWidget.of(context)
            ?._addRect(isSource: true, index: widget._index, rect: rect);
      }
    });

    return ret;
  }

  Widget _buildGestureDetector() {
    return RawGestureDetector(gestures: <Type, GestureRecognizerFactory>{
      _CustomPanGestureRecognizer:
          GestureRecognizerFactoryWithHandlers<_CustomPanGestureRecognizer>(
        () => _CustomPanGestureRecognizer(
          onPanDown: _onPanDown,
          onPanUpdate: _onPanUpdate,
          onPanEnd: _onPanEnd,
        ),
        (_CustomPanGestureRecognizer instance) {},
      ),
    }, child: widget._child);
  }

  bool _onPanDown(Offset position) {
    final renderBox = context.findRenderObject() as RenderBox;
    return null != renderBox?.globalToLocal(position);
  }

  void _onPanUpdate(Offset position) {
    final matchingState = MatchingWidget.of(context);
    if (null == matchingState) {
      return;
    }

    final rectQuery = RectGetter.getRectFromKey(_rectKey);

    final rectWidget = RectGetter.getRectFromKey(matchingState._rectKey);
    _lastPosition = position - rectWidget.topLeft;
    final line = _ConnectionLineActive(
        rectQuery.centerRight - rectWidget.topLeft, _lastPosition);
    widget._controller.add(line);
  }

  void _onPanEnd(Offset offset) {
    final matchingState = MatchingWidget.of(context);
    if (null == matchingState) {
      return;
    }
    final rectQuery = RectGetter.getRectFromKey(_rectKey);
    final rectWidget = RectGetter.getRectFromKey(matchingState._rectKey);

    final result = HitTestResult();
    WidgetsBinding.instance.hitTest(result, _lastPosition + rectWidget.topLeft);

    var found = false;

    final sourceIndex = widget._index;

    for (HitTestEntry entry in result.path) {
      if (entry.target is RenderMetaData) {
        final RenderMetaData renderMetaData = entry.target as RenderMetaData;
        if (renderMetaData.metaData is _AnswerWidgetState) {
          var metaData = renderMetaData.metaData as _AnswerWidgetState;
          final int destinationIndex = metaData.index;

          final rectAnswer = RectGetter.getRectFromKey(metaData._rectKey);
          final line = _ConnectionLineCreated(
              rectQuery.centerRight - rectWidget.topLeft,
              rectAnswer.centerLeft - rectWidget.topLeft,
              sourceIndex);

          widget._controller.add(line);

          if (null != matchingState.widget._builder.onAddConnection) {
            matchingState.widget._builder
                .onAddConnection(sourceIndex, destinationIndex);
          }

          found = true;
          break;
        }
      }
    }

    if (!found) {
      widget._controller.add(_ConnectionLineRemoved(sourceIndex));

      if (null != matchingState.widget._builder.onRemoveConnection) {
        matchingState.widget._builder.onRemoveConnection(sourceIndex);
      }
    }
  }
}

typedef _AnswerWidgetBuilder = Widget Function(BuildContext context);

class _AnswerWidget extends StatefulWidget {
  _AnswerWidget(
      {Key key, @required int index, @required _AnswerWidgetBuilder builder})
      : _index = index,
        _builder = builder,
        super(key: key);

  final _AnswerWidgetBuilder _builder;

  final int _index;

  @override
  State<StatefulWidget> createState() {
    return _AnswerWidgetState();
  }
}

class _AnswerWidgetState extends State<_AnswerWidget> {
  int get index => widget._index;

  final _rectKey = RectGetter.createGlobalKey();

  bool _inited;

  @override
  void initState() {
    super.initState();
    _inited = true;
  }

  @override
  void dispose() {
    _inited = false;
    super.dispose();
  }

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
      if (_inited) {
        final rect = RectGetter.getRectFromKey(_rectKey);
        MatchingWidget.of(context)
            ?._addRect(isSource: false, index: widget._index, rect: rect);
      }
    });

    return ret;
  }
}

class _Lines extends StatefulWidget {
  _Lines(
      {@required GlobalKey<_LinesState> key,
      @required this.stream,
      @required this.activeColor,
      @required this.connectedColor})
      : super(key: key);

  final Stream<_ConnectionLine> stream;
  final Color activeColor;
  final Color connectedColor;

  @override
  State<_Lines> createState() => _LinesState();
}

class _LinesState extends State<_Lines> {
  final _lines = Map<int, _ConnectionLine>();

  @override
  Widget build(BuildContext context) {
    _lines.clear();

    return StreamBuilder<_ConnectionLine>(
        stream: widget.stream,
        builder:
            (BuildContext context, AsyncSnapshot<_ConnectionLine> snapshot) {
          if (snapshot.connectionState == ConnectionState.active) {
            final activeLink =
                (snapshot.data is _ConnectionLineActive) ? snapshot.data : null;

            if (snapshot.data is _ConnectionLineCreated) {
              final line = snapshot.data as _ConnectionLineCreated;
              _lines[line._index] = line;
            } else if (snapshot.data is _ConnectionInitLines) {
              for (final line
                  in (snapshot.data as _ConnectionInitLines)._lines) {
                _lines[line._index] = line;
              }
            } else if (snapshot.data is _ConnectionLineRemoved) {
              _lines.remove((snapshot.data as _ConnectionLineRemoved)._index);
            } else if (snapshot.data is _ConnectionLineClear) {
              _lines.clear();
            }

            return CustomPaint(
              size: Size(10, 10),
              painter: _LinesPainter(Map<int, _ConnectionLine>.of(_lines),
                  activeLink, widget.activeColor, widget.connectedColor),
            );
          } else
            return Container();
        });
  }

//  void clear() {
//    setState(() {
//      _lines.clear();
//    });
//  }
}

abstract class _ConnectionLine {
  _ConnectionLine(this._start, this._end);

  final Offset _start;
  final Offset _end;

  @override
  String toString() {
    return '$_start -> $_end';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is _ConnectionLine &&
          runtimeType == other.runtimeType &&
          _start == other._start &&
          _end == other._end;

  @override
  int get hashCode => _start.hashCode ^ _end.hashCode;
}

class _ConnectionLineActive extends _ConnectionLine {
  _ConnectionLineActive(Offset start, Offset end) : super(start, end);
}

class _ConnectionLineCreated extends _ConnectionLine {
  _ConnectionLineCreated(Offset start, Offset end, this._index)
      : super(start, end);

  final int _index;
}

class _ConnectionInitLines extends _ConnectionLine {
  _ConnectionInitLines(this._lines) : super(null, null);

  final Iterable<_ConnectionLineCreated> _lines;
}

class _ConnectionLineRemoved extends _ConnectionLine {
  _ConnectionLineRemoved(this._index) : super(null, null);

  final int _index;
}

class _ConnectionLineClear extends _ConnectionLine {
  _ConnectionLineClear() : super(null, null);
}

bool matchingWidgetTest() {
  _CustomPanGestureRecognizer rec = _CustomPanGestureRecognizer(
      onPanUpdate: (Offset offset) {},
      onPanDown: (Offset offset) {
        return true;
      },
      onPanEnd: (Offset offset) {});
  String s = rec.debugDescription;
  rec.didStopTrackingLastPointer(0);

  _ConnectionLineActive l1 = _ConnectionLineActive(Offset(1, 0), Offset(0, 1));
  _ConnectionLineActive l2 = _ConnectionLineActive(Offset(1, 0), Offset(0, 1));
  _ConnectionLineActive l3 = _ConnectionLineActive(Offset(1, 0), Offset(1, 1));
  return l1.hashCode == l2.hashCode &&
      l1 == l2 &&
      l1.hashCode != l3.hashCode &&
      l1 != l3 &&
      s == 'customPan' &&
      l1.toString() != "";
}

class _LinesPainter extends CustomPainter {
  _LinesPainter(
      this._lines, this._activeLink, this.activeColor, this.connectedColor);

  final Map<int, _ConnectionLine> _lines;
  final _ConnectionLine _activeLink;
  final Color activeColor;
  final Color connectedColor;

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
  bool shouldRepaint(_LinesPainter oldDelegate) {
    final shouldRepaintMap =
        !mapEquals<int, _ConnectionLine>(oldDelegate._lines, _lines);

    final shouldRepaintActive = oldDelegate._activeLink != _activeLink;

    return shouldRepaintMap || shouldRepaintActive;
  }
}

class _CustomPanGestureRecognizer extends OneSequenceGestureRecognizer {
  _CustomPanGestureRecognizer({
    @required this.onPanDown,
    @required this.onPanUpdate,
    @required this.onPanEnd,
  });

  final bool Function(Offset offset) onPanDown;
  final Function(Offset offset) onPanUpdate;
  final Function(Offset offset) onPanEnd;

  @override
  void addPointer(PointerEvent event) {
    if (null != onPanDown && onPanDown(event.position)) {
      startTrackingPointer(event.pointer);
      resolve(GestureDisposition.accepted);
    } else {
      stopTrackingPointer(event.pointer);
    }
  }

  @override
  void handleEvent(PointerEvent event) {
    if (null != onPanUpdate && event is PointerMoveEvent) {
      onPanUpdate(event.position);
    } else if (event is PointerUpEvent) {
      if (null != onPanEnd) {
        onPanEnd(event.position);
      }

      stopTrackingPointer(event.pointer);
    }
  }

  @override
  String get debugDescription => 'customPan';

  @override
  void didStopTrackingLastPointer(int pointer) {}
}
