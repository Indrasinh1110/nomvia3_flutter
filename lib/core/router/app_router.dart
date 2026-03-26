import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:nomvia/core/services/auth_service.dart';
import 'package:nomvia/domain/entities/trip.dart';
import 'dart:async';
import '../../features/auth/presentation/pages/login_screen.dart';
import '../../features/auth/presentation/pages/otp_screen.dart';
import '../../features/auth/presentation/pages/splash_screen.dart';
import '../../features/chat/presentation/pages/chat_screen.dart';
import '../../features/explore/presentation/pages/explore_screen.dart';
import '../../features/home/presentation/pages/home_screen.dart';
import '../../features/main_wrapper.dart';
import '../../features/profile/presentation/pages/profile_screen.dart';
import '../../features/trip/presentation/pages/trip_detail_screen.dart';
import '../../features/booking/presentation/pages/booking_kyc_screen.dart';
import '../../features/booking/presentation/pages/booking_payment_screen.dart';
import '../../features/booking/presentation/pages/booking_success_screen.dart';
import '../../features/agency/presentation/pages/agency_profile_screen.dart';
import '../../features/chat/presentation/pages/chat_detail_screen.dart';
import 'package:nomvia/domain/entities/agency.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();

final appRouterProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateChangesProvider);

  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/',
    refreshListenable: authState.when(
      data: (user) => GoRouterRefreshStream(ref.read(authServiceProvider).authStateChanges),
      loading: () => null,
      error: (_, __) => null,
    ),
    redirect: (context, state) {
      final user = authState.asData?.value;
      final isLoggedIn = user != null;
      final isLoggingIn = state.uri.path == '/login' || state.uri.path == '/otp';
      final isSplash = state.uri.path == '/';

      if (authState.isLoading) return null;

      if (!isLoggedIn && !isLoggingIn && !isSplash) {
        return '/login';
      }

      if (isLoggedIn && (isLoggingIn || isSplash)) {
        return '/main/home';
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/otp',
        builder: (context, state) {
          final verificationId = state.extra as String;
          return OtpScreen(verificationId: verificationId);
        },
      ),
      GoRoute(
        path: '/main',
        redirect: (context, state) => '/main/home',
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return MainWrapper(navigationShell: navigationShell);
        },
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/main/home',
                builder: (context, state) => const HomeScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/main/explore',
                builder: (context, state) => const ExploreScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/main/chat',
                builder: (context, state) => const ChatScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/main/profile',
                builder: (context, state) => const ProfileScreen(),
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        path: '/trip/:id',
        builder: (context, state) {
          final trip = state.extra as Trip?;
          final id = state.pathParameters['id']!;
          return TripDetailScreen(tripId: id, trip: trip); 
        },
      ),
      GoRoute(
        path: '/booking/kyc/:tripId',
        builder: (context, state) => BookingKYCScreen(tripId: state.pathParameters['tripId']!),
      ),
      GoRoute(
        path: '/booking/payment/:tripId',
        builder: (context, state) => BookingPaymentScreen(tripId: state.pathParameters['tripId']!),
      ),
      GoRoute(
        path: '/booking/success',
        builder: (context, state) => const BookingSuccessScreen(),
      ),
      GoRoute(
        path: '/agency/:id',
        builder: (context, state) {
           final agency = state.extra as Agency?;
           final id = state.pathParameters['id']!;
           return AgencyProfileScreen(agencyId: id, agency: agency);
        },
      ),
      GoRoute(
        path: '/chat/:type/:id',
        builder: (context, state) => ChatDetailScreen(id: state.pathParameters['id']!),
      ),
      GoRoute(
        path: '/profile/:id',
        builder: (context, state) {
           return ProfileScreen(userId: state.pathParameters['id'], key: ValueKey(state.pathParameters['id'])); // Pass extra via state in ProfileScreen
        },
      ),
    ],
  );
});

class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners();
    _subscription = stream.asBroadcastStream().listen(
      (dynamic _) => notifyListeners(),
    );
  }

  late final StreamSubscription<dynamic> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
