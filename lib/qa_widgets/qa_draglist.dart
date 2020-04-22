import 'dart:math';

import 'package:built_collection/built_collection.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';

part 'drag_and_drop_list.dart';

part 'my_draggable.dart';

/// Parameters used to create [DragListWidget].
class DragListWidgetBuilder<T> {
  DragListWidgetBuilder({this.ordered, this.items, this.build, this.onOrder});

  /// Ordered list of [items] elements.
  final BuiltList<int> ordered;

  /// Items.
  ///
  /// Elements positions are used in [ordered] array field.
  final BuiltList<T> items;

  /// Constructs item widgets.
  final Widget Function(BuildContext context, T item) build;

  /// Callback when items are ordered.
  Function(List<int> ordered) onOrder;
}

/// Ordered list of items with drag and drop support.
///
/// Allows to order items.
class DragListWidget<T> extends StatefulWidget {
  const DragListWidget({Key key, @required DragListWidgetBuilder<T> builder})
      : this._builder = builder,
        super(key: key);

  final DragListWidgetBuilder<T> _builder;

  @override
  _DragListWidgetState createState() => _DragListWidgetState<T>();
}

class _DragListWidgetState<T> extends State<DragListWidget<T>> {
  List<int> ordered;

  @override
  void initState() {
    super.initState();

    int n = 0;
    ordered = null != widget._builder.ordered
        ? List<int>.from(widget._builder.ordered, growable: true)
        : List<int>.from(widget._builder.items.map<int>((_) {
            return n++;
          }), growable: true);
  }

  @override
  Widget build(BuildContext context) => DragAndDropList<T>(
        <T>[for (final n in ordered) widget._builder.items[n]],
        itemBuilder: (BuildContext context, item) =>
            widget._builder.build(context, item),
        onDragFinish: (before, after) {
          final position = ordered[before];
          ordered.removeAt(before);
          ordered.insert(after, position);

          if (null != widget._builder.onOrder) {
            widget._builder.onOrder(ordered);
          }
        },
        canBeDraggedTo: (one, two) => true,
        dragElevation: 0.0,
      );
}
