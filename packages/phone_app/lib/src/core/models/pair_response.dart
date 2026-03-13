class PairResponse {
  const PairResponse._({
    required this.ok,
    this.uid,
    this.error,
  });

  final bool ok;
  final String? uid;
  final String? error;

  factory PairResponse.fromJson(Map<String, Object?> json) {
    final type = json['type'];
    if (type != 'pair_response') {
      throw FormatException('Unexpected response type: $type');
    }

    final ok = json['ok'];
    if (ok is! bool) {
      throw const FormatException('Missing/invalid ok field');
    }

    final uid = json['uid'];
    final error = json['error'];

    return PairResponse._(
      ok: ok,
      uid: uid is String ? uid : null,
      error: error is String ? error : null,
    );
  }
}
