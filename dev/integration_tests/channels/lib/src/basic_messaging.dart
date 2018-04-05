// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'test_step.dart';

Future<TestStepResult> basicBinaryHandshake(ByteData message) async {
  const BasicMessageChannel<ByteData> channel =
      const BasicMessageChannel<ByteData>(
    'binary-msg',
    const BinaryCodec(),
  );
  return _basicMessageHandshake<ByteData>(
      'Binary >${toString(message)}<', channel, message);
}

Future<TestStepResult> basicStringHandshake(String message) async {
  const BasicMessageChannel<String> channel = const BasicMessageChannel<String>(
    'string-msg',
    const StringCodec(),
  );
  return _basicMessageHandshake<String>('String >$message<', channel, message);
}

Future<TestStepResult> basicJsonHandshake(dynamic message) async {
  const BasicMessageChannel<dynamic> channel =
      const BasicMessageChannel<dynamic>(
    'json-msg',
    const JSONMessageCodec(),
  );
  return _basicMessageHandshake<dynamic>('JSON >$message<', channel, message);
}

Future<TestStepResult> basicStandardHandshake(dynamic message) async {
  const BasicMessageChannel<dynamic> channel =
      const BasicMessageChannel<dynamic>(
    'std-msg',
    const StandardMessageCodec(),
  );
  return _basicMessageHandshake<dynamic>(
      'Standard >${toString(message)}<', channel, message);
}

Future<TestStepResult> basicBinaryMessageToUnknownChannel() async {
  const BasicMessageChannel<ByteData> channel =
      const BasicMessageChannel<ByteData>(
    'binary-unknown',
    const BinaryCodec(),
  );
  return _basicMessageToUnknownChannel<ByteData>('Binary', channel);
}

Future<TestStepResult> basicStringMessageToUnknownChannel() async {
  const BasicMessageChannel<String> channel = const BasicMessageChannel<String>(
    'string-unknown',
    const StringCodec(),
  );
  return _basicMessageToUnknownChannel<String>('String', channel);
}

Future<TestStepResult> basicJsonMessageToUnknownChannel() async {
  const BasicMessageChannel<dynamic> channel =
      const BasicMessageChannel<dynamic>(
    'json-unknown',
    const JSONMessageCodec(),
  );
  return _basicMessageToUnknownChannel<dynamic>('JSON', channel);
}

Future<TestStepResult> basicStandardMessageToUnknownChannel() async {
  const BasicMessageChannel<dynamic> channel =
      const BasicMessageChannel<dynamic>(
    'std-unknown',
    const StandardMessageCodec(),
  );
  return _basicMessageToUnknownChannel<dynamic>('Standard', channel);
}

/// Sends the specified message to the platform, doing a
/// receive message/send reply/receive reply echo handshake initiated by the
/// platform, then expecting a reply echo to the original message.
///
/// Fails, if an error occurs, or if any message seen is not deeply equal to
/// the original message.
Future<TestStepResult> _basicMessageHandshake<T>(
  String description,
  BasicMessageChannel<T> channel,
  T message,
) async {
  final List<dynamic> received = <dynamic>[];
  channel.setMessageHandler((T message) async {
    received.add(message);
    return message;
  });
  dynamic messageEcho = nothing;
  dynamic error = nothing;
  try {
    messageEcho = await channel.send(message);
  } catch (e) {
    error = e;
  }
  return resultOfHandshake(
    'Basic message handshake',
    description,
    message,
    received,
    messageEcho,
    error,
  );
}

/// Sends a message on a channel that no one listens on.
Future<TestStepResult> _basicMessageToUnknownChannel<T>(
  String description,
  BasicMessageChannel<T> channel,
) async {
  dynamic messageEcho = nothing;
  dynamic error = nothing;
  try {
    messageEcho = await channel.send(null);
  } catch (e) {
    error = e;
  }
  return resultOfHandshake(
    'Message on unknown channel',
    description,
    null,
    <dynamic>[null, null],
    messageEcho,
    error,
  );
}

String toString(dynamic message) {
  if (message is ByteData)
    return message.buffer
        .asUint8List(message.offsetInBytes, message.lengthInBytes)
        .toString();
  else
    return '$message';
}
