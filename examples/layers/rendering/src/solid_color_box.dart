// Copyright 2015 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/rendering.dart';
import 'package:flutter/gestures.dart';

class RenderSolidColorBox extends RenderDecoratedBox {
  final Size desiredSize;
  final Color backgroundColor;

  RenderSolidColorBox(this.backgroundColor, { this.desiredSize: Size.infinite })
      : super(decoration: new BoxDecoration(color: backgroundColor));

  @override
  double computeMinIntrinsicWidth(double height) {
    return desiredSize.width == double.INFINITY ? 0.0 : desiredSize.width;
  }

  @override
  double computeMaxIntrinsicWidth(double height) {
    return desiredSize.width == double.INFINITY ? 0.0 : desiredSize.width;
  }

  @override
  double computeMinIntrinsicHeight(double width) {
    return desiredSize.height == double.INFINITY ? 0.0 : desiredSize.height;
  }

  @override
  double computeMaxIntrinsicHeight(double width) {
    return desiredSize.height == double.INFINITY ? 0.0 : desiredSize.height;
  }

  @override
  void performLayout() {
    size = constraints.constrain(desiredSize);
  }

  @override
  void handleEvent(PointerEvent event, BoxHitTestEntry entry) {
    if (event is PointerDownEvent) {
      decoration = const BoxDecoration(color: const Color(0xFFFF0000));
    } else if (event is PointerUpEvent) {
      decoration = new BoxDecoration(color: backgroundColor);
    }
  }
}
