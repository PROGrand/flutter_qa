//flutter pub run build_runner build

import 'package:built_value/built_value.dart';

import 'page_builder.dart';

part 'qa_page.g.dart';

abstract class Page implements Built<Page, PageBuilder> {
  String get title;

  QABuilder get builder;

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    final dynamic _$dynamicOther = other;
    return other is Page && title == other.title;
  }

  @override
  int get hashCode {
    return $jf($jc(0, title.hashCode));
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper('Page')..add('title', title))
        .toString();
  }

  Page._();

  factory Page([void Function(PageBuilder) updates]) = _$Page;
}
