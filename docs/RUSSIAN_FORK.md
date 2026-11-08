# Russian personal fork

The maintained fork is `Astoltzweb/hermes-console`. The working branch for
connection recovery and Russian interface fixes is
`fix/connection-stability-and-russian`.

## Verified baseline

On 2026-11-08, the installed Android personal build reported version 1.3.1
(9650), package `dev.xpetalab.hermesconsole.personal`. The sources of
`connection_manager.dart`, `tui_gateway_client.dart` and
`shared_gateway_pool.dart` were read through that running build's Dart VM
service and matched the checkout at `66d7427` exactly after newline
normalization. A subsequent comparison of all 774 loaded, Git-tracked Dart
sources found no differences (11 generated sources were excluded). That
commit already includes the Russian locale and server
speech recognition adaptations. The local checkout is therefore the source
for this personal build, rather than an unverified upstream release.

## Changes on this branch

- Returning to the foreground clears a stale background reconnect delay.
- The automatic reconnect timer of an established chat is replaced immediately
  when the connection is woken, even when no request is waiting for it.
- Repeated wake/network signals share a 15-second holdoff; healthy sockets are
  probed, and the usual retry backoff still applies after another failure.
- Russian connection states, retry/save/cancel actions, navigation and common
  chat messages use natural, consistent wording.

Recovery does not resend a chat message. A server restart or an unreachable
server can still interrupt the connection; the client must reconnect when the
server is available again.

## Android background network access

Check the device's power policy as well as the app logs. Android can block
this package with `BATTERY_SAVER|DOZE|APP_BACKGROUND`; DNS lookup errors then
do not necessarily indicate a broken DNS server. During device diagnosis,
allowlisting the personal package changed its effective network block to
`NONE`, and the running app established its connection again.

For a phone whose owner wants background access, set Console's battery use to
unrestricted in Android settings, or apply the equivalent device-side ADB
exception:

```sh
adb shell dumpsys deviceidle whitelist +dev.xpetalab.hermesconsole.personal
```

This affects only the installed personal package and can increase its battery
use. Remove the exception with the same command and a `-` before the package.
It is a phone setting, not an app permission or a repository default. Android
may still suspend the process; the foreground reconnect fix remains necessary.

## Local build and validation

The verified toolchain is Flutter 3.47.1 / Dart 3.13.1, Android SDK 36 and JDK 21.
Use the repository's locked dependencies:

```sh
flutter pub get --enforce-lockfile
flutter gen-l10n
flutter test --no-pub test/gateway_reconnect_storm_test.dart test/shared_gateway_pool_test.dart test/tui_gateway_client_test.dart test/connection_health_tracker_test.dart test/net1_connection_status_test.dart
flutter analyze --no-pub
flutter build apk --debug --flavor full --target-platform android-arm64 --build-name 1.3.1-ru.2 --build-number 9651 --no-pub
```

The debug application ID retains the `.personal` suffix, so an update signed
with the same local debug key preserves the personal build's data. Install
with `adb install -r` only after checking package and signing continuity.
Never uninstall an existing app to work around a signing mismatch.

The APK and local signing material are private build outputs, not repository
files or public release assets. This branch does not publish a GitHub Release
or a Google Play artifact.
