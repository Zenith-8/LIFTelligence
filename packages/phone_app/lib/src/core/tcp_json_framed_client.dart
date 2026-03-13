import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

class TcpJsonFramedClient {
  TcpJsonFramedClient({
    required this.host,
    required this.port,
    this.connectTimeout = const Duration(seconds: 4),
    this.requestTimeout = const Duration(seconds: 4),
  });

  final String host;
  final int port;
  final Duration connectTimeout;
  final Duration requestTimeout;

  Future<Map<String, Object?>> request(Map<String, Object?> json) async {
    final socket = await Socket.connect(host, port, timeout: connectTimeout);
    try {
      socket.setOption(SocketOption.tcpNoDelay, true);

      final payload = utf8.encode(jsonEncode(json));
      final header = ByteData(4)..setUint32(0, payload.length, Endian.big);
      socket.add(header.buffer.asUint8List());
      socket.add(payload);
      await socket.flush();

      final responseBytes = await _readOneFrame(socket).timeout(requestTimeout);
      final decoded = jsonDecode(utf8.decode(responseBytes));
      if (decoded is! Map) {
        throw const FormatException('Response JSON is not an object');
      }
      return decoded.cast<String, Object?>();
    } finally {
      socket.destroy();
    }
  }

  Future<Uint8List> _readOneFrame(Socket socket) async {
    final header = await _readExact(socket, 4);
    final length = ByteData.sublistView(header).getUint32(0, Endian.big);
    if (length > 1024 * 1024) {
      throw const FormatException('Frame too large');
    }
    return _readExact(socket, length);
  }

  Future<Uint8List> _readExact(Socket socket, int n) async {
    final chunks = <Uint8List>[];
    var remaining = n;

    await for (final data in socket) {
      if (data.isEmpty) continue;
      final take = data.length <= remaining ? data.length : remaining;
      chunks.add(Uint8List.sublistView(data, 0, take));
      remaining -= take;
      if (remaining == 0) break;
    }

    if (remaining != 0) {
      throw const SocketException('Connection closed before full frame received');
    }

    final out = Uint8List(n);
    var offset = 0;
    for (final c in chunks) {
      out.setRange(offset, offset + c.length, c);
      offset += c.length;
    }
    return out;
  }
}

