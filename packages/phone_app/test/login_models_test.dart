import 'package:flutter_test/flutter_test.dart';
import 'package:phone_app/src/core/models/login_request.dart';
import 'package:phone_app/src/core/models/login_response.dart';

void main() {
  test('LoginRequest encodes expected shape', () {
    const req = LoginRequest(uid: 'ABC', machine: 'Bench-01');
    expect(req.toJson(), {
      'type': 'login',
      'uid': 'ABC',
      'machine': 'Bench-01',
    });
  });

  test('LoginResponse parses success', () {
    final resp = LoginResponse.fromJson({
      'type': 'login_response',
      'ok': true,
      'first': 'Jane',
      'last': 'Doe',
    });
    expect(resp.ok, true);
    expect(resp.first, 'Jane');
    expect(resp.last, 'Doe');
    expect(resp.error, isNull);
  });

  test('LoginResponse parses failure', () {
    final resp = LoginResponse.fromJson({
      'type': 'login_response',
      'ok': false,
      'error': 'unknown_uid',
    });
    expect(resp.ok, false);
    expect(resp.error, 'unknown_uid');
  });
}

