// Copyright 2015 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/rendering.dart';
import 'package:test/test.dart';

void main() {
  test('list body and paragraph intrinsics', () {
    final RenderParagraph paragraph = new RenderParagraph(
      const TextSpan(
        style: const TextStyle(height: 1.0),
        text: 'Hello World',
      ),
      textDirection: TextDirection.ltr,
    );
    final RenderListBody testBlock = new RenderListBody(
      children: <RenderBox>[
        paragraph,
      ],
    );

    final double textWidth = paragraph.getMaxIntrinsicWidth(double.INFINITY);
    final double oneLineTextHeight = paragraph.getMinIntrinsicHeight(double.INFINITY);
    final double constrainedWidth = textWidth * 0.9;
    final double wrappedTextWidth = paragraph.getMinIntrinsicWidth(double.INFINITY);
    final double twoLinesTextHeight = paragraph.getMinIntrinsicHeight(constrainedWidth);
    final double manyLinesTextHeight = paragraph.getMinIntrinsicHeight(0.0);

    // paragraph
    expect(wrappedTextWidth, greaterThan(0.0));
    expect(wrappedTextWidth, lessThan(textWidth));
    expect(oneLineTextHeight, lessThan(twoLinesTextHeight));
    expect(twoLinesTextHeight, lessThan(oneLineTextHeight * 3.0));
    expect(manyLinesTextHeight, greaterThan(twoLinesTextHeight));
    expect(paragraph.getMaxIntrinsicHeight(double.INFINITY), equals(oneLineTextHeight));
    expect(paragraph.getMaxIntrinsicHeight(constrainedWidth), equals(twoLinesTextHeight));
    expect(paragraph.getMaxIntrinsicHeight(0.0), equals(manyLinesTextHeight));

    // vertical block (same expectations)
    expect(testBlock.getMinIntrinsicWidth(double.INFINITY), equals(wrappedTextWidth));
    expect(testBlock.getMaxIntrinsicWidth(double.INFINITY), equals(textWidth));
    expect(testBlock.getMinIntrinsicHeight(double.INFINITY), equals(oneLineTextHeight));
    expect(testBlock.getMinIntrinsicHeight(constrainedWidth), equals(twoLinesTextHeight));
    expect(testBlock.getMaxIntrinsicHeight(double.INFINITY), equals(oneLineTextHeight));
    expect(testBlock.getMaxIntrinsicHeight(constrainedWidth), equals(twoLinesTextHeight));
    expect(testBlock.getMinIntrinsicWidth(0.0), equals(wrappedTextWidth));
    expect(testBlock.getMaxIntrinsicWidth(0.0), equals(textWidth));
    expect(testBlock.getMinIntrinsicHeight(wrappedTextWidth), equals(twoLinesTextHeight));
    expect(testBlock.getMaxIntrinsicHeight(wrappedTextWidth), equals(twoLinesTextHeight));
    expect(testBlock.getMinIntrinsicHeight(0.0), equals(manyLinesTextHeight));
    expect(testBlock.getMaxIntrinsicHeight(0.0), equals(manyLinesTextHeight));

    // horizontal block (same expectations again)
    testBlock.axisDirection = AxisDirection.right;
    expect(testBlock.getMinIntrinsicWidth(double.INFINITY), equals(wrappedTextWidth));
    expect(testBlock.getMaxIntrinsicWidth(double.INFINITY), equals(textWidth));
    expect(testBlock.getMinIntrinsicHeight(double.INFINITY), equals(oneLineTextHeight));
    expect(testBlock.getMinIntrinsicHeight(constrainedWidth), equals(twoLinesTextHeight));
    expect(testBlock.getMaxIntrinsicHeight(double.INFINITY), equals(oneLineTextHeight));
    expect(testBlock.getMaxIntrinsicHeight(constrainedWidth), equals(twoLinesTextHeight));
    expect(testBlock.getMinIntrinsicWidth(0.0), equals(wrappedTextWidth));
    expect(testBlock.getMaxIntrinsicWidth(0.0), equals(textWidth));
    expect(testBlock.getMinIntrinsicHeight(wrappedTextWidth), equals(twoLinesTextHeight));
    expect(testBlock.getMaxIntrinsicHeight(wrappedTextWidth), equals(twoLinesTextHeight));
    expect(testBlock.getMinIntrinsicHeight(0.0), equals(manyLinesTextHeight));
    expect(testBlock.getMaxIntrinsicHeight(0.0), equals(manyLinesTextHeight));
  });
}
