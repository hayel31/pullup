# PULLUP

PULLUP is a Flutter MVP for private night-plan discovery.

Product line: `What's the move?`

Signature: `Swipe. Match. Pull up.`

## MVP scope

Completed in the Flutter app:

- Dark premium Material 3 theme.
- Feature-first architecture with Riverpod and GoRouter.
- Demo authentication, registration, email reset and email verification screens.
- User onboarding: photos, profile, preferences and safety rules.
- User profile, edit profile, settings, sign out and delete account flow.
- Party event creation flow with type, info, location, media placeholder, vibe/rules and publishing.
- Discover feed with swipe gestures, pass/request actions, Premium undo simulation, report/share actions and request note modal.
- Recommendation engine with documented scoring formula.
- Tonight mode with `Happening now`, `Starting soon`, `Near you`, `Few spots left`, `Trending tonight` and approximate map.
- Event detail page with private address shown only to host or accepted participants.
- Host request review with accept, reject, block and profile preview.
- Local transaction-style match creation, spot decrement and conversation creation.
- Matches page with recent, upcoming, pending and chat tabs.
- Firestore-like chat model with text/system messages, unread markers and blocked-user checks.
- Notifications page.
- Safety Center with reports, blocked users and account deletion.
- DJ profiles, DJ request flow and DJ data models.
- Premium/paywall architecture prepared for RevenueCat or native subscriptions.
- Demo dataset with 12 users, 8 events, 3 DJs, requests, matches, conversations and notifications.
- Firestore rules, indexes, Firebase config and Cloud Functions skeleton.
- Unit, widget and integration tests.

Prepared but not activated without credentials:

- Firebase Authentication.
- Cloud Firestore live repositories.
- Firebase Storage uploads and image compression.
- Firebase Cloud Messaging push tokens.
- Apple/Google OAuth.
- App Check.
- RevenueCat/App Store/Google Play subscriptions.
- Identity/selfie verification provider.
- Real map tiles in restricted/offline environments.

## Architecture

The app uses a feature-first structure:

```text
lib/
  app/
    app.dart
    router.dart
    constants/
    providers/
    theme/
  core/
    config/
    errors/
    services/
    utils/
    widgets/
  models/
  features/
    authentication/
    onboarding/
    profile/
    discovery/
    tonight/
    events/
    matches/
    chat/
    notifications/
    safety/
    premium/
    dj/
    settings/
    shared/
```

Widgets do not call Firebase directly. They consume Riverpod providers and controllers. The controller depends on `PullupRepository`, which currently resolves to `DemoPullupRepository` unless the app is launched with:

```bash
flutter run --dart-define=USE_FIREBASE=true
```

The Firebase repository is intentionally guarded until Firebase project credentials and collection setup are added.

## Main models

- `UserProfile`
- `PartyEvent`
- `EventRequest`
- `PullupMatch`
- `ChatConversation`
- `ChatMessage`
- `NotificationItem`
- `Report`
- `DjProfile`
- `DjServiceRequest`
- `DjProposal`
- `SubscriptionState`
- `Boost`

## Firestore structure

```text
users/{userId}
users/{userId}/swipes/{swipeId}
users/{userId}/notifications/{notificationId}
users/{userId}/blockedUsers/{blockedUserId}

events/{eventId}
events/{eventId}/private/access
events/{eventId}/requests/{requestId}
events/{eventId}/participants/{participantId}

matches/{matchId}

conversations/{conversationId}
conversations/{conversationId}/messages/{messageId}

reports/{reportId}
djProfiles/{djId}
djServiceRequests/{requestId}
djProposals/{proposalId}
subscriptions/{userId}
boosts/{boostId}
```

Exact private addresses must live under `events/{eventId}/private/access`, not in the public event document.

## Setup

Install Flutter stable and verify:

```bash
flutter doctor
```

Install dependencies:

```bash
flutter pub get
```

Run in demo mode:

```bash
flutter run
```

Run with environment names:

```bash
flutter run --dart-define=APP_ENV=development
flutter run --dart-define=APP_ENV=staging
flutter run --dart-define=APP_ENV=production
```

Run with Firebase after adding platform config files:

```bash
flutter run --dart-define=USE_FIREBASE=true --dart-define=APP_ENV=staging
```

## Firebase configuration

Add your Firebase config files locally:

- Android: `android/app/google-services.json`
- iOS: `ios/Runner/GoogleService-Info.plist`

Then wire `FirebasePullupRepository` collection methods to the production schema. Keep sensitive server-owned fields out of client writes:

- verification flags
- `isPremium`
- moderation roles
- `accountStatus`
- `reportCount`
- boost validation fields

Deploy rules and indexes:

```bash
firebase deploy --only firestore:rules,firestore:indexes
```

Deploy Cloud Functions:

```bash
cd functions
npm install
npm run build
firebase deploy --only functions
```

## Tests and quality

Format:

```bash
dart format lib test integration_test
```

Analyze:

```bash
flutter analyze
```

Unit and widget tests:

```bash
flutter test
```

Integration test with a device/emulator:

```bash
flutter test integration_test
```

## Known limits

- Live Firebase repository methods are prepared but intentionally not connected without credentials.
- Demo images use remote placeholder URLs.
- Image upload uses `image_picker` in UX but stores demo URLs.
- Payments, boosts and identity checks are simulated.
- Voice/video messages, reactions, replies and temporary live location are not active.
- Moderation automation is prepared in Cloud Functions and rules but not connected to a staff UI.
- Map uses approximate event coordinates only.

## Production recommendations

- Split public event documents from private access documents before launch.
- Add server-side Cloud Function entrypoints for all sensitive writes.
- Add App Check and Firestore rules tests using the Emulator Suite.
- Integrate RevenueCat or native stores behind the Premium abstraction.
- Add Cloud Storage image processing and moderation scanning.
- Add real verification provider for selfie/identity/host/DJ badges.
- Add crash reporting, analytics consent and privacy policy flows.
- Add CI running `flutter analyze`, `flutter test`, rules tests and functions build.
- Replace demo recommendation with a server-assisted ranking service once data volume grows.
