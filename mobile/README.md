# mobile (Flutter)

Artisan-facing app: onboarding, camera capture, voice recording, offline-first queue, catalog browse, buyer-side search.

Consumes: `backend-service` REST contract.
Receives: push notifications from `backend-service`.

## Set up

```bash
flutter create . --org com.sih26090 --project-name sih26090_mobile
flutter pub get
flutter run
```

## Planned structure

```
lib/
├── main.dart
├── core/            # api client, theming, routing
├── features/
│   ├── onboarding/
│   ├── capture/     # camera + voice recording + offline queue
│   ├── catalog/     # listing list/detail, review-and-publish
│   └── orders/
└── shared/
```

Point the API client at `backend-service`'s base URL via an environment config (`--dart-define=API_BASE_URL=...`), not a hardcoded constant, so switching between local/mock/staging is a build flag, not a code change.
