import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../features/auth/google_signin_page.dart';
import '../features/home/home_page.dart';
import '../features/property/property_web_page.dart';
import '../features/search/presentation/search_page.dart';
import '../features/search/presentation/search_results_page.dart';


final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/auth',
    routes: [
      GoRoute(
        path: '/auth',
        name: 'auth',
        builder: (ctx, state) => const GoogleSignInPage(),
      ),
      GoRoute(
        path: '/',
        name: 'home',
        builder: (ctx, state) => const HomePage(),
      ),
      GoRoute(
        path: '/search',
        name: 'search',
        builder: (ctx, state) => const SearchPage(),
      ),
      GoRoute(
        path: '/search/results',
        name: 'results',
        builder: (ctx, state) => const SearchResultsPage(),
      ),
      GoRoute(
        name: 'propertyWeb',
        path: '/propertyWeb',
        pageBuilder: (context, state) {
          final url = state.extra as String?;
          return MaterialPage(child: PropertyWebPage(url: url));
        },
      ),
    ],
  );
});