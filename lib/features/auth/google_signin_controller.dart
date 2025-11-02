import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'google_user.dart';
import 'package:google_sign_in/google_sign_in.dart';

final googleSignInProvider = Provider((ref) => GoogleSignIn(scopes: ['email', 'profile']));

final googleUserProvider = StateNotifierProvider<GoogleUserController, GoogleUserProfile?>((ref) {
  return GoogleUserController(ref);
});

class GoogleUserController extends StateNotifier<GoogleUserProfile?> {
  GoogleUserController(this.ref) : super(null);

  final Ref ref;

  Future<void> signIn() async {
    final google = ref.read(googleSignInProvider);
    final account = await google.signIn();
    if (account != null) {
      state = GoogleUserProfile(
        displayName: account.displayName ?? 'Guest',
        email: account.email,
        photoUrl: account.photoUrl,
      );
    }
  }

  Future<void> signOut() async {
    final google = ref.read(googleSignInProvider);
    await google.signOut();
    state = null;
  }
}
