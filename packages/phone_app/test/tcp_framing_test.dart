import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:phone_app/src/core/tcp_json_framed_client.dart';

void main() {
  test('TcpJsonFramedClient sends length-prefixed JSON', () async {
    final server = await ServerSocket.bind(InternetAddress.loopbackIPv4, 0);
    addTearDown(() async => server.close());

    final seen = Completer<Map<String, Object?>>();
    unawaited(() async {
      final socket = await server.first;
      final header = await _readExact(socket, 4);
      final len = ByteData.sublistView(header).getUint32(0, Endian.big);
      final payload = await _readExact(socket, len);
      final json = jsonDecode(utf8.decode(payload)) as Map;
      seen.complete(json.cast<String, Object?>());

      final response = utf8.encode('{"type":"login_response","ok":true,"first":"A","last":"B"}');
      final respHeader = ByteData(4)..setUint32(0, response.length, Endian.big);
      socket.add(respHeader.buffer.asUint8List());
      socket.add(response);
      await socket.flush();
      socket.destroy();
    }());

    final client = TcpJsonFramedClient(host: '127.0.0.1', port: server.port);
    final resp = await client.request({'type': 'login', 'uid': 'X', 'machine': 'Y'});

    expect(await seen.future, {'type': 'login', 'uid': 'X', 'machine': 'Y'});
    expect(resp['type'], 'login_response');
    expect(resp['ok'], true);
  });
}

Future<Uint8List> _readExact(Socket socket, int n) async {
  final chunks = <Uint8List>[];
  var remaining = n;
  await for (final data in socket) {
    final take = data.length <= remaining ? data.length : remaining;
    chunks.add(Uint8List.sublistView(data, 0, take));
    remaining -= take;
    if (remaining == 0) break;
  }
  if (remaining != 0) {
    throw StateError('socket closed early');
  }
  final out = Uint8List(n);
  var offset = 0;
  for (final c in chunks) {
    out.setRange(offset, offset + c.length, c);
    offset += c.length;
  }
  return out;
}


