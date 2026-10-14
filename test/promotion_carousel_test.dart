import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:point_system/features/home/widgets/promotion_carousel.dart';

Widget carousel({bool reduceMotion = false, double textScale = 1}) =>
    MaterialApp(
      home: MediaQuery(
        data: MediaQueryData(
          disableAnimations: reduceMotion,
          textScaler: TextScaler.linear(textScale),
        ),
        child: const Scaffold(
          body: SingleChildScrollView(
            child: SizedBox(width: 320, child: PromotionCarousel()),
          ),
        ),
      ),
    );

void main() {
  testWidgets('swipe changes promotion and selected indicator', (tester) async {
    final semantics = tester.ensureSemantics();
    await tester.pumpWidget(carousel());
    await tester.pumpAndSettle();
    expect(find.text('Double Points Weekend'), findsOneWidget);
    await tester.drag(find.byType(PageView), const Offset(-300, 0));
    await tester.pumpAndSettle();
    expect(find.text('Coffee & Rewards'), findsOneWidget);
    final selected = tester.widget<Semantics>(
      find.byWidgetPredicate(
        (widget) =>
            widget is Semantics &&
            widget.properties.label == 'Promotion 2 of 3',
      ),
    );
    expect(selected.properties.selected, isTrue);
    expect(tester.takeException(), isNull);
    semantics.dispose();
  });

  testWidgets('indicator animates to requested slide with network fallback', (
    tester,
  ) async {
    await tester.pumpWidget(carousel());
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Show Member Specials'));
    await tester.pumpAndSettle();
    expect(find.text('Member Specials'), findsOneWidget);
    // Widget tests reject HTTP requests. The asset fallback must keep the card usable.
    await tester.runAsync(() async {
      await Future<void>.delayed(const Duration(milliseconds: 100));
    });
    await tester.pumpAndSettle();
    expect(
      find.byWidgetPredicate(
        (widget) => widget is Image && widget.image is AssetImage,
      ),
      findsWidgets,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('large text fits and reduced motion jumps without animation', (
    tester,
  ) async {
    await tester.pumpWidget(carousel(reduceMotion: true, textScale: 2));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Show Coffee & Rewards'));
    await tester.pump();
    expect(tester.widget<PageView>(find.byType(PageView)).controller!.page, 1);
    expect(find.text('Coffee & Rewards'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
