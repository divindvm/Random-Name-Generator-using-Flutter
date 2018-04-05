// Copyright 2015 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/widgets.dart';

void main() {
  testWidgets('setState() overbuild test', (WidgetTester tester) async {
    final List<String> log = <String>[];
    final Builder inner = new Builder(
      builder: (BuildContext context) {
        log.add('inner');
        return const Text('inner', textDirection: TextDirection.ltr);
      }
    );
    int value = 0;
    await tester.pumpWidget(new Builder(
      builder: (BuildContext context) {
        log.add('outer');
        return new StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            log.add('stateful');
            return new GestureDetector(
              onTap: () {
                setState(() {
                  value += 1;
                });
              },
              child: new Builder(
                builder: (BuildContext context) {
                  log.add('middle $value');
                  return inner;
                }
              )
            );
          }
        );
      }
    ));
    log.add('---');
    await tester.tap(find.text('inner'));
    await tester.pump();
    log.add('---');
    expect(log, equals(<String>[
      'outer',
      'stateful',
      'middle 0',
      'inner',
      '---',
      'stateful',
      'middle 1',
      '---',
    ]));
  });
}
