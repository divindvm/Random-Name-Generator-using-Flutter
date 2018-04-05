// Copyright 2015 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/rendering.dart';
import 'package:test/test.dart';

import 'rendering_tester.dart';

void main() {
  test('RenderFractionallySizedBox constraints', () {
    RenderBox root, leaf, test;
    root = new RenderPositionedBox(
      child: new RenderConstrainedBox(
        additionalConstraints: new BoxConstraints.tight(const Size(200.0, 200.0)),
        child: test = new RenderFractionallySizedOverflowBox(
          widthFactor: 2.0,
          heightFactor: 0.5,
          child: leaf = new RenderConstrainedBox(
            additionalConstraints: const BoxConstraints.expand()
          )
        )
      )
    );
    layout(root);
    expect(root.size.width, equals(800.0));
    expect(root.size.height, equals(600.0));
    expect(test.size.width, equals(200.0));
    expect(test.size.height, equals(200.0));
    expect(leaf.size.width, equals(400.0));
    expect(leaf.size.height, equals(100.0));
  });

  test('BoxConstraints with NaN', () {
    String result;

    result = 'no exception';
    try {
      const BoxConstraints constraints = const BoxConstraints(minWidth: double.NAN, maxWidth: double.NAN, minHeight: 2.0, maxHeight: double.NAN);
      assert(constraints.debugAssertIsValid());
    } on FlutterError catch (e) {
      result = '$e';
    }
    expect(result, equals(
      'BoxConstraints has NaN values in minWidth, maxWidth, and maxHeight.\n'
      'The offending constraints were:\n'
      '  BoxConstraints(NaN<=w<=NaN, 2.0<=h<=NaN; NOT NORMALIZED)'
    ));

    result = 'no exception';
    try {
      const BoxConstraints constraints = const BoxConstraints(minHeight: double.NAN);
      assert(constraints.debugAssertIsValid());
    } on FlutterError catch (e) {
      result = '$e';
    }
    expect(result, equals(
      'BoxConstraints has a NaN value in minHeight.\n'
      'The offending constraints were:\n'
      '  BoxConstraints(0.0<=w<=Infinity, NaN<=h<=Infinity; NOT NORMALIZED)'
    ));

    result = 'no exception';
    try {
      const BoxConstraints constraints = const BoxConstraints(minHeight: double.NAN, maxWidth: 0.0/0.0);
      assert(constraints.debugAssertIsValid());
    } on FlutterError catch (e) {
      result = '$e';
    }
    expect(result, equals(
      'BoxConstraints has NaN values in maxWidth and minHeight.\n'
      'The offending constraints were:\n'
      '  BoxConstraints(0.0<=w<=NaN, NaN<=h<=Infinity; NOT NORMALIZED)'
    ));
  });
}
