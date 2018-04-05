// Copyright 2016 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:ui' as ui;

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/animation.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';

import '../scheduler/scheduler_tester.dart';

void main() {
  setUp(() {
    WidgetsFlutterBinding.ensureInitialized();
    WidgetsBinding.instance.resetEpoch();
    ui.window.onBeginFrame = null;
    ui.window.onDrawFrame = null;
  });

  test('Can set value during status callback', () {
    final AnimationController controller = new AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: const TestVSync(),
    );
    bool didComplete = false;
    bool didDismiss = false;
    controller.addStatusListener((AnimationStatus status) {
      if (status == AnimationStatus.completed) {
        didComplete = true;
        controller.value = 0.0;
        controller.forward();
      } else if (status == AnimationStatus.dismissed) {
        didDismiss = true;
        controller.value = 0.0;
        controller.forward();
      }
    });

    controller.forward();
    expect(didComplete, isFalse);
    expect(didDismiss, isFalse);
    tick(const Duration(seconds: 1));
    expect(didComplete, isFalse);
    expect(didDismiss, isFalse);
    tick(const Duration(seconds: 2));
    expect(didComplete, isTrue);
    expect(didDismiss, isTrue);

    controller.stop();
  });

  test('Receives status callbacks for forward and reverse', () {
    final AnimationController controller = new AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: const TestVSync(),
    );
    final List<double> valueLog = <double>[];
    final List<AnimationStatus> log = <AnimationStatus>[];
    controller
      ..addStatusListener(log.add)
      ..addListener(() {
        valueLog.add(controller.value);
      });

    expect(log, equals(<AnimationStatus>[]));
    expect(valueLog, equals(<AnimationStatus>[]));

    controller.forward();

    expect(log, equals(<AnimationStatus>[AnimationStatus.forward]));
    expect(valueLog, equals(<AnimationStatus>[]));

    controller.reverse();

    expect(log, equals(<AnimationStatus>[AnimationStatus.forward, AnimationStatus.dismissed]));
    expect(valueLog, equals(<AnimationStatus>[]));

    controller.reverse();

    expect(log, equals(<AnimationStatus>[AnimationStatus.forward, AnimationStatus.dismissed]));
    expect(valueLog, equals(<AnimationStatus>[]));

    log.clear();
    controller.forward();

    expect(log, equals(<AnimationStatus>[AnimationStatus.forward]));
    expect(valueLog, equals(<AnimationStatus>[]));

    controller.forward();

    expect(log, equals(<AnimationStatus>[AnimationStatus.forward]));
    expect(valueLog, equals(<AnimationStatus>[]));

    controller.reverse();
    log.clear();

    tick(const Duration(seconds: 10));
    expect(log, equals(<AnimationStatus>[]));
    expect(valueLog, equals(<AnimationStatus>[]));
    tick(const Duration(seconds: 20));
    expect(log, equals(<AnimationStatus>[]));
    expect(valueLog, equals(<AnimationStatus>[]));
    tick(const Duration(seconds: 30));
    expect(log, equals(<AnimationStatus>[]));
    expect(valueLog, equals(<AnimationStatus>[]));
    tick(const Duration(seconds: 40));
    expect(log, equals(<AnimationStatus>[]));
    expect(valueLog, equals(<AnimationStatus>[]));

    controller.stop();
  });

  test('Forward and reverse from values', () {
    final AnimationController controller = new AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: const TestVSync(),
    );
    final List<double> valueLog = <double>[];
    final List<AnimationStatus> statusLog = <AnimationStatus>[];
    controller
      ..addStatusListener(statusLog.add)
      ..addListener(() {
        valueLog.add(controller.value);
      });

    controller.reverse(from: 0.2);
    expect(statusLog, equals(<AnimationStatus>[ AnimationStatus.reverse ]));
    expect(valueLog, equals(<double>[ 0.2 ]));
    expect(controller.value, equals(0.2));
    statusLog.clear();
    valueLog.clear();

    controller.forward(from: 0.0);
    expect(statusLog, equals(<AnimationStatus>[ AnimationStatus.dismissed, AnimationStatus.forward ]));
    expect(valueLog, equals(<double>[ 0.0 ]));
    expect(controller.value, equals(0.0));
  });

  test('Forward only from value', () {
    final AnimationController controller = new AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: const TestVSync(),
    );
    final List<double> valueLog = <double>[];
    final List<AnimationStatus> statusLog = <AnimationStatus>[];
    controller
      ..addStatusListener(statusLog.add)
      ..addListener(() {
        valueLog.add(controller.value);
      });

    controller.forward(from: 0.2);
    expect(statusLog, equals(<AnimationStatus>[ AnimationStatus.forward ]));
    expect(valueLog, equals(<double>[ 0.2 ]));
    expect(controller.value, equals(0.2));
  });

  test('Can fling to upper and lower bounds', () {
    final AnimationController controller = new AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: const TestVSync(),
    );

    controller.fling();
    tick(const Duration(seconds: 1));
    tick(const Duration(seconds: 2));
    expect(controller.value, 1.0);
    controller.stop();

    final AnimationController largeRangeController = new AnimationController(
      duration: const Duration(milliseconds: 100),
      lowerBound: -30.0,
      upperBound: 45.0,
      vsync: const TestVSync(),
    );

    largeRangeController.fling();
    tick(const Duration(seconds: 3));
    tick(const Duration(seconds: 4));
    expect(largeRangeController.value, 45.0);
    largeRangeController.fling(velocity: -1.0);
    tick(const Duration(seconds: 5));
    tick(const Duration(seconds: 6));
    expect(largeRangeController.value, -30.0);
    largeRangeController.stop();
  });

  test('lastElapsedDuration control test', () {
    final AnimationController controller = new AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: const TestVSync(),
    );
    controller.forward();
    tick(const Duration(milliseconds: 20));
    tick(const Duration(milliseconds: 30));
    tick(const Duration(milliseconds: 40));
    expect(controller.lastElapsedDuration, equals(const Duration(milliseconds: 20)));
    controller.stop();
  });

  test('toString control test', () {
    final AnimationController controller = new AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: const TestVSync(),
    );
    expect(controller, hasOneLineDescription);
    controller.forward();
    tick(const Duration(milliseconds: 10));
    tick(const Duration(milliseconds: 20));
    expect(controller, hasOneLineDescription);
    tick(const Duration(milliseconds: 30));
    expect(controller, hasOneLineDescription);
    controller.reverse();
    tick(const Duration(milliseconds: 40));
    tick(const Duration(milliseconds: 50));
    expect(controller, hasOneLineDescription);
    controller.stop();
  });

  test('velocity test - linear', () {
    final AnimationController controller = new AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: const TestVSync(),
    );

    // mid-flight
    controller.forward();
    tick(const Duration(milliseconds: 0));
    tick(const Duration(milliseconds: 500));
    expect(controller.velocity, inInclusiveRange(0.9, 1.1));

    // edges
    controller.forward();
    expect(controller.velocity, inInclusiveRange(0.4, 0.6));
    tick(Duration.ZERO);
    expect(controller.velocity, inInclusiveRange(0.4, 0.6));
    tick(const Duration(milliseconds: 5));
    expect(controller.velocity, inInclusiveRange(0.9, 1.1));

    controller.forward(from: 0.5);
    expect(controller.velocity, inInclusiveRange(0.4, 0.6));
    tick(Duration.ZERO);
    expect(controller.velocity, inInclusiveRange(0.4, 0.6));
    tick(const Duration(milliseconds: 5));
    expect(controller.velocity, inInclusiveRange(0.9, 1.1));

    // stopped
    controller.forward(from: 1.0);
    expect(controller.velocity, 0.0);
    tick(Duration.ZERO);
    expect(controller.velocity, 0.0);
    tick(const Duration(milliseconds: 500));
    expect(controller.velocity, 0.0);

    controller.forward();
    tick(Duration.ZERO);
    tick(const Duration(milliseconds: 1000));
    expect(controller.velocity, 0.0);

    controller.stop();
  });

  test('Disposed AnimationController toString works', () {
    final AnimationController controller = new AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: const TestVSync(),
    );
    controller.dispose();
    expect(controller, hasOneLineDescription);
  });

  test('AnimationController error handling', () {
    final AnimationController controller = new AnimationController(
      vsync: const TestVSync(),
    );

    expect(controller.forward, throwsFlutterError);
    expect(controller.reverse, throwsFlutterError);
    expect(() { controller.animateTo(0.5); }, throwsFlutterError);
    expect(controller.repeat, throwsFlutterError);

    controller.dispose();
    expect(controller.dispose, throwsFlutterError);
  });

  test('AnimationController repeat() throws if period is not specified', () {
    final AnimationController controller = new AnimationController(
      vsync: const TestVSync(),
    );
    expect(() { controller.repeat(); }, throwsFlutterError);
    expect(() { controller.repeat(period: null); }, throwsFlutterError);
  });

  test('Do not animate if already at target', () {
    final List<AnimationStatus> statusLog = <AnimationStatus>[];

    final AnimationController controller = new AnimationController(
      value: 0.5,
      vsync: const TestVSync(),
    )..addStatusListener(statusLog.add);

    expect(controller.value, equals(0.5));
    controller.animateTo(0.5, duration: const Duration(milliseconds: 100));
    expect(statusLog, equals(<AnimationStatus>[ AnimationStatus.completed ]));
    expect(controller.value, equals(0.5));
  });

  test('Do not animate to upperBound if already at upperBound', () {
    final List<AnimationStatus> statusLog = <AnimationStatus>[];

    final AnimationController controller = new AnimationController(
      value: 1.0,
      upperBound: 1.0,
      lowerBound: 0.0,
      vsync: const TestVSync(),
    )..addStatusListener(statusLog.add);

    expect(controller.value, equals(1.0));
    controller.animateTo(1.0, duration: const Duration(milliseconds: 100));
    expect(statusLog, equals(<AnimationStatus>[ AnimationStatus.completed ]));
    expect(controller.value, equals(1.0));
  });

  test('Do not animate to lowerBound if already at lowerBound', () {
    final List<AnimationStatus> statusLog = <AnimationStatus>[];

    final AnimationController controller = new AnimationController(
      value: 0.0,
      upperBound: 1.0,
      lowerBound: 0.0,
      vsync: const TestVSync(),
    )..addStatusListener(statusLog.add);

    expect(controller.value, equals(0.0));
    controller.animateTo(0.0, duration: const Duration(milliseconds: 100));
    expect(statusLog, equals(<AnimationStatus>[ AnimationStatus.completed ]));
    expect(controller.value, equals(0.0));
  });

  test('Do not animate if already at target mid-flight (forward)', () {
    final List<AnimationStatus> statusLog = <AnimationStatus>[];
    final AnimationController controller = new AnimationController(
      value: 0.0,
      duration: const Duration(milliseconds: 1000),
      vsync: const TestVSync(),
    )..addStatusListener(statusLog.add);

    expect(controller.value, equals(0.0));

    controller.forward();
    tick(const Duration(milliseconds: 0));
    tick(const Duration(milliseconds: 500));
    expect(controller.value, inInclusiveRange(0.4, 0.6));
    expect(statusLog, equals(<AnimationStatus>[ AnimationStatus.forward ]));

    final double currentValue = controller.value;
    controller.animateTo(currentValue, duration: const Duration(milliseconds: 100));
    expect(statusLog, equals(<AnimationStatus>[ AnimationStatus.forward, AnimationStatus.completed ]));
    expect(controller.value, currentValue);
  });

  test('Do not animate if already at target mid-flight (reverse)', () {
    final List<AnimationStatus> statusLog = <AnimationStatus>[];
    final AnimationController controller = new AnimationController(
      value: 1.0,
      duration: const Duration(milliseconds: 1000),
      vsync: const TestVSync(),
    )..addStatusListener(statusLog.add);

    expect(controller.value, equals(1.0));

    controller.reverse();
    tick(const Duration(milliseconds: 0));
    tick(const Duration(milliseconds: 500));
    expect(controller.value, inInclusiveRange(0.4, 0.6));
    expect(statusLog, equals(<AnimationStatus>[ AnimationStatus.reverse ]));

    final double currentValue = controller.value;
    controller.animateTo(currentValue, duration: const Duration(milliseconds: 100));
    expect(statusLog, equals(<AnimationStatus>[ AnimationStatus.reverse, AnimationStatus.completed ]));
    expect(controller.value, currentValue);
  });

  test('animateTo can deal with duration == Duration.ZERO', () {
    final AnimationController controller = new AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: const TestVSync(),
    );

    controller.forward(from: 0.2);
    expect(controller.value, 0.2);
    controller.animateTo(1.0, duration: Duration.ZERO);
    expect(SchedulerBinding.instance.transientCallbackCount, equals(0), reason: 'Expected no animation.');
    expect(controller.value, 1.0);
  });

  test('resetting animation works at all phases', () {
    final List<AnimationStatus> statusLog = <AnimationStatus>[];
    final AnimationController controller = new AnimationController(
      duration: const Duration(milliseconds: 100),
      value: 0.0,
      lowerBound: 0.0,
      upperBound: 1.0,
      vsync: const TestVSync(),
    )..addStatusListener(statusLog.add);

    expect(controller.value, 0.0);
    expect(controller.status, AnimationStatus.dismissed);

    controller.reset();

    expect(controller.value, 0.0);
    expect(controller.status, AnimationStatus.dismissed);

    statusLog.clear();
    controller.forward();
    tick(const Duration(milliseconds: 0));
    tick(const Duration(milliseconds: 50));
    expect(controller.status, AnimationStatus.forward);
    controller.reset();

    expect(controller.value, 0.0);
    expect(controller.status, AnimationStatus.dismissed);
    expect(statusLog, equals(<AnimationStatus>[ AnimationStatus.forward, AnimationStatus.dismissed ]));

    controller.value = 1.0;
    statusLog.clear();
    controller.reverse();
    tick(const Duration(milliseconds: 0));
    tick(const Duration(milliseconds: 50));
    expect(controller.status, AnimationStatus.reverse);
    controller.reset();

    expect(controller.value, 0.0);
    expect(controller.status, AnimationStatus.dismissed);
    expect(statusLog, equals(<AnimationStatus>[ AnimationStatus.reverse, AnimationStatus.dismissed ]));

    statusLog.clear();
    controller.forward();
    tick(const Duration(milliseconds: 0));
    tick(const Duration(milliseconds: 150));
    expect(controller.status, AnimationStatus.completed);
    controller.reset();

    expect(controller.value, 0.0);
    expect(controller.status, AnimationStatus.dismissed);
    expect(statusLog, equals(<AnimationStatus>[ AnimationStatus.forward, AnimationStatus.completed, AnimationStatus.dismissed ]));
  });

  test('setting value directly sets correct status', () {
    final AnimationController controller = new AnimationController(
      value: 0.0,
      lowerBound: 0.0,
      upperBound: 1.0,
      vsync: const TestVSync(),
    );

    expect(controller.value, 0.0);
    expect(controller.status, AnimationStatus.dismissed);

    controller.value = 0.5;
    expect(controller.value, 0.5);
    expect(controller.status, AnimationStatus.forward);

    controller.value = 1.0;
    expect(controller.value, 1.0);
    expect(controller.status, AnimationStatus.completed);

    controller.value = 0.5;
    expect(controller.value, 0.5);
    expect(controller.status, AnimationStatus.forward);

    controller.value = 0.0;
    expect(controller.value, 0.0);
    expect(controller.status, AnimationStatus.dismissed);
  });

  test('animateTo sets correct status', () {
    final List<AnimationStatus> statusLog = <AnimationStatus>[];
    final AnimationController controller = new AnimationController(
      duration: const Duration(milliseconds: 100),
      value: 0.0,
      lowerBound: 0.0,
      upperBound: 1.0,
      vsync: const TestVSync(),
    )..addStatusListener(statusLog.add);

    expect(controller.value, 0.0);
    expect(controller.status, AnimationStatus.dismissed);

    // Animate from 0.0 to 0.5
    controller.animateTo(0.5);
    tick(const Duration(milliseconds: 0));
    tick(const Duration(milliseconds: 150));
    expect(controller.value, 0.5);
    expect(statusLog, equals(<AnimationStatus>[ AnimationStatus.forward, AnimationStatus.completed ]));
    statusLog.clear();

    // Animate from 0.5 to 1.0
    controller.animateTo(1.0);
    tick(const Duration(milliseconds: 0));
    tick(const Duration(milliseconds: 150));
    expect(controller.value, 1.0);
    expect(statusLog, equals(<AnimationStatus>[ AnimationStatus.forward, AnimationStatus.completed ]));
    statusLog.clear();

    // Animate from 1.0 to 0.5
    controller.animateTo(0.5);
    tick(const Duration(milliseconds: 0));
    tick(const Duration(milliseconds: 150));
    expect(controller.value, 0.5);
    expect(statusLog, equals(<AnimationStatus>[ AnimationStatus.forward, AnimationStatus.completed ]));
    statusLog.clear();

    // Animate from 0.5 to 1.0
    controller.animateTo(0.0);
    tick(const Duration(milliseconds: 0));
    tick(const Duration(milliseconds: 150));
    expect(controller.value, 0.0);
    expect(statusLog, equals(<AnimationStatus>[ AnimationStatus.forward, AnimationStatus.completed ]));
    statusLog.clear();
  });

  test('after a reverse call animateTo sets correct status', () {
    final List<AnimationStatus> statusLog = <AnimationStatus>[];
    final AnimationController controller = new AnimationController(
      duration: const Duration(milliseconds: 100),
      value: 1.0,
      lowerBound: 0.0,
      upperBound: 1.0,
      vsync: const TestVSync(),
    )..addStatusListener(statusLog.add);

    expect(controller.value, 1.0);
    expect(controller.status, AnimationStatus.completed);

    controller.reverse();
    tick(const Duration(milliseconds: 0));
    tick(const Duration(milliseconds: 150));
    expect(controller.value, 0.0);
    expect(statusLog, equals(<AnimationStatus>[ AnimationStatus.reverse, AnimationStatus.dismissed ]));
    statusLog.clear();

    controller.animateTo(0.5);
    tick(const Duration(milliseconds: 0));
    tick(const Duration(milliseconds: 150));
    expect(controller.value, 0.5);
    expect(statusLog, equals(<AnimationStatus>[ AnimationStatus.forward, AnimationStatus.completed ]));
    statusLog.clear();
  });

  test('after a forward call animateTo sets correct status', () {
    final List<AnimationStatus> statusLog = <AnimationStatus>[];
    final AnimationController controller = new AnimationController(
      duration: const Duration(milliseconds: 100),
      value: 0.0,
      lowerBound: 0.0,
      upperBound: 1.0,
      vsync: const TestVSync(),
    )..addStatusListener(statusLog.add);

    expect(controller.value, 0.0);
    expect(controller.status, AnimationStatus.dismissed);

    controller.forward();
    tick(const Duration(milliseconds: 0));
    tick(const Duration(milliseconds: 150));
    expect(controller.value, 1.0);
    expect(statusLog, equals(<AnimationStatus>[ AnimationStatus.forward, AnimationStatus.completed ]));
    statusLog.clear();

    controller.animateTo(0.5);
    tick(const Duration(milliseconds: 0));
    tick(const Duration(milliseconds: 150));
    expect(controller.value, 0.5);
    expect(statusLog, equals(<AnimationStatus>[ AnimationStatus.forward, AnimationStatus.completed ]));
    statusLog.clear();
  });
}
