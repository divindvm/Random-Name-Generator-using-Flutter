// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/widgets.dart';

import '../rendering/mock_canvas.dart';
import 'states.dart';

void main() {
  testWidgets('Empty GridView', (WidgetTester tester) async {
    await tester.pumpWidget(
      new Directionality(
        textDirection: TextDirection.ltr,
        child: new GridView.count(
          crossAxisCount: 4,
          children: const <Widget>[],
        ),
      ),
    );
  });

  testWidgets('GridView.count control test', (WidgetTester tester) async {
    final List<String> log = <String>[];

    await tester.pumpWidget(
      new Directionality(
        textDirection: TextDirection.ltr,
        child: new GridView.count(
          crossAxisCount: 4,
          children: kStates.map((String state) {
            return new GestureDetector(
              onTap: () {
                log.add(state);
              },
              child: new Container(
                color: const Color(0xFF0000FF),
                child: new Text(state),
              ),
            );
          }).toList(),
        ),
      ),
    );

    expect(tester.getSize(find.text('Arkansas')), equals(const Size(200.0, 200.0)));

    for (int i = 0; i < 8; ++i) {
      await tester.tap(find.text(kStates[i]));
      expect(log, equals(<String>[kStates[i]]));
      log.clear();
    }

    expect(find.text(kStates[12]), findsNothing);
    expect(find.text('Nevada'), findsNothing);

    await tester.drag(find.text('Arkansas'), const Offset(0.0, -200.0));
    await tester.pump();

    for (int i = 0; i < 4; ++i)
      expect(find.text(kStates[i]), findsNothing);

    for (int i = 4; i < 12; ++i) {
      await tester.tap(find.text(kStates[i]));
      expect(log, equals(<String>[kStates[i]]));
      log.clear();
    }

    await tester.drag(find.text('Delaware'), const Offset(0.0, -4000.0));
    await tester.pump();

    expect(find.text('Alabama'), findsNothing);
    expect(find.text('Pennsylvania'), findsNothing);

    expect(tester.getCenter(find.text('Tennessee')),
        equals(const Offset(300.0, 100.0)));

    await tester.tap(find.text('Tennessee'));
    expect(log, equals(<String>['Tennessee']));
    log.clear();

    await tester.drag(find.text('Tennessee'), const Offset(0.0, 200.0));
    await tester.pump();

    await tester.tap(find.text('Tennessee'));
    expect(log, equals(<String>['Tennessee']));
    log.clear();

    await tester.tap(find.text('Pennsylvania'));
    expect(log, equals(<String>['Pennsylvania']));
    log.clear();
  });

  testWidgets('GridView.extent control test', (WidgetTester tester) async {
    final List<String> log = <String>[];

    await tester.pumpWidget(
      new Directionality(
        textDirection: TextDirection.ltr,
        child: new GridView.extent(
          maxCrossAxisExtent: 200.0,
          children: kStates.map((String state) {
            return new GestureDetector(
              onTap: () {
                log.add(state);
              },
              child: new Container(
                color: const Color(0xFF0000FF),
                child: new Text(state),
              ),
            );
          }).toList(),
        ),
      ),
    );

    expect(tester.getSize(find.text('Arkansas')), equals(const Size(200.0, 200.0)));

    for (int i = 0; i < 8; ++i) {
      await tester.tap(find.text(kStates[i]));
      expect(log, equals(<String>[kStates[i]]));
      log.clear();
    }

    expect(find.text('Nevada'), findsNothing);

    await tester.drag(find.text('Arkansas'), const Offset(0.0, -4000.0));
    await tester.pump();

    expect(find.text('Alabama'), findsNothing);

    expect(tester.getCenter(find.text('Tennessee')),
        equals(const Offset(300.0, 100.0)));

    await tester.tap(find.text('Tennessee'));
    expect(log, equals(<String>['Tennessee']));
    log.clear();
  });

  testWidgets('GridView large scroll jump', (WidgetTester tester) async {
    final List<int> log = <int>[];

    await tester.pumpWidget(
      new Directionality(
        textDirection: TextDirection.ltr,
        child: new GridView.extent(
          scrollDirection: Axis.horizontal,
          maxCrossAxisExtent: 200.0,
          childAspectRatio: 0.75,
          children: new List<Widget>.generate(80, (int i) {
            return new Builder(
              builder: (BuildContext context) {
                log.add(i);
                return new Container(
                  child: new Text('$i'),
                );
              }
            );
          }),
        ),
      ),
    );

    expect(tester.getSize(find.text('4')), equals(const Size(200.0 / 0.75, 200.0)));

    expect(log, equals(<int>[
      0, 1, 2, // col 0
      3, 4, 5, // col 1
      6, 7, 8, // col 2
    ]));
    log.clear();

    final ScrollableState state = tester.state(find.byType(Scrollable));
    final ScrollPosition position = state.position;
    position.jumpTo(3025.0);

    expect(log, isEmpty);
    await tester.pump();

    expect(log, equals(<int>[
      33, 34, 35, // col 11
      36, 37, 38, // col 12
      39, 40, 41, // col 13
      42, 43, 44, // col 14
    ]));
    log.clear();

    position.jumpTo(975.0);

    expect(log, isEmpty);
    await tester.pump();

    expect(log, equals(<int>[
      9, 10, 11, // col 3
      12, 13, 14, // col 4
      15, 16, 17, // col 5
      18, 19, 20, // col 6
    ]));
    log.clear();
  });

  testWidgets('GridView - change crossAxisCount', (WidgetTester tester) async {
    final List<int> log = <int>[];

    await tester.pumpWidget(
      new Directionality(
        textDirection: TextDirection.ltr,
        child: new GridView(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4,
          ),
          children: new List<Widget>.generate(40, (int i) {
            return new Builder(
              builder: (BuildContext context) {
                log.add(i);
                return new Container(
                  child: new Text('$i'),
                );
              }
            );
          }),
        ),
      ),
    );

    expect(tester.getSize(find.text('4')), equals(const Size(200.0, 200.0)));

    expect(log, equals(<int>[
      0, 1, 2, 3, // row 0
      4, 5, 6, 7, // row 1
      8, 9, 10, 11, // row 2
    ]));
    log.clear();

    await tester.pumpWidget(
      new Directionality(
        textDirection: TextDirection.ltr,
        child: new GridView(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
          ),
          children: new List<Widget>.generate(40, (int i) {
            return new Builder(
              builder: (BuildContext context) {
                log.add(i);
                return new Container(
                  child: new Text('$i'),
                );
              }
            );
          }),
        ),
      ),
    );

    expect(log, equals(<int>[
      0, 1, 2, 3, // row 0
      4, 5, 6, 7, // row 1
      8, 9, 10, 11, // row 2
    ]));
    log.clear();

    expect(tester.getSize(find.text('3')), equals(const Size(400.0, 400.0)));
    expect(find.text('4'), findsNothing);
  });

  testWidgets('GridView - change maxChildCrossAxisExtent', (WidgetTester tester) async {
    final List<int> log = <int>[];

    await tester.pumpWidget(
      new Directionality(
        textDirection: TextDirection.ltr,
        child: new GridView(
          gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
            maxCrossAxisExtent: 200.0,
          ),
          children: new List<Widget>.generate(40, (int i) {
            return new Builder(
              builder: (BuildContext context) {
                log.add(i);
                return new Container(
                  child: new Text('$i'),
                );
              }
            );
          }),
        ),
      ),
    );

    expect(tester.getSize(find.text('4')), equals(const Size(200.0, 200.0)));

    expect(log, equals(<int>[
      0, 1, 2, 3, // row 0
      4, 5, 6, 7, // row 1
      8, 9, 10, 11, // row 2
    ]));
    log.clear();

    await tester.pumpWidget(
      new Directionality(
        textDirection: TextDirection.ltr,
        child: new GridView(
          gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
            maxCrossAxisExtent: 400.0,
          ),
          children: new List<Widget>.generate(40, (int i) {
            return new Builder(
              builder: (BuildContext context) {
                log.add(i);
                return new Container(
                  child: new Text('$i'),
                );
              }
            );
          }),
        ),
      ),
    );

    expect(log, equals(<int>[
      0, 1, 2, 3, // row 0
      4, 5, 6, 7, // row 1
      8, 9, 10, 11, // row 2
    ]));
    log.clear();

    expect(tester.getSize(find.text('3')), equals(const Size(400.0, 400.0)));
    expect(find.text('4'), findsNothing);
  });

  testWidgets('One-line GridView paints', (WidgetTester tester) async {
    const Color green = const Color(0xFF00FF00);

    final Container container = new Container(
      decoration: const BoxDecoration(
        color: green,
      ),
    );

    await tester.pumpWidget(
      new Directionality(
        textDirection: TextDirection.ltr,
        child: new Center(
          child: new SizedBox(
            height: 200.0,
            child: new GridView.count(
              crossAxisCount: 2,
              children: <Widget>[ container, container, container, container ],
            ),
          ),
        ),
      ),
    );

    expect(find.byType(GridView), paints..rect(color: green)..rect(color: green));
    expect(find.byType(GridView), isNot(paints..rect(color: green)..rect(color: green)..rect(color: green)));
  });

  testWidgets('GridView in zero context', (WidgetTester tester) async {
    await tester.pumpWidget(
      new Directionality(
        textDirection: TextDirection.ltr,
        child: new Center(
          child: new SizedBox(
            width: 0.0,
            height: 0.0,
            child: new GridView.count(
              crossAxisCount: 4,
              children: new List<Widget>.generate(20, (int i) {
                return new Container(
                  child: new Text('$i'),
                );
              }),
            ),
          ),
        ),
      ),
    );

    expect(find.text('0'), findsOneWidget);
    expect(find.text('1'), findsNothing);
  });

  testWidgets('GridView in unbounded context', (WidgetTester tester) async {
    await tester.pumpWidget(
      new Directionality(
        textDirection: TextDirection.ltr,
        child: new SingleChildScrollView(
          child: new GridView.count(
            crossAxisCount: 4,
            shrinkWrap: true,
            children: new List<Widget>.generate(20, (int i) {
              return new Container(
                child: new Text('$i'),
              );
            }),
          ),
        ),
      ),
    );

    expect(find.text('0'), findsOneWidget);
    expect(find.text('19'), findsOneWidget);
  });

  testWidgets('GridView.builder control test', (WidgetTester tester) async {
    await tester.pumpWidget(
      new Directionality(
        textDirection: TextDirection.ltr,
        child: new GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4,
          ),
          shrinkWrap: true,
          itemCount: 20,
          itemBuilder: (BuildContext context, int index) {
            return new Container(
              child: new Text('$index'),
            );
          },
        ),
      ),
    );
    expect(find.text('0'), findsOneWidget);
    expect(find.text('11'), findsOneWidget);
    expect(find.text('12'), findsNothing);
  });

  testWidgets('GridView cross axis layout', (WidgetTester tester) async {
    final Key target = new UniqueKey();

    Widget build(TextDirection textDirection) {
      return new Directionality(
        textDirection: textDirection,
        child: new GridView.count(
          crossAxisCount: 4,
          children: <Widget>[
            new Container(key: target),
          ],
        ),
      );
    }

    await tester.pumpWidget(build(TextDirection.ltr));

    expect(tester.getTopLeft(find.byKey(target)), Offset.zero);
    expect(tester.getBottomRight(find.byKey(target)), const Offset(200.0, 200.0));

    await tester.pumpWidget(build(TextDirection.rtl));

    expect(tester.getTopLeft(find.byKey(target)), const Offset(600.0, 0.0));
    expect(tester.getBottomRight(find.byKey(target)), const Offset(800.0, 200.0));
  });
}
