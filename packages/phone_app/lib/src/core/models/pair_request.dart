class PairRequest {
  const PairRequest({
    required this.token,
    this.first,
    this.last,
  });

  final String token;
  final String? first;
  final String? last;

  Map<String, Object?> toJson() => <String, Object?>{
        'type': 'pair',
        'token': token,
        if (first != null && first!.trim().isNotEmpty) 'first': first!.trim(),
        if (last != null && last!.trim().isNotEmpty) 'last': last!.trim(),
      };
}
