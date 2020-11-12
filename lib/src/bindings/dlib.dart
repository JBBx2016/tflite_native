// Copyright (c) 2019, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:ffi';
import 'dart:io';
import 'dart:isolate' show Isolate;

const Set<String> _supported = {'linux64', 'mac64', 'win64'};

/// Computes the shared object filename for this os and architecture.
///
/// Throws an exception if invoked on an unsupported platform.
String _getObjectFilename() {
  final architecture = sizeOf<IntPtr>() == 4 ? '32' : '64';
  String os, extension;
  if (Platform.isLinux) {
    os = 'linux';
    extension = 'so';
  } else if (Platform.isMacOS) {
    os = 'mac';
    extension = 'so';
  } else if (Platform.isWindows) {
    os = 'win';
    extension = 'dll';
  } else {
    throw Exception('Unsupported platform!');
  }

  final result = os + architecture;
  if (!_supported.contains(result)) {
    throw Exception('Unsupported platform: $result!');
  }

  return 'libtensorflowlite_c-$result.$extension';
}

/// TensorFlowLite C library.
DynamicLibrary tflitelib;

Future<void> initTfLiteLib() async {
  final rootLibrary = 'package:tflite_native/tflite.dart';
  final uri = await Isolate.resolvePackageUri(Uri.parse(rootLibrary));
  final blobs = uri
      .resolve('src/blobs/');
  String objectFile = blobs.resolve(_getObjectFilename()).toFilePath();

  tflitelib = DynamicLibrary.open(objectFile);
}
