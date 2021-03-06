// Copyright (c) 2013, the Dart project authors.  Please see the AUTHORS d.file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:test/test.dart';

import '../descriptor.dart' as d;
import '../serve/utils.dart';
import '../test_pub.dart';

main() {
  // An import error will cause the isolate API to fail synchronously while
  // loading the transformer.
  test("fails to load a transform with an import error", () async {
    await serveBarback();

    await d.dir(appPath, [
      d.pubspec({
        "name": "myapp",
        "transformers": ["myapp/src/transformer"],
        "dependencies": {"barback": "any"}
      }),
      d.dir("lib", [
        d.dir("src",
            [d.file("transformer.dart", "import 'does/not/exist.dart';")])
      ])
    ]).create();

    await pubGet();
    var pub = await startPubServe();
    expect(pub.stderr,
        emitsThrough("Unable to spawn isolate: Unhandled exception:"));
    expect(pub.stderr, emits(startsWith('Could not import "')));
    await pub.shouldExit(1);
  });
}
