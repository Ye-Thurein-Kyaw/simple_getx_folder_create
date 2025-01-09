import 'dart:async';

extension StreamListToBytes on Stream<List<int>> {
  Future<List<int>> toBytes() async {
    final completer = Completer<List<int>>();
    final bytes = <int>[];

    listen(
      bytes.addAll,
      onDone: () => completer.complete(bytes),
      onError: completer.completeError,
    );

    return completer.future;
  }
}
