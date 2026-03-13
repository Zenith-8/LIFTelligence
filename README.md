# Phone App (iOS/Android) - Flutter + Cloud iOS Builds

This folder is the start of a real native iPhone app that can integrate with this repo's `nfc-login-server` (TCP, length-prefixed JSON protocol).

Because iOS builds require macOS/Xcode, this project is set up so you can develop on Windows and still ship to an iPhone using cloud macOS builds (Codemagic / GitHub Actions macOS runners) and TestFlight.

## What's here

- `packages/phone_app/` - Flutter package containing the app UI + TCP client for `nfc-login-server` protocol v1.
- `app/` - Generated Flutter host app (created by `flutter create`) that depends on `packages/phone_app`.
- `tool/bootstrap.ps1` - Windows bootstrap (creates `app/` and wires it to the package).
- `tool/bootstrap.sh` - macOS/Linux bootstrap (used by CI).
- `codemagic.yaml` - Example Codemagic config (builds Android + iOS).
- `.github/workflows/flutter_ci.yml` - CI that runs package tests.

## Quick start (Windows dev)

1. Install Flutter on Windows.
2. Bootstrap the host app:
   - PowerShell: `./tool/bootstrap.ps1`
3. Run:
   - `cd ./app`
   - `flutter pub get`
   - `flutter run` (you can use an Android emulator/device locally)

## Running on an iPhone without a Mac

Recommended flow:

1. Create an Apple Developer account (typically required for device installs/TestFlight).
2. Use Codemagic (or a GitHub Actions macOS runner) to build/sign the iOS app.
3. Distribute to your iPhone via TestFlight.

This repo includes a starting `codemagic.yaml`. You'll still need to add signing credentials in your CI provider (Apple certificate/provisioning profile or App Store Connect API key, depending on provider and workflow).

## Integration target: nfc-login-server

`nfc-login-server` protocol v1 (see `../nfc-login-server/README.md`) uses:

- TCP transport
- Frame: `uint32_be length` + UTF-8 JSON payload
- Request: `{"type":"login","uid":"04A1B2C3D4","machine":"Bench-01"}`

The Flutter package implements this framing and request/response mapping.

## Next steps (recommended)

- Decide how the phone obtains the UID:
  - For now, the UI supports manual UID entry (works immediately).
  - iOS NFC UID access is restricted; you may need a tag strategy (NDEF payload, QR, or a supported NFC flow) depending on your hardware.
- Decide where the server runs and how the phone reaches it (LAN IP, Wi-Fi AP, VPN, etc.).

## QR pairing flow

When a card UID is unknown, the machine app (`cpp-senior-design`) shows a QR code. In the phone app, use **Scan Pairing QR** to enroll/link that UID by sending a `pair` request to `nfc-login-server`.

Camera permissions:

- iOS: ensure `NSCameraUsageDescription` exists in `phone-app/app/ios/Runner/Info.plist` after bootstrapping.
- Android: the camera permission is added by the QR scanning plugin, but you may need to review `AndroidManifest.xml` depending on your build setup.

