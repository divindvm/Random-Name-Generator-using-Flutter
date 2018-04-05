// Copyright 2015 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

import 'colors.dart';
import 'constants.dart';
import 'debug.dart';
import 'theme.dart';
import 'typography.dart';

/// A material design slider.
///
/// Used to select from a range of values.
///
/// A slider can be used to select from either a continuous or a discrete set of
/// values. The default is use a continuous range of values from [min] to [max].
/// To use discrete values, use a non-null value for [divisions], which
/// indicates the number of discrete intervals. For example, if [min] is 0.0 and
/// [max] is 50.0 and [divisions] is 5, then the slider can take on the values
/// discrete values 0.0, 10.0, 20.0, 30.0, 40.0, and 50.0.
///
/// The slider will be disabled if [onChanged] is null or if the range given by
/// [min]..[max] is empty (i.e. if [min] is equal to [max]).
///
/// The slider itself does not maintain any state. Instead, when the state of
/// the slider changes, the widget calls the [onChanged] callback. Most widgets
/// that use a slider will listen for the [onChanged] callback and rebuild the
/// slider with a new [value] to update the visual appearance of the slider.
///
/// By default, a slider will be as wide as possible, centered vertically. When
/// given unbounded constraints, it will attempt to make the track 144 pixels
/// wide (with margins on each side) and will shrink-wrap vertically.
///
/// Requires one of its ancestors to be a [Material] widget.
///
/// See also:
///
///  * [Radio], for selecting among a set of explicit values.
///  * [Checkbox] and [Switch], for toggling a particular value on or off.
///  * <https://material.google.com/components/sliders.html>
class Slider extends StatefulWidget {
  /// Creates a material design slider.
  ///
  /// The slider itself does not maintain any state. Instead, when the state of
  /// the slider changes, the widget calls the [onChanged] callback. Most widgets
  /// that use a slider will listen for the [onChanged] callback and rebuild the
  /// slider with a new [value] to update the visual appearance of the slider.
  ///
  /// * [value] determines currently selected value for this slider.
  /// * [onChanged] is called when the user selects a new value for the slider.
  const Slider({
    Key key,
    @required this.value,
    @required this.onChanged,
    this.min: 0.0,
    this.max: 1.0,
    this.divisions,
    this.label,
    this.activeColor,
    this.inactiveColor,
    this.thumbOpenAtMin: false,
  }) : assert(value != null),
       assert(min != null),
       assert(max != null),
       assert(min <= max),
       assert(value >= min && value <= max),
       assert(divisions == null || divisions > 0),
       assert(thumbOpenAtMin != null),
       super(key: key);

  /// The currently selected value for this slider.
  ///
  /// The slider's thumb is drawn at a position that corresponds to this value.
  final double value;

  /// Called when the user selects a new value for the slider.
  ///
  /// The slider passes the new value to the callback but does not actually
  /// change state until the parent widget rebuilds the slider with the new
  /// value.
  ///
  /// If null, the slider will be displayed as disabled.
  ///
  /// The callback provided to onChanged should update the state of the parent
  /// [StatefulWidget] using the [State.setState] method, so that the parent
  /// gets rebuilt; for example:
  ///
  /// ```dart
  /// new Slider(
  ///   value: _duelCommandment.toDouble(),
  ///   min: 1.0,
  ///   max: 10.0,
  ///   divisions: 10,
  ///   label: '$_duelCommandment',
  ///   onChanged: (double newValue) {
  ///     setState(() {
  ///       _duelCommandment = newValue.round();
  ///     });
  ///   },
  /// )
  /// ```
  final ValueChanged<double> onChanged;

  /// The minimum value the user can select.
  ///
  /// Defaults to 0.0. Must be less than or equal to [max].
  ///
  /// If the [max] is equal to the [min], then the slider is disabled.
  final double min;

  /// The maximum value the user can select.
  ///
  /// Defaults to 1.0. Must be greater than or equal to [min].
  ///
  /// If the [max] is equal to the [min], then the slider is disabled.
  final double max;

