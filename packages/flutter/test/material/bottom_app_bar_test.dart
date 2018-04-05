// Copyright 2018 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

void main() {
  testWidgets('no overlap with floating action button', (WidgetTester tester) async {
    await tester.pumpWidget(
      new MaterialApp(
        home: const Scaffold(
          floatingActionButton: const FloatingActionButton(
            onPressed: null,
          ),
          bottomNavigationBar: const ShapeListener(const BottomAppBar()),
        ),
      ),
    );

    final ShapeListenerState shapeListenerState = tester.state(find.byType(ShapeListener));
    final RenderBox renderBox = tester.renderObject(find.byType(BottomAppBar));
    final Path expectedPath = new Path()
      ..addRect(Offset.zero & renderBox.size);

    final Path actualPath = shapeListenerState.cache.value;
    expect(
      actualPath,
      coversSameAreaAs(
        expectedPath,
        areaToCompare: (Offset.zero & renderBox.size).inflate(5.0),
      )
    );
  });
}

// The bottom app bar clip path computation is only available at paint time.
// In order to examine the notch path we implement this caching painter which
// at paint time looks for for a descendant PhysicalShape and caches the
// clip path it is using.
class ClipCachePainter extends CustomPainter {
  ClipCachePainter(this.context);

  Path value;
  BuildContext context;

  @override
  void paint(Canvas canvas, Size size) {
    final RenderPhysicalShape physicalShape = findPhysicalShapeChild(context);
    value = physicalShape.clipper.getClip(size);
  }

  RenderPhysicalShape findPhysicalShapeChild(BuildContext context) {
    RenderPhysicalShape result;
    context.visitChildElements((Element e) {
      final RenderObject renderObject = e.findRenderObject();
      if (renderObject.runtimeType == RenderPhysicalShape) {
        assert(result == null);
        result = renderObject;
      } else {
        result = findPhysicalShapeChild(e);
      }
    });
    return result;
  }

  @override
  bool shouldRepaint(ClipCachePainter oldDelegate) {
    return true;
  }
}

class ShapeListener extends StatefulWidget {
  const ShapeListener(this.child);

  final Widget child;

  @override
  State createState() => new ShapeListenerState();

}

class ShapeListenerState extends State<ShapeListener> {
  @override
  Widget build(BuildContext context) {
    return new CustomPaint(
      child: widget.child,
      painter: cache
    );
  }

  ClipCachePainter cache;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    cache = new ClipCachePainter(context);
  }

}
