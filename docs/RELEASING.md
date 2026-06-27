# Releasing the IPMA APK

This app self-checks for updates against **GitHub Releases**. The banner appears at
the top of the home screen whenever the latest release's tag (e.g. `v0.2.0`) is
newer than the running app's `version` from `pubspec.yaml`.

---

## One-time setup

### 1. Create a signing keystore (do this **once**, keep it forever)

> If you ever lose this keystore, users cannot update — they will have to
> uninstall the old app and install the new one fresh. Back it up somewhere safe.

```bash
keytool -genkey -v -keystore upload-keystore.jks \
  -keyalg RSA -keysize 2048 -validity 10000 -alias upload
```

Move the resulting `upload-keystore.jks` to `android/app/upload-keystore.jks` for
local release builds, and copy `android/key.properties.example` to
`android/key.properties` with the real passwords.

### 2. Tell the app where its repo lives

Edit `lib/widgets/update_banner.dart`:

```dart
const _kRepoOwner = 'your-github-username';
const _kRepoName  = 'ipma_apk';
```

### 3. Add GitHub Actions secrets

In your repo → **Settings → Secrets and variables → Actions → New secret**:

| Secret name              | Value                                                                 |
|--------------------------|-----------------------------------------------------------------------|
| `ANDROID_KEYSTORE_BASE64`| Output of `base64 -w0 upload-keystore.jks` (one long line).           |
| `ANDROID_STORE_PASSWORD` | Keystore password.                                                    |
| `ANDROID_KEY_ALIAS`      | `upload` (or whatever alias you used).                                |
| `ANDROID_KEY_PASSWORD`   | Key password.                                                         |

---

## Shipping a new version

1. Bump the version in `pubspec.yaml` — both halves matter:
   ```yaml
   version: 0.2.0+2     # ^^^^ user-visible    ^ Android versionCode (must increase)
   ```
2. Commit, tag, push:
   ```bash
   git commit -am "release: 0.2.0"
   git tag v0.2.0
   git push origin main --tags
   ```
3. The `Release` workflow builds a signed APK and publishes it as
   `ipma-v0.2.0.apk` on the GitHub Releases page.
4. Every running app polls `releases/latest` on launch and shows an in-app
   "Atualizar" banner. The user taps it → APK downloads → Android's package
   installer opens.

---

## Local release build (optional, no GitHub needed)

```bash
flutter build apk --release
# APK ends up at build/app/outputs/flutter-apk/app-release.apk
```

You can attach this manually to a Release in the GitHub UI if you want to skip
CI for a one-off.

---

## What users have to do once

The first time a user taps "Atualizar", Android asks for permission to install
apps from this source. They must enable it once; subsequent updates are silent
(still go through the OS package installer, but no permission prompt).

---

## Gotchas

- **Never change the keystore.** Signature mismatch ⇒ Android refuses the
  update with `INSTALL_FAILED_UPDATE_INCOMPATIBLE`.
- **`versionCode` must strictly increase.** That's the `+N` after the `+` in
  `pubspec.yaml`. The user-visible `0.2.0` part is compared as semver by the
  in-app updater.
- **Tag must be `vX.Y.Z`.** The `v` prefix is stripped before semver compare,
  but the asset name uses the full tag.
