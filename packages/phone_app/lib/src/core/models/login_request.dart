class LoginRequest {
  const LoginRequest({
    required this.uid,
    required this.machine,
  });

  final String uid;
  final String machine;

  Map<String, Object?> toJson() => <String, Object?>{
        'type': 'login',
        'uid': uid,
        'machine': machine,
      };
}

