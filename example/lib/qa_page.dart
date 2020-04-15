
//flutter pub run build_runner build

import 'package:built_value/built_value.dart';

import 'page_builder.dart';

part 'qa_page.g.dart';

abstract class Page implements Built<Page, PageBuilder> {
  String get title;

  QABuilder get builder;

  Page._();

  factory Page([void Function(PageBuilder) updates]) = _$Page;
}
