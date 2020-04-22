import 'package:built_collection/built_collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_qa/qa_widgets/qa_draglist.dart';
import 'package:flutter_qa/qa_widgets/qa_matching.dart';
import 'package:flutter_test/flutter_test.dart';

part 'matching_app.dart';
part 'ordering_app.dart';

void main() {
  testWidgets('Test matching widget', (WidgetTester tester) async {
    await tester.pumpWidget(MatchingTestApp());

    expect(find.text('Clear'), findsOneWidget);
    expect(find.text('Query 2'), findsNWidgets(1));

    await tester.press(find.text('Query 2'));
    await tester.pump();
    await tester.press(find.text('Answer 2'));
    await tester.pump();

    final src_rect = tester.getRect(find.text('Query 2'));
    final dst_rect = tester.getRect(find.text('Answer 2'));

    await tester.dragFrom(src_rect.center, dst_rect.center);
    await tester.pump();

    await tester.dragFrom(
        src_rect.center, (src_rect.center + dst_rect.center) / 2);
    await tester.pump();

    await tester.dragFrom(
        dst_rect.center, (src_rect.center + dst_rect.center) / 2);
    await tester.pump();

    await tester.tap(find.text('Clear'));

    expect(onClearCalled, isTrue);

    expect(matchingWidgetTest(), isTrue);

//    await tester.dragFrom(src_rect.center, (dst_rect.center + src_rect.center) / 2);
  });

  testWidgets('Test ordering widget', (WidgetTester tester) async {
          await tester.pumpWidget(OrderingTestApp());

          expect(find.text('3'), findsOneWidget);

          await tester.pump();

          final src_rect = tester.getRect(find.text('3'));
          final dst_rect = tester.getRect(find.text('1'));

          await tester.dragFrom(src_rect.center, dst_rect.center);
          await tester.pump();

          expect(onOrderCalled, isTrue);
  });
}

