# PULLUP

PULLUP is a Flutter MVP for private night-plan discovery.

Product line: `What's the move?`

Signature: `Swipe. Match. Pull up.`

## MVP scope

Completed in the Flutter app:

- Dark premium Material 3 theme.
- Feature-first architecture with Riverpod and GoRouter.
- Persistent in-app language picker with English, French, Spanish and German UI copy.
- Demo email/password authentication with persistent registration and session restore.
- User onboarding: photos, profile, preferences and safety rules.
- Personal/professional account choice with dedicated professional onboarding, services, portfolio media, social links, rates and references.
- User profile, edit profile, settings, sign out and delete account flow.
- Party event creation flow with type, info, location, media placeholder, vibe/rules and publishing.
- Event entry pricing, supplied drinks/food, guest contributions and host-selectable practical indicators.
- Initial attendee composition and aggregate men/women/other counters updated atomically after every accepted request.
- Private, professional and venue event identities, with professional-needs tags and filters.
- Discover feed with swipe gestures, pass/request actions, Premium undo simulation and a structured join-request modal.
- Reciprocal PULLUP friends with search, add/remove actions and local persistence.
- Group requests with identified PULLUP friends plus anonymous men/women guest counts, all constrained by event capacity.
- Recommendation engine with documented scoring formula.
- Tonight mode with `Happening now`, `Starting soon`, `Near you`, `Few spots left`, `Trending tonight` and approximate map.
- Event detail page with private address shown only to host or accepted participants.
- Host request review with accept, reject, block and profile preview.
- Professional applications attach the provider portfolio and create a match without consuming guest capacity.
- Open bar/venue events collect interest likes without creating individual approval requests.
- Local transaction-style match creation, spot decrement and conversation creation.
- Matches page with recent, upcoming, pending and chat tabs.
- Ephemeral 12-hour event group chats with member access checks, author avatars, text/system messages and unread markers.
- Notifications page.
- Safety Center with reports, blocked users and account deletion.
- DJ profiles, DJ request flow and DJ data models.
- Premium/paywall architecture prepared for RevenueCat or native subscriptions.
- Toulouse-centered demo dataset with 13 users, 10 events, 5 demo accounts, 3 DJs, requests, matches, conversations and notifications.
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
- Machine translation of user-authored profiles, events and messages.

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
  l10n/
  models/
  features/
    authentication/
    onboarding/
    profile/
    friends/
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

## Demo accounts

The Vercel build includes five host profiles, including a professional DJ and
a professional bar. Every account owns at least one published event and can
also use the guest discovery experience.

| Profile | Email | Password | Existing events |
| --- | --- | --- | --- |
| Leo | `leo@pullup.demo` | `Pullup2026!` | Rooftop, pre-game and private loft DJ set |
| Jade | `jade@pullup.demo` | `Pullup2026!` | Pool party, student apartment and after |
| Noah | `noah@pullup.demo` | `Pullup2026!` | Boat party and birthday suite |
| Nina Volt | `nina@pullup.demo` | `Pullup2026!` | Neon private DJ session |
| Le Halo Toulouse | `halo@pullup.demo` | `Pullup2026!` | Professional bar and open venue events |

Accounts created in demo mode, their password digests, the active session and
their newly published events are saved with `shared_preferences`. This storage
is local to the browser/device. Configure Firebase Authentication and Firestore
for shared accounts and data across devices.

## Main models

- `UserProfile`
- `ProfessionalProfile`
- `ProfessionalPortfolioItem`
- `PartyEvent`
- `AttendanceBreakdown`
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
users/{userId}/friends/{friendId}

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

## Web and Vercel

The public demo is deployed at [pullup-night.vercel.app](https://pullup-night.vercel.app).

Build the same production bundle locally:

```bash
flutter build web --release --pwa-strategy=none \
  --dart-define=APP_ENV=production \
  --dart-define=USE_FIREBASE=false
```

Deploy the prebuilt static bundle to the existing Vercel project:

```bash
npx vercel@latest deploy build/web --prod --yes --project pullup-night
```

`web/vercel.json` is copied into the build and provides SPA rewrites for direct links. The public deployment deliberately uses the demo repository and contains no Firebase credentials.

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
- Demo event covers use bundled local nightlife imagery.
- Image upload uses `image_picker` in UX but stores demo references.
- Payments, boosts and identity checks are simulated.
- Voice/video messages, reactions, replies and temporary live location are not active.
- Moderation automation is prepared in Cloud Functions and rules but not connected to a staff UI.
- Map uses approximate event coordinates only.
- Demo registrations and newly created events are local to each browser until Firebase is configured.

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
