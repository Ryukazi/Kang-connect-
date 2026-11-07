# Kang Connect — real backend starter

This release replaces the UI-only demo with Supabase email authentication, private one-to-one chat, invitation codes, and realtime message streaming.

## Important privacy model
- Each invitation creates one private chat between its creator and the accepting account.
- The app has no shared group chat or member directory.
- Messages are accessible only to the two participants via Row Level Security.
- Location sharing is NOT implemented or active in this release.
- This is not end-to-end encrypted; Supabase/database operators can technically access stored data. Do not use it for highly sensitive messages yet.

## Setup
1. In Supabase SQL Editor, run `supabase/secure_private_connections.sql` after the initial schema.
2. Ensure Authentication -> Providers -> Email is enabled.
3. In Database -> Publications, enable `messages` in `supabase_realtime` if not already enabled.
4. In Authentication -> URL Configuration, keep your app's redirect settings as default for now.
5. Push this project to GitHub and let Actions build the APK.

The Supabase project URL and publishable key are configured in `lib/main.dart`. Publishable keys are intended for client apps; never put a secret/service-role key in the app.

## First use
1. Install the APK.
2. Create your account using your email and password. If email confirmation is enabled, confirm the email before signing in.
3. On your account, tap Home -> Invite someone and send the generated one-time code to ONE person.
4. The invited person creates their own account, then taps Home -> Join with a code.
5. Both accounts will see only their private conversation with each other.
6. Repeat with a different invite code for the next person.

## Build APK
Push to `main`, then open GitHub -> Actions -> Build Kang Connect APK. Download `kang-connect-release-apk` from the successful run's Artifacts section.

## Current scope
Working: email/password auth, profile display name on sign-up, one-use invitations, separate private chats, message persistence, realtime message stream.
Not included yet: push notifications, live location, media attachments, voice/video calls, iOS signing. Those require additional implementation and permissions.
