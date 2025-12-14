// import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:aiSeaSafe/utils/helper/log_helper.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

import 'client/network_client.dart';

class SocialAuthService {
  SocialAuthService._();

  static final GoogleSignIn _googleSignIn = GoogleSignIn(scopes: ['email']);

  static Future<Result<AuthResult, String>> googleSignIn() async {
    try {
      GoogleSignInAccount? googleSignInAccount = await _googleSignIn.signIn();

      if (googleSignInAccount != null) {
        _DisplayName displayName = _getDisplayName(
          googleSignInAccount.displayName,
        );
        AuthResult result = AuthResult(
          id: googleSignInAccount.id,
          firstName: displayName.first,
          lastName: displayName.last,
          email: googleSignInAccount.email,
          profileUrl: googleSignInAccount.photoUrl,
        );
        return Success(result);
      }
      return Failure('Authentication Cancelled');
    } catch (e) {
      LoggerHelper.logError('Authentication Error', e);
      return Failure(e.toString());
    }
  }

  static Future<GoogleSignInAccount?> googleSignOut() {
    return _googleSignIn.signOut();
  }

  static Future<Result<AuthResult, String>> appleSignIn() async {
    try {
      AuthorizationCredentialAppleID appleID =
          await SignInWithApple.getAppleIDCredential(
            scopes: [
              AppleIDAuthorizationScopes.email,
              AppleIDAuthorizationScopes.fullName,
            ],
          );

      AuthResult result = AuthResult(
        id: appleID.userIdentifier,
        firstName: appleID.givenName,
        lastName: appleID.familyName,
        email: appleID.email,
      );
      return Success(result);
    } catch (e) {
      return Failure(e.toString());
    }
  }

  // static Future<Result<AuthResult, String>> facebookSignIn() async {
  //   try {
  //     FacebookAuth facebookAuth = FacebookAuth.instance;
  //     LoginResult loginResult = await facebookAuth.login();

  //     switch (loginResult.status) {
  //       case LoginStatus.success:
  //         AuthResult result = AuthResult(
  //           id: loginResult.accessToken?.userId,
  //         );
  //         return Success(result);
  //       case LoginStatus.failed:
  //       case LoginStatus.cancelled:
  //       case LoginStatus.operationInProgress:
  //         return Failure(loginResult.message ?? '');
  //     }
  //   } on PlatformException catch (e) {
  //     LoginResult loginResult = LoginResult.getResultFromException(e);
  //     return Failure(loginResult.message ?? '');
  //   }
  // }

  static _DisplayName _getDisplayName(String? fullName) {
    List<String> names = fullName?.split(' ') ?? [];

    if (names.length >= 2) {
      return _DisplayName(first: names.first, last: names.last);
    } else {
      return _DisplayName(first: fullName);
    }
  }
}

class _DisplayName {
  final String? first;
  final String? last;

  const _DisplayName({this.first, this.last});
}

class AuthResult {
  final String? firstName;
  final String? lastName;
  final String? id;
  final String? email;
  final String? profileUrl;

  const AuthResult({
    this.firstName,
    this.lastName,
    this.id,
    this.email,
    this.profileUrl,
  });

  @override
  String toString() {
    return '''firstName: $firstName
    lastName: $lastName
    id: $id
    email: $email
    profileUrl: $profileUrl''';
  }
}
