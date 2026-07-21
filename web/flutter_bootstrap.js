{{flutter_js}}
{{flutter_build_config}}

// PULLUP is served as an online-first app. Avoid registering Flutter's legacy
// service worker so a new Vercel deployment is visible immediately on Safari.
_flutter.loader.load();
