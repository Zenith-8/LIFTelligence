import 'dart:async';

import 'package:flutter/material.dart';

import '../core/app_storage.dart';
import '../core/nfc_login_client.dart';
import '../core/models/login_response.dart';
import '../core/pairing_qr.dart';
import 'scan_qr_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _storage = AppStorage();

  final _host = TextEditingController();
  final _port = TextEditingController();
  final _machine = TextEditingController();
  final _uid = TextEditingController();

  final _first = TextEditingController();
  final _last = TextEditingController();

  bool _loading = true;
  bool _busy = false;
  String? _error;
  String? _info;
  LoginResponse? _lastResponse;

  @override
  void initState() {
    super.initState();
    unawaited(_loadDefaults());
  }

  Future<void> _loadDefaults() async {
    final host = await _storage.getServerHost();
    final port = await _storage.getServerPort();
    final machine = await _storage.getMachineName();
    final uid = await _storage.getLastUid();

    if (!mounted) return;
    setState(() {
      _host.text = host;
      _port.text = port.toString();
      _machine.text = machine;
      _uid.text = uid;
      _loading = false;
    });
  }

  @override
  void dispose() {
    _host.dispose();
    _port.dispose();
    _machine.dispose();
    _uid.dispose();
    _first.dispose();
    _last.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    setState(() {
      _busy = true;
      _error = null;
      _info = null;
      _lastResponse = null;
    });

    try {
      final host = _host.text.trim();
      final port = int.tryParse(_port.text.trim());
      final machine = _machine.text.trim();
      final uid = _uid.text.trim();

      if (host.isEmpty) throw const FormatException('Host is required');
      if (port == null || port <= 0 || port > 65535) {
        throw const FormatException('Port must be 1-65535');
      }
      if (machine.isEmpty) throw const FormatException('Machine name is required');
      if (uid.isEmpty) throw const FormatException('UID is required');

      await _storage.setServerHost(host);
      await _storage.setServerPort(port);
      await _storage.setMachineName(machine);
      await _storage.setLastUid(uid);

      final client = NfcLoginClient(host: host, port: port);
      final resp = await client.login(uid: uid, machine: machine);

      if (!mounted) return;
      setState(() => _lastResponse = resp);
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = e.toString());
    } finally {
      if (!mounted) return;
      setState(() => _busy = false);
    }
  }

  Future<void> _scanAndPair() async {
    setState(() {
      _error = null;
      _info = null;
      _lastResponse = null;
    });

    final raw = await Navigator.of(context).push<String>(
      MaterialPageRoute(builder: (_) => const ScanQrPage()),
    );
    if (!mounted || raw == null) return;

    setState(() => _busy = true);

    try {
      final parsed = parsePairingQr(raw);

      var host = parsed.host;
      var port = parsed.port;
      if (host.isEmpty) {
        host = _host.text.trim();
        port = int.tryParse(_port.text.trim()) ?? 0;
      }

      if (host.isEmpty) throw const FormatException('Host is required (QR did not include it)');
      if (port <= 0 || port > 65535) throw const FormatException('Port is required (QR did not include it)');

      await _storage.setServerHost(host);
      await _storage.setServerPort(port);
      _host.text = host;
      _port.text = port.toString();

      final client = NfcLoginClient(host: host, port: port);
      final resp = await client.pair(
        token: parsed.token,
        first: _first.text,
        last: _last.text,
      );

      if (!mounted) return;
      setState(() {
        if (resp.ok) {
          _info = 'Paired successfully${resp.uid == null ? '' : ' (UID: ${resp.uid})'}.';
        } else {
          _error = 'Pair failed: ${resp.error ?? 'unknown'}';
        }
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = e.toString());
    } finally {
      if (!mounted) return;
      setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Liftelligence Login'),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Text(
                  'Connect to nfc-login-server',
                  style: theme.textTheme.titleMedium,
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _host,
                  decoration: const InputDecoration(
                    labelText: 'Server Host',
                    hintText: '192.168.1.10',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.url,
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _port,
                  decoration: const InputDecoration(
                    labelText: 'Server Port',
                    hintText: '5001',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _machine,
                  decoration: const InputDecoration(
                    labelText: 'Machine',
                    hintText: 'Bench-01',
                    border: OutlineInputBorder(),
                  ),
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _uid,
                  decoration: const InputDecoration(
                    labelText: 'UID (manual login)',
                    hintText: '04A1B2C3D4',
                    border: OutlineInputBorder(),
                  ),
                  textInputAction: TextInputAction.done,
                  onSubmitted: (_) => unawaited(_login()),
                ),
                const SizedBox(height: 16),
                FilledButton(
                  onPressed: _busy ? null : () => unawaited(_login()),
                  child: _busy
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Login'),
                ),
                const SizedBox(height: 18),
                Text(
                  'Pairing (QR)',
                  style: theme.textTheme.titleMedium,
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _first,
                        decoration: const InputDecoration(
                          labelText: 'First (optional)',
                          border: OutlineInputBorder(),
                        ),
                        textInputAction: TextInputAction.next,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        controller: _last,
                        decoration: const InputDecoration(
                          labelText: 'Last (optional)',
                          border: OutlineInputBorder(),
                        ),
                        textInputAction: TextInputAction.done,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                OutlinedButton(
                  onPressed: _busy ? null : () => unawaited(_scanAndPair()),
                  child: const Text('Scan Pairing QR'),
                ),
                const SizedBox(height: 16),
                if (_error != null)
                  Card(
                    color: theme.colorScheme.errorContainer,
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Text(
                        _error!,
                        style: TextStyle(color: theme.colorScheme.onErrorContainer),
                      ),
                    ),
                  ),
                if (_info != null)
                  Card(
                    color: theme.colorScheme.primaryContainer,
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Text(
                        _info!,
                        style: TextStyle(color: theme.colorScheme.onPrimaryContainer),
                      ),
                    ),
                  ),
                if (_lastResponse != null)
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: _lastResponse!.ok
                          ? Text(
                              'OK: ${_lastResponse!.first ?? ''} ${_lastResponse!.last ?? ''}'.trim(),
                              style: theme.textTheme.titleMedium,
                            )
                          : Text(
                              'Login failed: ${_lastResponse!.error ?? 'unknown'}',
                              style: theme.textTheme.titleMedium,
                            ),
                    ),
                  ),
                const SizedBox(height: 24),
                Text(
                  'Tip: Your phone must reach the server over the network (same Wi-Fi, etc.).',
                  style: theme.textTheme.bodySmall,
                ),
              ],
            ),
    );
  }
}