  /// The number of discrete divisions.
  ///
  /// Typically used with [label] to show the current discrete value.
  ///
  /// If null, the slider is continuous.
  final int divisions;

  /// A label to show above the slider when the slider is active.
  ///
  /// Typically used to display the value of a discrete slider.
  final String label;

  /// The color to use for the portion of the slider that has been selected.
  ///
  /// Defaults to accent color of the current [Theme].
  final Color activeColor;

  /// The color for the unselected portion of the slider.
  ///
  /// Defaults to the unselected widget color of the current [Theme].
  final Color inactiveColor;

  /// Whether the thumb should be an open circle when the slider is at its minimum position.
  ///
  /// When this property is false, the thumb does not change when it the slider
  /// reaches its minimum position.
  ///
  /// This property is useful, for example, when the minimum value represents a
  /// qualitatively different state. For a slider that controls the volume of
  /// a sound, for example, the minimum value represents "no sound at all,"
  /// which is qualitatively different from even a very soft sound.
  ///
  /// Defaults to false.
  final bool thumbOpenAtMin;

  @override
  _SliderState createState() => new _SliderState();

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder description) {
    super.debugFillProperties(description);
    description.add(new DoubleProperty('value', value));
    description.add(new DoubleProperty('min', min));
    description.add(new DoubleProperty('max', max));
  }
}

class _SliderState extends State<Slider> with TickerProviderStateMixin {
  _SliderState() {
    _reactionController = new AnimationController(
      duration: kRadialReactionDuration,
      vsync: this,
    );
  }

  void _handleChanged(double value) {
    assert(widget.onChanged != null);
    widget.onChanged(value * (widget.max - widget.min) + widget.min);
  }

  @override
  void dispose() {
    _reactionController?.dispose();
    super.dispose();
  }

  // Have to keep the reaction controller here so that we may dispose of it
  // properly.
  AnimationController _reactionController;

  @override
  Widget build(BuildContext context) {
    assert(debugCheckHasMaterial(context));
    final ThemeData theme = Theme.of(context);
    return new _SliderRenderObjectWidget(
      value: widget.max > widget.min ? (widget.value - widget.min) / (widget.max - widget.min) : 0.0,
      divisions: widget.divisions,
      label: widget.label,
      activeColor: widget.activeColor ?? theme.accentColor,
      inactiveColor: widget.inactiveColor ?? theme.unselectedWidgetColor,
      thumbOpenAtMin: widget.thumbOpenAtMin,
      textTheme: theme.accentTextTheme,
      textScaleFactor: MediaQuery.of(context, nullOk: true)?.textScaleFactor ?? 1.0,
      onChanged: (widget.onChanged != null) && (widget.max > widget.min) ? _handleChanged : null,
      vsync: this,
      reactionController: _reactionController,
    );
  }
}

class _SliderRenderObjectWidget extends LeafRenderObjectWidget {
  const _SliderRenderObjectWidget({
    Key key,
    this.value,
    this.divisions,
    this.label,
    this.activeColor,
    this.inactiveColor,
    this.thumbOpenAtMin,
    this.textTheme,
    this.textScaleFactor,
    this.onChanged,
    this.vsync,
    this.reactionController,
  }) : super(key: key);

  final double value;
  final int divisions;
  final String label;
  final Color activeColor;
  final Color inactiveColor;
  final bool thumbOpenAtMin;
  final TextTheme textTheme;
  final double textScaleFactor;
  final ValueChanged<double> onChanged;
  final TickerProvider vsync;
  final AnimationController reactionController;

  @override
  _RenderSlider createRenderObject(BuildContext context) {
    return new _RenderSlider(
      value: value,
      divisions: divisions,
      label: label,
      activeColor: activeColor,
      inactiveColor: inactiveColor,
      thumbOpenAtMin: thumbOpenAtMin,
      textTheme: textTheme,
      textScaleFactor: textScaleFactor,
      onChanged: onChanged,
      vsync: vsync,
      reactionController: reactionController,
      textDirection: Directionality.of(context),
    );
  }

