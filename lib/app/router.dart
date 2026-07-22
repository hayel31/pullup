import 'package:pullup/l10n/app_material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/authentication/presentation/pages/auth_pages.dart';
import '../features/chat/presentation/pages/chat_page.dart';
import '../features/discovery/presentation/pages/discover_page.dart';
import '../features/discovery/presentation/pages/filters_page.dart';
import '../features/dj/presentation/pages/dj_page.dart';
import '../features/events/presentation/pages/create_event_page.dart';
import '../features/events/presentation/pages/event_detail_page.dart';
import '../features/events/presentation/pages/host_dashboard_page.dart';
import '../features/events/presentation/pages/host_requests_page.dart';
import '../features/friends/presentation/pages/friends_page.dart';
import '../features/matches/presentation/pages/matches_page.dart';
import '../features/notifications/presentation/pages/notifications_page.dart';
import '../features/onboarding/presentation/pages/onboarding_page.dart';
import '../features/premium/presentation/pages/premium_page.dart';
import '../features/profile/presentation/pages/edit_profile_page.dart';
import '../features/profile/presentation/pages/profile_page.dart';
import '../features/safety/presentation/pages/safety_page.dart';
import '../features/settings/presentation/pages/appearance_page.dart';
import '../features/settings/presentation/pages/settings_page.dart';
import '../features/shared/presentation/main_shell.dart';
import '../features/tonight/presentation/pages/tonight_page.dart';
import 'providers/app_state.dart';
import 'providers/entrance_flow_provider.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final refreshNotifier = _RouterRefreshNotifier();
  ref.onDispose(refreshNotifier.dispose);
  ref.listen(
    appControllerProvider.select(
      (state) =>
          (state.currentUser?.id, state.currentUser?.onboardingCompleted),
    ),
    (previous, next) {
      if (previous?.$1 != null && next.$1 == null) {
        ref.read(preLoginEntranceSeenProvider.notifier).state = false;
      }
      refreshNotifier.refresh();
    },
  );
  ref.listen(preLoginEntranceSeenProvider, (_, _) => refreshNotifier.refresh());

  return GoRouter(
    initialLocation: '/splash',
    debugLogDiagnostics: false,
    refreshListenable: refreshNotifier,
    redirect: (context, state) {
      final path = state.uri.path;
      final publicPaths = {
        '/splash',
        '/welcome',
        '/login',
        '/register',
        '/forgot-password',
        '/verify-email',
      };
      final isPublic = publicPaths.contains(path);
      final user = ref.read(appControllerProvider).currentUser;
      if (path == '/splash') {
        return null;
      }
      if (user == null &&
          path == '/welcome' &&
          !ref.read(preLoginEntranceSeenProvider)) {
        return '/splash';
      }
      if (user == null && !isPublic) {
        return '/welcome';
      }
      if (user != null && !user.onboardingCompleted && path != '/onboarding') {
        return '/onboarding';
      }
      if (user != null && user.onboardingCompleted && isPublic) {
        return '/entrance';
      }
      return null;
    },
    routes: [
      GoRoute(path: '/splash', builder: (context, state) => const SplashPage()),
      GoRoute(
        path: '/entrance',
        builder: (context, state) => const PostLoginEntrancePage(),
      ),
      GoRoute(
        path: '/welcome',
        pageBuilder: (context, state) => CustomTransitionPage<void>(
          key: state.pageKey,
          transitionDuration: const Duration(milliseconds: 220),
          reverseTransitionDuration: const Duration(milliseconds: 160),
          child: const WelcomePage(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            final entrance = CurvedAnimation(
              parent: animation,
              curve: const Interval(0.04, 1, curve: Curves.easeOutCubic),
            );
            return FadeTransition(
              opacity: entrance,
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0, 0.025),
                  end: Offset.zero,
                ).animate(entrance),
                child: child,
              ),
            );
          },
        ),
      ),
      GoRoute(path: '/login', builder: (context, state) => const LoginPage()),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterPage(),
      ),
      GoRoute(
        path: '/forgot-password',
        builder: (context, state) => const ForgotPasswordPage(),
      ),
      GoRoute(
        path: '/verify-email',
        builder: (context, state) => const VerifyEmailPage(),
      ),
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const OnboardingPage(),
      ),
      StatefulShellRoute.indexedStack(
        pageBuilder: (context, state, navigationShell) =>
            NoTransitionPage<void>(
              key: state.pageKey,
              child: MainShell(navigationShell: navigationShell),
            ),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/discover',
                builder: (context, state) => const DiscoverPage(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/tonight',
                builder: (context, state) => const TonightPage(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/create',
                builder: (context, state) => const CreateEventPage(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/matches',
                builder: (context, state) => const MatchesPage(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/profile',
                builder: (context, state) => const ProfilePage(),
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        path: '/filters',
        builder: (context, state) => const FiltersPage(),
      ),
      GoRoute(
        path: '/events/:eventId',
        builder: (context, state) =>
            EventDetailPage(eventId: state.pathParameters['eventId']!),
      ),
      GoRoute(
        path: '/events/:eventId/requests',
        builder: (context, state) =>
            HostRequestsPage(eventId: state.pathParameters['eventId']!),
      ),
      GoRoute(
        path: '/host',
        pageBuilder: (context, state) => NoTransitionPage<void>(
          key: state.pageKey,
          child: const HostDashboardPage(),
        ),
      ),
      GoRoute(
        path: '/chat/:conversationId',
        builder: (context, state) =>
            ChatPage(conversationId: state.pathParameters['conversationId']!),
      ),
      GoRoute(
        path: '/notifications',
        builder: (context, state) => const NotificationsPage(),
      ),
      GoRoute(
        path: '/profile/edit',
        builder: (context, state) => const EditProfilePage(),
      ),
      GoRoute(
        path: '/friends',
        builder: (context, state) => const FriendsPage(),
      ),
      GoRoute(path: '/safety', builder: (context, state) => const SafetyPage()),
      GoRoute(
        path: '/premium',
        builder: (context, state) => const PremiumPage(),
      ),
      GoRoute(path: '/dj', builder: (context, state) => const DjPage()),
      GoRoute(
        path: '/settings',
        builder: (context, state) => const SettingsPage(),
      ),
      GoRoute(
        path: '/settings/appearance',
        builder: (context, state) => const AppearancePage(),
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      appBar: AppBar(title: const Text('PULLUP')),
      body: Center(child: Text('Route not found: ${state.uri.path}')),
    ),
  );
});

class _RouterRefreshNotifier extends ChangeNotifier {
  void refresh() => notifyListeners();
}
