// Copyright 2016 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/physics.dart';
import 'package:flutter/material.dart';

class TestSliverPersistentHeaderDelegate extends SliverPersistentHeaderDelegate {
  TestSliverPersistentHeaderDelegate(this._maxExtent);

  final double _maxExtent;

  @override
  double get maxExtent => _maxExtent;

  @override
  double get minExtent => 16.0;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return new Column(
      children: <Widget>[
        new Container(height: minExtent),
        new Expanded(child: new Container()),
      ],
    );
  }

  @override
  bool shouldRebuild(TestSliverPersistentHeaderDelegate oldDelegate) => false;
}

class TestBehavior extends ScrollBehavior {
  @override
  Widget buildViewportChrome(BuildContext context, Widget child, AxisDirection axisDirection) {
    return new GlowingOverscrollIndicator(
      child: child,
      axisDirection: axisDirection,
      color: const Color(0xFFFFFFFF),
    );
  }
}

class TestScrollPhysics extends ClampingScrollPhysics {
  const TestScrollPhysics({ ScrollPhysics parent }) : super(parent: parent);

  @override
  TestScrollPhysics applyTo(ScrollPhysics ancestor) {
    return new TestScrollPhysics(parent: parent?.applyTo(ancestor) ?? ancestor);
  }

  @override
  Tolerance get tolerance => const Tolerance(velocity: 20.0, distance: 1.0);
}

class TestViewportScrollPosition extends ScrollPositionWithSingleContext {
  TestViewportScrollPosition({
    ScrollPhysics physics,
    ScrollContext context,
    ScrollPosition oldPosition,
  }) : super(physics: physics, context: context, oldPosition: oldPosition);

  @override
  bool applyContentDimensions(double minScrollExtent, double maxScrollExtent) {
    expect(minScrollExtent, moreOrLessEquals(-3895.0));
    expect(maxScrollExtent, moreOrLessEquals(8575.0));
    return super.applyContentDimensions(minScrollExtent, maxScrollExtent);
  }
}

