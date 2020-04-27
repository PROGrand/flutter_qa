import 'page_builder.dart';

class QAPage {
  QAPage(this.title, this.builder);

  final String title;

  final QABuilder builder;

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is QAPage && title == other.title;
  }

  @override
  int get hashCode {
    return title.hashCode;
  }

  @override
  String toString() {
    return title.toString();
  }
}
