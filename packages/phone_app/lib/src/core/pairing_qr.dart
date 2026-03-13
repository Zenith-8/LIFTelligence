class PairingQrData {
  const PairingQrData({
    required this.host,
    required this.port,
    required this.token,
  });

  final String host;
  final int port;
  final String token;
}

PairingQrData parsePairingQr(String raw) {
  final s = raw.trim();

  // Accept a full custom-scheme URI.
  if (s.startsWith('liftelligence://')) {
    final uri = Uri.parse(s);
    if (uri.scheme != 'liftelligence') {
      throw const FormatException('Invalid pairing QR scheme');
    }
    if (uri.host != 'pair') {
      throw const FormatException('Invalid pairing QR host');
    }

    final host = uri.queryParameters['host'];
    final portStr = uri.queryParameters['port'];
    final token = uri.queryParameters['token'];

    if (host == null || host.trim().isEmpty) {
      throw const FormatException('Missing host');
    }
    final port = int.tryParse(portStr ?? '');
    if (port == null || port < 1 || port > 65535) {
      throw const FormatException('Invalid port');
    }
    if (token == null || token.trim().isEmpty) {
      throw const FormatException('Missing token');
    }

    return PairingQrData(host: host.trim(), port: port, token: token.trim());
  }

  // Fallback: accept a raw token (requires the app to already know host/port).
  final token = s;
  final tokenOk = RegExp(r'^[A-Fa-f0-9]{16,128}$').hasMatch(token);
  if (!tokenOk) {
    throw const FormatException('Unrecognized QR contents');
  }
  return PairingQrData(host: '', port: 0, token: token);
}
