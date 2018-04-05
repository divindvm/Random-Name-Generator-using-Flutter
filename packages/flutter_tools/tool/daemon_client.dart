// Copyright 2015 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:convert';

import 'package:flutter_tools/src/base/io.dart';

Process daemon;

// To use, start from the console and enter:
//   version: print version
//   shutdown: terminate the server
//   start: start an app
//   stop: stop a running app
//   devices: list devices

Future<Null> main() async {
  daemon = await Process.start('dart', <String>['bin/flutter_tools.dart', 'daemon']);
  print('daemon process started, pid: ${daemon.pid}');

  daemon.stdout
    .transform(UTF8.decoder)
    .transform(const LineSplitter())
    .listen((String line) => print('<== $line'));
  daemon.stderr.listen((dynamic data) => stderr.add(data));

  stdout.write('> ');
  stdin.transform(UTF8.decoder).transform(const LineSplitter()).listen((String line) {
    final List<String> words = line.split(' ');

    if (line == 'version' || line == 'v') {
      _send(<String, dynamic>{'method': 'daemon.version'});
    } else if (line == 'shutdown' || line == 'q') {
      _send(<String, dynamic>{'method': 'daemon.shutdown'});
    } else if (words.first == 'start') {
      _send(<String, dynamic>{
        'method': 'app.start',
        'params': <String, dynamic> {
          'deviceId': words[1],
          'projectDirectory': words[2]
        }
      });
    } else if (words.first == 'stop') {
      if (words.length > 1) {
        _send(<String, dynamic>{
          'method': 'app.stop',
          'params': <String, dynamic> { 'appId': words[1] }
        });
      } else {
        _send(<String, dynamic>{'method': 'app.stop'});
      }
    } else if (words.first == 'restart') {
      if (words.length > 1) {
        _send(<String, dynamic>{
          'method': 'app.restart',
          'params': <String, dynamic> { 'appId': words[1] }
        });
      } else {
        _send(<String, dynamic>{'method': 'app.restart'});
      }
    } else if (line == 'devices') {
      _send(<String, dynamic>{'method': 'device.getDevices'});
    } else if (line == 'enable') {
      _send(<String, dynamic>{'method': 'device.enable'});
    } else {
      _send(<String, dynamic>{'method': line.trim()});
    }
    stdout.write('> ');
  });

  daemon.exitCode.then<Null>((int code) {
    print('daemon exiting ($code)');
    exit(code);
  });
}

int id = 0;

void _send(Map<String, dynamic> map) {
  map['id'] = id++;
  final String str = '[${JSON.encode(map)}]';
  daemon.stdin.writeln(str);
  print('==> $str');
}
