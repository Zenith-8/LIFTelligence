import 'models/login_request.dart';
import 'models/login_response.dart';
import 'models/pair_request.dart';
import 'models/pair_response.dart';
import 'tcp_json_framed_client.dart';

class NfcLoginClient {
  NfcLoginClient({
    required this.host,
    required this.port,
  });

  final String host;
  final int port;

  Future<LoginResponse> login({
    required String uid,
    required String machine,
  }) async {
    final client = TcpJsonFramedClient(host: host, port: port);
    final responseJson = await client.request(
      LoginRequest(uid: uid, machine: machine).toJson(),
    );
    return LoginResponse.fromJson(responseJson);
  }

  Future<PairResponse> pair({
    required String token,
    String? first,
    String? last,
  }) async {
    final client = TcpJsonFramedClient(host: host, port: port);
    final responseJson = await client.request(
      PairRequest(token: token, first: first, last: last).toJson(),
    );
    return PairResponse.fromJson(responseJson);
  }
}
