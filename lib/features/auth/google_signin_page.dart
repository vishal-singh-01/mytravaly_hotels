import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'bootstrap_controller.dart';
import 'google_signin_controller.dart';


class GoogleSignInPage extends ConsumerWidget {
  const GoogleSignInPage({super.key});



  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(googleUserProvider);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark.copyWith(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
      ),
      child: Scaffold(
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          systemOverlayStyle: SystemUiOverlayStyle.dark,
          title: const Text(
            'Welcome Travelers',
            style: TextStyle(color: Colors.black87),
          ),
          iconTheme: const IconThemeData(color: Colors.black87),
        ),
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFFE8F1FF),
                Color(0xFFD6E4F0),
                Color(0xFFBFD7ED),
              ],
            ),
          ),
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.asset(
                    'assets/travel.png',
                    width: 80,
                    height: 80,
                    fit: BoxFit.contain,
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Sign in with Google',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: Colors.black87,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 24),
                  if (user == null) ...[
                    FilledButton.icon(
                      icon: const Icon(Icons.login),
                      label: const Text('Continue with Google'),
                      onPressed: () async {
                        try {
                          await ref.read(googleUserProvider.notifier).signIn();
                          await ref.read(appBootstrapProvider.notifier).init();

                          if (context.mounted) context.goNamed('home');
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(e.toString())),
                          );
                        }
                      },
                    ),
                    const SizedBox(height: 8),
                    TextButton.icon(
                      icon: const Icon(Icons.home),
                      label: const Text('Go To Home'),
                      onPressed: () async {
                        await ref.read(appBootstrapProvider.notifier).init();
                        if (context.mounted) context.goNamed('home');
                      },
                    ),
                  ] else ...[
                    CircleAvatar(
                      radius: 40,
                      backgroundImage: user.photoUrl != null
                          ? NetworkImage(user.photoUrl!)
                          : null,
                      backgroundColor: Colors.white,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      user.displayName,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    Text(
                      user.email,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.black54,
                      ),
                    ),
                    const SizedBox(height: 20),
                    FilledButton.icon(
                      icon: const Icon(Icons.arrow_forward),
                      label: const Text('Go to Home'),
                      onPressed: () => context.goNamed('home'),
                    ),
                    TextButton.icon(
                      icon: const Icon(Icons.logout),
                      label: const Text('Sign out'),
                      onPressed: () =>
                          ref.read(googleUserProvider.notifier).signOut(),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}