  @override
  void updateRenderObject(BuildContext context, _RenderSlider renderObject) {
    renderObject
      ..value = value
      ..divisions = divisions
      ..label = label
      ..activeColor = activeColor
      ..inactiveColor = inactiveColor
      ..thumbOpenAtMin = thumbOpenAtMin
      ..textTheme = textTheme
      ..textScaleFactor = textScaleFactor
      ..onChanged = onChanged
      ..textDirection = Directionality.of(context);
      // Ticker provider cannot change since there's a 1:1 relationship between
      // the _SliderRenderObjectWidget object and the _SliderState object.
  }
}

const double _kThumbRadius = 6.0;
const double _kActiveThumbRadius = 9.0;
const double _kDisabledThumbRadius = 4.0;
const double _kReactionRadius = 16.0;
const double _kPreferredTrackWidth = 144.0;
const double _kMinimumTrackWidth = _kActiveThumbRadius; // biggest of the thumb radii
const double _kPreferredTotalWidth = _kPreferredTrackWidth + 2 * _kReactionRadius;
const double _kMinimumTotalWidth = _kMinimumTrackWidth + 2 * _kReactionRadius;

final Color _kActiveTrackColor = Colors.grey;
final Tween<double> _kReactionRadiusTween = new Tween<double>(begin: _kThumbRadius, end: _kReactionRadius);
final Tween<double> _kThumbRadiusTween = new Tween<double>(begin: _kThumbRadius, end: _kActiveThumbRadius);
final ColorTween _kTickColorTween = new ColorTween(begin: Colors.transparent, end: Colors.black54);
const Duration _kDiscreteTransitionDuration = const Duration(milliseconds: 500);

const double _kLabelBalloonRadius = 14.0;
final Tween<double> _kLabelBalloonCenterTween = new Tween<double>(begin: 0.0, end: -_kLabelBalloonRadius * 2.0);
final Tween<double> _kLabelBalloonRadiusTween = new Tween<double>(begin: _kThumbRadius, end: _kLabelBalloonRadius);
final Tween<double> _kLabelBalloonTipTween = new Tween<double>(begin: 0.0, end: -8.0);
final double _kLabelBalloonTipAttachmentRatio = math.sin(math.PI / 4.0);

const double _kAdjustmentUnit = 0.1; // Matches iOS implementation of material slider.

double _getAdditionalHeightForLabel(String label) {
  return label == null ? 0.0 : _kLabelBalloonRadius * 2.0;
}

double _getPreferredTotalHeight(String label) {
  return 2 * _kReactionRadius + _getAdditionalHeightForLabel(label);
}

class _RenderSlider extends RenderBox {
  _RenderSlider({
    @required double value,
    int divisions,
    String label,
    Color activeColor,
    Color inactiveColor,
    bool thumbOpenAtMin,
    TextTheme textTheme,
    double textScaleFactor,
    ValueChanged<double> onChanged,
    TickerProvider vsync,
    @required TextDirection textDirection,
    @required AnimationController reactionController,
  }) : assert(value != null && value >= 0.0 && value <= 1.0),
       assert(textDirection != null),
       _label = label,
       _value = value,
       _divisions = divisions,
       _activeColor = activeColor,
       _inactiveColor = inactiveColor,
       _thumbOpenAtMin = thumbOpenAtMin,
       _textTheme = textTheme,
       _textScaleFactor = textScaleFactor,
       _onChanged = onChanged,
       _textDirection = textDirection {
    _updateLabelPainter();
    final GestureArenaTeam team = new GestureArenaTeam();
    _drag = new HorizontalDragGestureRecognizer()
      ..team = team
      ..onStart = _handleDragStart
      ..onUpdate = _handleDragUpdate
      ..onEnd = _handleDragEnd;
    _tap = new TapGestureRecognizer()
      ..team = team
      ..onTapUp = _handleTapUp;
    _reactionController = reactionController;
    _reaction = new CurvedAnimation(
      parent: _reactionController,
      curve: Curves.fastOutSlowIn
    )..addListener(markNeedsPaint);
    _position = new AnimationController(
      value: value,
      duration: _kDiscreteTransitionDuration,
      vsync: vsync,
    )..addListener(markNeedsPaint);
  }

