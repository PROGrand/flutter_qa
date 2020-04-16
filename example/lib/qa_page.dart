//flutter pub run build_runner build

import 'package:built_value/built_value.dart';

import 'page_builder.dart';

class Page {
  Page(this.title, this.builder);

  final String title;

  final QABuilder builder;

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is Page && title == other.title;
  }

  @override
  int get hashCode {
    return title.hashCode;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper('Page')..add('title', title))
        .toString();
  }
}