void main() {
  testWidgets('Evil test of sliver features - 1', (WidgetTester tester) async {
    final GlobalKey centerKey = new GlobalKey();
    await tester.pumpWidget(new Directionality(
      textDirection: TextDirection.ltr,
      child: new ScrollConfiguration(
        behavior: new TestBehavior(),
        child: new Scrollbar(
          child: new Scrollable(
            axisDirection: AxisDirection.down,
            physics: const TestScrollPhysics(),
            viewportBuilder: (BuildContext context, ViewportOffset offset) {
              return new Viewport(
                axisDirection: AxisDirection.down,
                anchor: 0.25,
                offset: offset,
                center: centerKey,
                slivers: <Widget>[
                  new SliverToBoxAdapter(child: new Container(height: 5.0)),
                  new SliverToBoxAdapter(child: new Container(height: 520.0)),
                  new SliverToBoxAdapter(child: new Container(height: 520.0)),
                  new SliverToBoxAdapter(child: new Container(height: 520.0)),
                  new SliverPersistentHeader(delegate: new TestSliverPersistentHeaderDelegate(150.0), pinned: true),
                  new SliverToBoxAdapter(child: new Container(height: 520.0)),
                  new SliverPadding(
                    padding: const EdgeInsets.all(50.0),
                    sliver: new SliverToBoxAdapter(child: new Container(height: 520.0)),
                  ),
                  new SliverToBoxAdapter(child: new Container(height: 520.0)),
                  new SliverPersistentHeader(delegate: new TestSliverPersistentHeaderDelegate(150.0), floating: true),
                  new SliverToBoxAdapter(child: new Container(height: 520.0)),
                  new SliverToBoxAdapter(key: centerKey, child: new Container(height: 520.0)), // ------------------------ CENTER ------------------------
                  new SliverPersistentHeader(delegate: new TestSliverPersistentHeaderDelegate(150.0), pinned: true),
                  new SliverToBoxAdapter(child: new Container(height: 520.0)),
                  new SliverToBoxAdapter(child: new Container(height: 520.0)),
                  new SliverToBoxAdapter(child: new Container(height: 520.0)),
                  new SliverPadding(
                    padding: const EdgeInsets.all(50.0),
                    sliver: new SliverPersistentHeader(delegate: new TestSliverPersistentHeaderDelegate(250.0), pinned: true),
                  ),
                  new SliverToBoxAdapter(child: new Container(height: 520.0)),
                  new SliverPersistentHeader(delegate: new TestSliverPersistentHeaderDelegate(250.0), pinned: true),
                  new SliverToBoxAdapter(child: new Container(height: 5.0)),
                  new SliverPersistentHeader(delegate: new TestSliverPersistentHeaderDelegate(250.0), pinned: true),
                  new SliverToBoxAdapter(child: new Container(height: 5.0)),
                  new SliverPersistentHeader(delegate: new TestSliverPersistentHeaderDelegate(250.0), pinned: true),
                  new SliverPersistentHeader(delegate: new TestSliverPersistentHeaderDelegate(250.0), pinned: true),
                  new SliverToBoxAdapter(child: new Container(height: 5.0)),
                  new SliverPersistentHeader(delegate: new TestSliverPersistentHeaderDelegate(250.0), pinned: true),
                  new SliverPersistentHeader(delegate: new TestSliverPersistentHeaderDelegate(250.0)),
                  new SliverToBoxAdapter(child: new Container(height: 520.0)),
                  new SliverPersistentHeader(delegate: new TestSliverPersistentHeaderDelegate(150.0), floating: true),
                  new SliverToBoxAdapter(child: new Container(height: 520.0)),
                  new SliverPersistentHeader(delegate: new TestSliverPersistentHeaderDelegate(150.0), floating: true),
                  new SliverToBoxAdapter(child: new Container(height: 5.0)),
                  new SliverList(
                    delegate: new SliverChildListDelegate(<Widget>[
                      new Container(height: 50.0),
                      new Container(height: 50.0),
                      new Container(height: 50.0),
                      new Container(height: 50.0),
                      new Container(height: 50.0),
                      new Container(height: 50.0),
                      new Container(height: 50.0),
                      new Container(height: 50.0),
                      new Container(height: 50.0),
                      new Container(height: 50.0),
                      new Container(height: 50.0),
                      new Container(height: 50.0),
                      new Container(height: 50.0),
                      new Container(height: 50.0),
                      new Container(height: 50.0),
                    ]),
                  ),
                  new SliverPersistentHeader(delegate: new TestSliverPersistentHeaderDelegate(250.0)),
                  new SliverPersistentHeader(delegate: new TestSliverPersistentHeaderDelegate(250.0)),
                  new SliverPersistentHeader(delegate: new TestSliverPersistentHeaderDelegate(250.0)),
                  new SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 50.0),
                    sliver: new SliverToBoxAdapter(child: new Container(height: 520.0)),
                  ),
                  new SliverToBoxAdapter(child: new Container(height: 520.0)),
                  new SliverToBoxAdapter(child: new Container(height: 520.0)),
                  new SliverToBoxAdapter(child: new Container(height: 5.0)),
                ],
              );
            },
          ),
        ),
      ),
    ));
    final ScrollPosition position = tester.state<ScrollableState>(find.byType(Scrollable)).position;

    position.animateTo(10000.0, curve: Curves.linear, duration: const Duration(minutes: 1));
    await tester.pump(const Duration(milliseconds: 10));
    await tester.pump(const Duration(milliseconds: 10));
    await tester.pump(const Duration(milliseconds: 50));
    await tester.pumpAndSettle(const Duration(milliseconds: 122));

    position.animateTo(-10000.0, curve: Curves.linear, duration: const Duration(minutes: 1));
    await tester.pump(const Duration(milliseconds: 10));
    await tester.pump(const Duration(milliseconds: 10));
    await tester.pump(const Duration(milliseconds: 50));
    await tester.pumpAndSettle(const Duration(milliseconds: 122));

    position.animateTo(10000.0, curve: Curves.linear, duration: const Duration(minutes: 1));
    await tester.pump(const Duration(milliseconds: 10));
    await tester.pump(const Duration(milliseconds: 10));
    await tester.pump(const Duration(milliseconds: 50));
    await tester.pumpAndSettle(const Duration(milliseconds: 122));

    position.animateTo(-10000.0, curve: Curves.linear, duration: const Duration(seconds: 1));
    await tester.pump(const Duration(milliseconds: 10));
    await tester.pump(const Duration(milliseconds: 10));
    await tester.pump(const Duration(milliseconds: 50));
    await tester.pumpAndSettle(const Duration(milliseconds: 122));

    position.animateTo(10000.0, curve: Curves.linear, duration: const Duration(seconds: 1));
    await tester.pump(const Duration(milliseconds: 10));
    await tester.pump(const Duration(milliseconds: 10));
    await tester.pump(const Duration(milliseconds: 50));
    await tester.pumpAndSettle(const Duration(milliseconds: 122));

  });

  testWidgets('Removing offscreen items above and rescrolling does not crash', (WidgetTester tester) async {
    await tester.pumpWidget(new MaterialApp(
      home: new CustomScrollView(
        slivers: <Widget>[
          new SliverFixedExtentList(
            itemExtent: 100.0,
            delegate: new SliverChildBuilderDelegate(
              (BuildContext context, int index) {
                return new Container(
                  color: Colors.blue,
                  child: new Text(index.toString()),
                );
              },
              childCount: 30,
            ),
          ),
        ],
      ),
    ));

    await tester.drag(find.text('5'), const Offset(0.0, -500.0));
    await tester.pump();

    // Screen is 600px high. Moved bottom item 500px up. It's now at the top.
    expect(tester.getTopLeft(find.widgetWithText(DecoratedBox, '5')).dy, 0.0);
    expect(tester.getBottomLeft(find.widgetWithText(DecoratedBox, '10')).dy, 600.0);

    // Stop returning the first 3 items.
    await tester.pumpWidget(new MaterialApp(
      home: new CustomScrollView(
        slivers: <Widget>[
          new SliverFixedExtentList(
            itemExtent: 100.0,
            delegate: new SliverChildBuilderDelegate(
              (BuildContext context, int index) {
                if (index > 3) {
                  return new Container(
                    color: Colors.blue,
                    child: new Text(index.toString()),
                  );
                }
                return null;
              },
              childCount: 30,
            ),
          ),
        ],
      ),
    ));

    await tester.drag(find.text('5'), const Offset(0.0, 400.0));
    await tester.pump();

    // Move up by 4 items, meaning item 1 would have been at the top but
    // 0 through 3 no longer exist, so item 4, 3 items down, is the first one.
    // Item 4 is also shifted to the top.
    expect(tester.getTopLeft(find.widgetWithText(DecoratedBox, '4')).dy, 0.0);

    // Because the screen is still 600px, item 9 is now visible at the bottom instead
    // of what's supposed to be item 6 had we not re-shifted.
    expect(tester.getBottomLeft(find.widgetWithText(DecoratedBox, '9')).dy, 600.0);
  });
}