  double get value => _value;
  double _value;
  set value(double newValue) {
    assert(newValue != null && newValue >= 0.0 && newValue <= 1.0);
    if (newValue == _value)
      return;
    _value = newValue;
    if (divisions != null)
      _position.animateTo(newValue, curve: Curves.fastOutSlowIn);
    else
      _position.value = newValue;
  }

  int get divisions => _divisions;
  int _divisions;
  set divisions(int value) {
    if (value == _divisions)
      return;
    _divisions = value;
    markNeedsPaint();
  }

  String get label => _label;
  String _label;
  set label(String value) {
    if (value == _label)
      return;
    _label = value;
    _updateLabelPainter();
  }

  Color get activeColor => _activeColor;
  Color _activeColor;
  set activeColor(Color value) {
    if (value == _activeColor)
      return;
    _activeColor = value;
    markNeedsPaint();
  }

  Color get inactiveColor => _inactiveColor;
  Color _inactiveColor;
  set inactiveColor(Color value) {
    if (value == _inactiveColor)
      return;
    _inactiveColor = value;
    markNeedsPaint();
  }

  bool get thumbOpenAtMin => _thumbOpenAtMin;
  bool _thumbOpenAtMin;
  set thumbOpenAtMin(bool value) {
    if (value == _thumbOpenAtMin)
      return;
    _thumbOpenAtMin = value;
    markNeedsPaint();
  }

  TextTheme get textTheme => _textTheme;
  TextTheme _textTheme;
  set textTheme(TextTheme value) {
    if (value == _textTheme)
      return;
    _textTheme = value;
    markNeedsPaint();
  }

  double get textScaleFactor => _textScaleFactor;
  double _textScaleFactor;
  set textScaleFactor(double value) {
    if (value == _textScaleFactor)
      return;
    _textScaleFactor = value;
    _updateLabelPainter();
    markNeedsPaint();
  }

  ValueChanged<double> get onChanged => _onChanged;
  ValueChanged<double> _onChanged;
  set onChanged(ValueChanged<double> value) {
    if (value == _onChanged)
      return;
    final bool wasInteractive = isInteractive;
    _onChanged = value;
    if (wasInteractive != isInteractive) {
      markNeedsPaint();
      markNeedsSemanticsUpdate();
    }
  }

  TextDirection get textDirection => _textDirection;
  TextDirection _textDirection;
  set textDirection(TextDirection value) {
    assert(value != null);
    if (value == _textDirection)
      return;
    _textDirection = value;
    _updateLabelPainter();
  }

  void _updateLabelPainter() {
    if (label != null) {
      _labelPainter
        ..text = new TextSpan(
          style: _textTheme.body1.copyWith(fontSize: 10.0 * _textScaleFactor),
          text: label,
        )
        ..textDirection = textDirection
        ..layout();
    } else {
      _labelPainter.text = null;
    }
    // Changing the textDirection can result in the layout changing, because the
    // bidi algorithm might line up the glyphs differently which can result in
    // different ligatures, different shapes, etc. So we always markNeedsLayout.
    markNeedsLayout();
  }

  double get _trackLength => size.width - 2.0 * _kReactionRadius;

  Animation<double> _reaction;
  AnimationController _reactionController;

  AnimationController _position;
  final TextPainter _labelPainter = new TextPainter();

  HorizontalDragGestureRecognizer _drag;
  TapGestureRecognizer _tap;
  bool _active = false;
  double _currentDragValue = 0.0;

  bool get isInteractive => onChanged != null;

  double _getValueFromVisualPosition(double visualPosition) {
    switch (textDirection) {
      case TextDirection.rtl:
        return 1.0 - visualPosition;
      case TextDirection.ltr:
        return visualPosition;
    }
    return null;
  }

  double _getValueFromGlobalPosition(Offset globalPosition) {
    final double visualPosition = (globalToLocal(globalPosition).dx - _kReactionRadius) / _trackLength;
    return _getValueFromVisualPosition(visualPosition);
  }

  double _discretize(double value) {
    double result = value.clamp(0.0, 1.0);
    if (divisions != null)
      result = (result * divisions).round() / divisions;
    return result;
  }

