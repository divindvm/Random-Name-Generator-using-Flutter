// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

// All values eyeballed.
const Color _kScrollbarColor = const Color(0x99777777);
const double _kScrollbarThickness = 2.5;
const double _kScrollbarMainAxisMargin = 4.0;
const double _kScrollbarCrossAxisMargin = 2.5;
const double _kScrollbarMinLength = 4.0;
const Radius _kScrollbarRadius = const Radius.circular(1.25);
const Duration _kScrollbarTimeToFade = const Duration(milliseconds: 50);
const Duration _kScrollbarFadeDuration = const Duration(milliseconds: 250);

/// A iOS style scrollbar.
///
/// A scrollbar indicates which portion of a [Scrollable] widget is actually
/// visible.
///
/// To add a scrollbar to a [ScrollView], simply wrap the scroll view widget in
/// a [CupertinoScrollbar] widget.
///
/// See also:
///
///  * [ListView], which display a linear, scrollable list of children.
///  * [GridView], which display a 2 dimensional, scrollable array of children.
///  * [Scrollbar], a Material Design scrollbar that dynamically adapts to the
///    platform showing either an Android style or iOS style scrollbar.
class CupertinoScrollbar extends StatefulWidget {
  /// Creates an iOS style scrollbar that wraps the given [child].
  ///
  /// The [child] should be a source of [ScrollNotification] notifications,
  /// typically a [Scrollable] widget.
  const CupertinoScrollbar({
    Key key,
    @required this.child,
  }) : super(key: key);

  /// The subtree to place inside the [CupertinoScrollbar].
  ///
  /// This should include a source of [ScrollNotification] notifications,
  /// typically a [Scrollable] widget.
  final Widget child;

  @override
  _CupertinoScrollbarState createState() => new _CupertinoScrollbarState();
}

class _CupertinoScrollbarState extends State<CupertinoScrollbar> with TickerProviderStateMixin {
  ScrollbarPainter _painter;
  TextDirection _textDirection;

  AnimationController _fadeoutAnimationController;
  Animation<double> _fadeoutOpacityAnimation;
  Timer _fadeoutTimer;

  @override
  void initState() {
    super.initState();
    _fadeoutAnimationController = new AnimationController(
      vsync: this,
      duration: _kScrollbarFadeDuration,
    );
    _fadeoutOpacityAnimation = new CurvedAnimation(
      parent: _fadeoutAnimationController,
      curve: Curves.fastOutSlowIn
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _textDirection = Directionality.of(context);
    _painter = _buildCupertinoScrollbarPainter();
  }

  /// Returns a [ScrollbarPainter] visually styled like the iOS scrollbar.
  ScrollbarPainter _buildCupertinoScrollbarPainter() {
    return new ScrollbarPainter(
      color: _kScrollbarColor,
      textDirection: _textDirection,
      thickness: _kScrollbarThickness,
      fadeoutOpacityAnimation: _fadeoutOpacityAnimation,
      mainAxisMargin: _kScrollbarMainAxisMargin,
      crossAxisMargin: _kScrollbarCrossAxisMargin,
      radius: _kScrollbarRadius,
      minLength: _kScrollbarMinLength,
    );
  }

  bool _handleScrollNotification(ScrollNotification notification) {
    if (notification is ScrollUpdateNotification ||
        notification is OverscrollNotification) {
      // Any movements always makes the scrollbar start showing up.
      if (_fadeoutAnimationController.status != AnimationStatus.forward) {
        _fadeoutAnimationController.forward();
      }

      _fadeoutTimer?.cancel();
      _painter.update(notification.metrics, notification.metrics.axisDirection);
    } else if (notification is ScrollEndNotification) {
      // On iOS, the scrollbar can only go away once the user lifted the finger.

      _fadeoutTimer?.cancel();
      _fadeoutTimer = new Timer(_kScrollbarTimeToFade, () {
        _fadeoutAnimationController.reverse();
        _fadeoutTimer = null;
      });
    }
    return false;
  }

  @override
  void dispose() {
    _fadeoutAnimationController.dispose();
    _fadeoutTimer?.cancel();
    _painter.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return new NotificationListener<ScrollNotification>(
      onNotification: _handleScrollNotification,
      child: new RepaintBoundary(
        child: new CustomPaint(
          foregroundPainter: _painter,
          child: new RepaintBoundary(
            child: widget.child,
          ),
        ),
      ),
    );
  }
}
