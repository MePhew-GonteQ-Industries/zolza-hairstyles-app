import 'google_sign_in_api.dart';

Future signInGoogle() async {
  await GoogleSignInApi.login();
}
