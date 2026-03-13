class LoginResponse {
  const LoginResponse._({
    required this.ok,
    this.first,
    this.last,
    this.error,
    this.pairToken,
    this.pairTtlSec,
  });

  final bool ok;
  final String? first;
  final String? last;
  final String? error;

  // Present when ok=false and error="pairing_required".
  final String? pairToken;
  final int? pairTtlSec;

  factory LoginResponse.fromJson(Map<String, Object?> json) {
    final type = json['type'];
    if (type != 'login_response') {
      throw FormatException('Unexpected response type: $type');
    }

    final ok = json['ok'];
    if (ok is! bool) {
      throw const FormatException('Missing/invalid ok field');
    }

    final first = json['first'];
    final last = json['last'];
    final error = json['error'];
    final pairToken = json['pair_token'];
    final pairTtlSec = json['pair_ttl_sec'];

    return LoginResponse._(
      ok: ok,
      first: first is String ? first : null,
      last: last is String ? last : null,
      error: error is String ? error : null,
      pairToken: pairToken is String ? pairToken : null,
      pairTtlSec: pairTtlSec is int ? pairTtlSec : null,
    );
  }
}