  void _handleDragStart(DragStartDetails details) {
    if (isInteractive) {
      _active = true;
      _currentDragValue = _getValueFromGlobalPosition(details.globalPosition);
      onChanged(_discretize(_currentDragValue));
      _reactionController.forward();
    }
  }

  void _handleDragUpdate(DragUpdateDetails details) {
    if (isInteractive) {
      final double valueDelta = details.primaryDelta / _trackLength;
      switch (textDirection) {
        case TextDirection.rtl:
          _currentDragValue -= valueDelta;
          break;
        case TextDirection.ltr:
          _currentDragValue += valueDelta;
          break;
      }
      onChanged(_discretize(_currentDragValue));
    }
  }

  void _handleDragEnd(DragEndDetails details) {
    if (_active) {
      _active = false;
      _currentDragValue = 0.0;
      _reactionController.reverse();
    }
  }

  void _handleTapUp(TapUpDetails details) {
    if (isInteractive && !_active)
      onChanged(_discretize(_getValueFromGlobalPosition(details.globalPosition)));
  }

  @override
  bool hitTestSelf(Offset position) => true;

  @override
  void handleEvent(PointerEvent event, BoxHitTestEntry entry) {
    assert(debugHandleEvent(event, entry));
    if (event is PointerDownEvent && isInteractive) {
      // We need to add the drag first so that it has priority.
      _drag.addPointer(event);
      _tap.addPointer(event);
    }
  }

  @override
  double computeMinIntrinsicWidth(double height) {
    return _kMinimumTotalWidth;
  }

  @override
  double computeMaxIntrinsicWidth(double height) {
    // This doesn't quite match the definition of computeMaxIntrinsicWidth,
    // but it seems within the spirit...
    return _kPreferredTotalWidth;
  }

  @override
  double computeMinIntrinsicHeight(double width) {
    return _getPreferredTotalHeight(label);
  }

  @override
  double computeMaxIntrinsicHeight(double width) {
    return _getPreferredTotalHeight(label);
  }

  @override
  bool get sizedByParent => true;

