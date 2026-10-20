# bio_glow

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Learn Flutter](https://docs.flutter.dev/get-started/learn-flutter)
- [Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Flutter learning resources](https://docs.flutter.dev/reference/learning-resources)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

---

## Local run & test (added by assistant)

This project includes the Bio Glow UI, sign-in persistence, quiz flow, camera capture, and a simple on-device image heuristic.
# Bio Glow

Bio Glow is a Flutter app for Android, iOS, and web. It includes a mint sign-in screen, a 12-question skin profile quiz, and a blue concern/photo screen with links to the supplied skin-condition guides.

## Run and test

```sh
flutter pub get
flutter test
flutter run
```

Camera access uses the browser's camera/file picker on web and the native camera on supported devices. Android and iOS camera permissions are configured in their platform projects.

Profiles and quiz answers are stored locally on the device. This prototype does not provide server-backed accounts or cross-device sync. Photos are not medically analyzed; the app presents educational resources and cannot diagnose skin conditions. A validated medical model and clinical review would be needed before offering diagnostic results.

## Web publishing

The GitHub Actions workflows build the web app for the `/BioGlow/` project path and publish it to the `gh-pages` branch after a push to `main` (or `master`). In the repository's GitHub Pages settings, select **Deploy from a branch**, then select `gh-pages` and `/ (root)`.

The intended permanent URL is <https://vidhyapg30-ship-it.github.io/BioGlow/>. It currently returns 404 until the updated app is pushed, the Pages source is enabled, and the workflow completes successfully.
Follow the app flow: sign in → quiz → describe concern → take photo → analyze.
