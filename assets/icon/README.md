# App icon source files

Drop two PNGs here, then run:

```bash
flutter pub get
dart run flutter_launcher_icons
```

| File | Size | Purpose |
|---|---|---|
| `icon.png` | 1024×1024, full-bleed | Legacy launcher icon (Android 7 and below, Play Store). |
| `icon_foreground.png` | 1024×1024, ~25% padding around the logo, transparent background | Foreground layer of the Android 8+ adaptive icon (gets cropped/zoomed inside the user's chosen mask shape — circle, squircle, etc.). |

The adaptive background is configured as a solid color in `pubspec.yaml`
(`adaptive_icon_background: "#0B2A4A"`). Change that hex or replace it with a
path to another PNG if you want a gradient/illustration backdrop.

If you only have ONE image, you can point both fields at the same `icon.png` —
it will still work, but Android may crop your logo unexpectedly. Adding 25 %
transparent padding to the foreground avoids that.