  @override
  void performResize() {
    size = new Size(
      constraints.hasBoundedWidth ? constraints.maxWidth : _kPreferredTotalWidth,
      constraints.hasBoundedHeight ? constraints.maxHeight : _getPreferredTotalHeight(label),
    );
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    final Canvas canvas = context.canvas;

    final double trackLength = size.width - 2 * _kReactionRadius;
    final bool enabled = isInteractive;
    final double value = _position.value;
    final bool thumbAtMin = value == 0.0;

    final Paint primaryPaint = new Paint()..color = enabled ? _activeColor : _inactiveColor;
    final Paint trackPaint = new Paint()..color = _inactiveColor;

    double visualPosition;
    Paint leftPaint;
    Paint rightPaint;
    switch (textDirection) {
      case TextDirection.rtl:
        visualPosition = 1.0 - value;
        leftPaint = trackPaint;
        rightPaint = primaryPaint;
        break;
      case TextDirection.ltr:
        visualPosition = value;
        leftPaint = primaryPaint;
        rightPaint = trackPaint;
        break;
    }

    final double additionalHeightForLabel = _getAdditionalHeightForLabel(label);
    final double trackCenter = offset.dy + (size.height - additionalHeightForLabel) / 2.0 + additionalHeightForLabel;
    final double trackLeft = offset.dx + _kReactionRadius;
    final double trackTop = trackCenter - 1.0;
    final double trackBottom = trackCenter + 1.0;
    final double trackRight = trackLeft + trackLength;
    final double trackActive = trackLeft + trackLength * visualPosition;

    final Offset thumbCenter = new Offset(trackActive, trackCenter);
    final double thumbRadius = enabled ? _kThumbRadiusTween.evaluate(_reaction) : _kDisabledThumbRadius;

    if (enabled) {
      if (visualPosition > 0.0)
        canvas.drawRect(new Rect.fromLTRB(trackLeft, trackTop, trackActive, trackBottom), leftPaint);
      if (visualPosition < 1.0) {
        final bool hasBalloon = _reaction.status != AnimationStatus.dismissed && label != null;
        final double trackActiveDelta = hasBalloon ? 0.0 : thumbRadius - 1.0;
        canvas.drawRect(new Rect.fromLTRB(trackActive + trackActiveDelta, trackTop, trackRight, trackBottom), rightPaint);
      }
    } else {
      if (visualPosition > 0.0)
        canvas.drawRect(new Rect.fromLTRB(trackLeft, trackTop, trackActive - _kDisabledThumbRadius - 2, trackBottom), trackPaint);
      if (visualPosition < 1.0)
        canvas.drawRect(new Rect.fromLTRB(trackActive + _kDisabledThumbRadius + 2, trackTop, trackRight, trackBottom), trackPaint);
    }

    if (_reaction.status != AnimationStatus.dismissed) {
      final int divisions = this.divisions;
      if (divisions != null) {
        const double tickWidth = 2.0;
        final double dx = (trackLength - tickWidth) / divisions;
        // If the ticks would be too dense, don't bother painting them.
        if (dx >= 3 * tickWidth) {
          final Paint tickPaint = new Paint()..color = _kTickColorTween.evaluate(_reaction);
          for (int i = 0; i <= divisions; i += 1) {
            final double left = trackLeft + i * dx;
            canvas.drawRect(new Rect.fromLTRB(left, trackTop, left + tickWidth, trackBottom), tickPaint);
          }
        }
      }

      if (label != null) {
        final Offset center = new Offset(
          trackActive,
          _kLabelBalloonCenterTween.evaluate(_reaction) * textScaleFactor + trackCenter
        );
        final double radius = _kLabelBalloonRadiusTween.evaluate(_reaction) * textScaleFactor;
        final Offset tip = new Offset(
          trackActive,
          _kLabelBalloonTipTween.evaluate(_reaction) * textScaleFactor + trackCenter
        );
        final double tipAttachment = _kLabelBalloonTipAttachmentRatio * radius;

        canvas.drawCircle(center, radius, primaryPaint);
        final Path path = new Path()
          ..moveTo(tip.dx, tip.dy)
          ..lineTo(center.dx - tipAttachment, center.dy + tipAttachment)
          ..lineTo(center.dx + tipAttachment, center.dy + tipAttachment)
          ..close();
        canvas.drawPath(path, primaryPaint);
        final Offset labelOffset = new Offset(
          center.dx - _labelPainter.width / 2.0,
          center.dy - _labelPainter.height / 2.0
        );
        _labelPainter.paint(canvas, labelOffset);
        return;
      } else {
        final Color reactionBaseColor = thumbAtMin ? _kActiveTrackColor : _activeColor;
        final Paint reactionPaint = new Paint()..color = reactionBaseColor.withAlpha(kRadialReactionAlpha);
        canvas.drawCircle(thumbCenter, _kReactionRadiusTween.evaluate(_reaction), reactionPaint);
      }
    }

    Paint thumbPaint = primaryPaint;
    double thumbRadiusDelta = 0.0;
    if (thumbAtMin && thumbOpenAtMin) {
      thumbPaint = trackPaint;
      // This is destructive to trackPaint.
      thumbPaint
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0;
      thumbRadiusDelta = -1.0;
    }
    canvas.drawCircle(thumbCenter, thumbRadius + thumbRadiusDelta, thumbPaint);
  }

  @override
  void describeSemanticsConfiguration(SemanticsConfiguration config) {
    super.describeSemanticsConfiguration(config);

    config.isSemanticBoundary = isInteractive;
    if (isInteractive) {
      config.onIncrease = _increaseAction;
      config.onDecrease = _decreaseAction;
    }
  }

  double get _semanticActionUnit => divisions != null ? 1.0 / divisions : _kAdjustmentUnit;

  void _increaseAction() {
    if (isInteractive)
      onChanged((value + _semanticActionUnit).clamp(0.0, 1.0));
  }

  void _decreaseAction() {
    if (isInteractive)
      onChanged((value - _semanticActionUnit).clamp(0.0, 1.0));
  }
}
