# Kang Connect

A Flutter starter app for a private, consent-based connection app.

## Current prototype
- Home screen and member spaces
- Local demo switches for location and activity sharing
- Privacy information screen
- Chat placeholder
- GitHub Actions workflow to build an Android APK

**Important:** The switches are UI-only. This version does not transmit location, app activity, or messages. Do not treat it as a functioning tracking or messaging service.

## Build APK with GitHub Actions
1. Push this project to the `main` branch.
2. Open the repository on GitHub.
3. Open **Actions**.
4. Select **Build Kang Connect APK**.
5. Tap **Run workflow** if it has not started automatically.
6. Open the completed workflow run.
7. Under **Artifacts**, download `kang-connect-release-apk`.
8. Extract the ZIP to get `app-release.apk`.

## Next development stage
Connect Firebase Authentication, Firestore, and push notifications. Then implement member invitations and consent-managed location sharing. Android and iOS permissions must be requested transparently from each device owner. iOS app-usage reporting has additional Apple entitlement and API restrictions.
