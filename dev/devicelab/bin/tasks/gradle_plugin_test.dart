// Copyright (c) 2016 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:io';

import 'package:path/path.dart' as path;
import 'package:flutter_devicelab/framework/framework.dart';
import 'package:flutter_devicelab/framework/utils.dart';

String javaHome;

void main() {
  task(() async {
    section('Running flutter doctor to get JAVA_HOME');
    final String flutterDoctor = await evalFlutter('doctor', options: <String>['-v']);
    final RegExp javaHomeExtractor = new RegExp(r'Android Studio at (.*)');
    javaHome = javaHomeExtractor.firstMatch(flutterDoctor).group(1) + '/jre';

    section('Setting up flutter projects');
    final Directory tmp = await Directory.systemTemp.createTemp('gradle');
    final FlutterProject project = await FlutterProject.create(tmp, 'hello');
    final FlutterPluginProject pluginProject = await FlutterPluginProject.create(tmp, 'aaa');

    try {
      section('gradlew assembleDebug');
      await project.runGradleTask('assembleDebug');

      section('gradlew assembleProfile');
      await project.runGradleTask('assembleProfile');

      section('gradlew assembleRelease');
      await project.runGradleTask('assembleRelease');

      section('gradlew assembleLocal (custom debug build)');
      await project.addCustomBuildType('local', initWith: 'debug');
      await project.runGradleTask('assembleLocal');

      section('gradlew assembleBeta (custom release build)');
      await project.addCustomBuildType('beta', initWith: 'release');
      await project.runGradleTask('assembleBeta');

      section('gradlew assembleFreeDebug (product flavor)');
      await project.addProductFlavor('free');
      await project.runGradleTask('assembleFreeDebug');

      await project.introduceError();

      section('gradlew on build script with error');
      {
        final ProcessResult result = await project.resultOfGradleTask('assembleRelease');
        if (result.exitCode == 0)
          return _failure('Gradle did not exit with error as expected', result);
        final String output = result.stdout + '\n' + result.stderr;
        if (output.contains('GradleException') || output.contains('Failed to notify') || output.contains('at org.gradle'))
          return _failure('Gradle output should not contain stacktrace', result);
        if (!output.contains('Build failed') || !output.contains('builTypes'))
          return _failure('Gradle output should contain a readable error message', result);
      }

      section('flutter build apk on build script with error');
      {
        final ProcessResult result = await project.resultOfFlutterCommand('build', <String>['apk']);
        if (result.exitCode == 0)
          return _failure('flutter build apk should fail when Gradle does', result);
        final String output = result.stdout + '\n' + result.stderr;
        if (!output.contains('Build failed') || !output.contains('builTypes'))
          return _failure('flutter build apk output should contain a readable Gradle error message', result);
        if (_hasMultipleOccurrences(output, 'builTypes'))
          return _failure('flutter build apk should not invoke Gradle repeatedly on error', result);
      }

      section('gradlew assembleDebug on plugin example');
      await pluginProject.runGradleTask('assembleDebug');
      if (!pluginProject.hasDebugApk)
        return new TaskResult.failure('Gradle did not produce an apk file at the expected place');

      return new TaskResult.success(null);
    } catch (e) {
      return new TaskResult.failure(e.toString());
    } finally {
      project.parent.deleteSync(recursive: true);
    }
  });
}

TaskResult _failure(String message, ProcessResult result) {
  print('Unexpected process result:');
  print('Exit code: ${result.exitCode}');
  print('Std out  :\n${result.stdout}');
  print('Std err  :\n${result.stderr}');
  return new TaskResult.failure(message);
}

bool _hasMultipleOccurrences(String text, Pattern pattern) {
  return text.indexOf(pattern) != text.lastIndexOf(pattern);
}

class FlutterProject {
  FlutterProject(this.parent, this.name);

  final Directory parent;
  final String name;

  static Future<FlutterProject> create(Directory directory, String name) async {
    await inDirectory(directory, () async {
      await flutter('create', options: <String>[name]);
    });
    return new FlutterProject(directory, name);
  }

  String get rootPath => path.join(parent.path, name);
  String get androidPath => path.join(rootPath, 'android');

  Future<Null> addCustomBuildType(String name, {String initWith}) async {
    final File buildScript = new File(
      path.join(androidPath, 'app', 'build.gradle'),
    );
    buildScript.openWrite(mode: FileMode.APPEND).write('''

android {
    buildTypes {
        $name {
            initWith $initWith
        }
    }
}
    ''');
  }

  Future<Null> addProductFlavor(String name) async {
    final File buildScript = new File(
      path.join(androidPath, 'app', 'build.gradle'),
    );
    buildScript.openWrite(mode: FileMode.APPEND).write('''

android {
    flavorDimensions "mode"
    productFlavors {
        $name {
            applicationIdSuffix ".$name"
            versionNameSuffix "-$name"
        }
    }
}
    ''');
  }

  Future<Null> introduceError() async {
    final File buildScript = new File(
      path.join(androidPath, 'app', 'build.gradle'),
    );
    await buildScript.writeAsString((await buildScript.readAsString()).replaceAll('buildTypes', 'builTypes'));
  }

  Future<Null> runGradleTask(String task) async {
    return _runGradleTask(workingDirectory: androidPath, task: task);
  }

  Future<ProcessResult> resultOfGradleTask(String task) {
    return _resultOfGradleTask(workingDirectory: androidPath, task: task);
  }

  Future<ProcessResult> resultOfFlutterCommand(String command, List<String> options) {
    return Process.run(
      path.join(flutterDirectory.path, 'bin', 'flutter'),
      <String>[command]..addAll(options),
      workingDirectory: rootPath,
    );
  }
}

class FlutterPluginProject {
  FlutterPluginProject(this.parent, this.name);

  final Directory parent;
  final String name;

  static Future<FlutterPluginProject> create(Directory directory, String name) async {
    await inDirectory(directory, () async {
      await flutter('create', options: <String>['-t', 'plugin', name]);
    });
    return new FlutterPluginProject(directory, name);
  }

  String get rootPath => path.join(parent.path, name);
  String get examplePath => path.join(rootPath, 'example');
  String get exampleAndroidPath => path.join(examplePath, 'android');
  String get debugApkPath => path.join(examplePath, 'build', 'app', 'outputs', 'apk', 'debug', 'app-debug.apk');

  Future<Null> runGradleTask(String task) async {
    return _runGradleTask(workingDirectory: exampleAndroidPath, task: task);
  }

  bool get hasDebugApk => new File(debugApkPath).existsSync();
}

Future<Null> _runGradleTask({String workingDirectory, String task}) async {
  final ProcessResult result = await _resultOfGradleTask(workingDirectory: workingDirectory, task: task);
  if (result.exitCode != 0) {
    print('stdout:');
    print(result.stdout);
    print('stderr:');
    print(result.stderr);
  }
  if (result.exitCode != 0)
    throw 'Gradle exited with error';
}

Future<ProcessResult> _resultOfGradleTask({String workingDirectory, String task}) {
  return Process.run(
    './gradlew',
    <String>['app:$task'],
    workingDirectory: workingDirectory,
    environment: <String, String>{ 'JAVA_HOME': javaHome }
  );
}
