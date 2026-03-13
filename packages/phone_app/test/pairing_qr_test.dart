import 'package:flutter_test/flutter_test.dart';
import 'package:phone_app/src/core/pairing_qr.dart';

void main() {
  test('parsePairingQr parses liftelligence URI', () {
    final data = parsePairingQr(
      'liftelligence://pair?host=192.168.1.10&port=5001&token=ABCDEF',
    );
    expect(data.host, '192.168.1.10');
    expect(data.port, 5001);
    expect(data.token, 'ABCDEF');
  });

  test('parsePairingQr accepts raw token fallback', () {
    final data = parsePairingQr('A1B2C3D4E5F6');
    expect(data.token, 'A1B2C3D4E5F6');
    expect(data.host, isEmpty);
    expect(data.port, 0);
  });
}
