import 'dart:convert';
import 'package:PickApp/main.dart';
import 'package:meta/meta.dart';
import 'package:flutter_facebook_login/flutter_facebook_login.dart';
import 'package:http/http.dart';

class AuthenticationRepository {
  static final apiUrl = 'http://150.254.78.200/api/';

  static final signInWithFacebookFailedMessage =
      'Something went wrong while trying to sign in with Facebook. Please try again later.';

  static final signInWithFacebookCancelledMessage =
      "It seems like you cancelled logging in. Please try again or report the issue in case it's unexpected.";

  static Future<String> signInWithEmail({
    @required String email,
    @required String password,
  }) async {
    final url = apiUrl + 'login';

    var headers = {'Content-type': 'application/json'};
    var json = '{"email": "$email", "password": "$password"}';

    var response = await post(url, headers: headers, body: json);

    if (response.statusCode == 200) {
      return response.body;
    } else {
      throw Exception();
    }
  }

  static Future<Map<String, dynamic>> signInWithFacebook() async {
    final url = apiUrl + 'fb_sign_in';
    final facebookLogin = FacebookLogin();

    final fbLoginResult = await facebookLogin.logIn(['email']);

    switch (fbLoginResult.status) {
      case FacebookLoginStatus.loggedIn:
        var fbAuthToken = fbLoginResult.accessToken.token;
        var headers = {'Content-type': 'application/json'};
        var payload = json.encode({'fb_auth_token': fbAuthToken});
        var response = await post(url, headers: headers, body: payload);

        if (response.statusCode == 201) {
          var decoded = json.decode(response.body);

          return {
            'authToken': decoded['auth_token'],
            'userData': decoded['user_data'],
            'fbAuthToken': decoded['fb_auth_token'],
            'userId': decoded['user_id']
          };
        } else {
          throw Exception(signInWithFacebookFailedMessage);
        }
        break;

      case FacebookLoginStatus.cancelledByUser:
        throw Exception(signInWithFacebookCancelledMessage);
        break;

      case FacebookLoginStatus.error:
        throw Exception(signInWithFacebookFailedMessage);
        break;
    }
    return null;
  }

  static void logOutWithFb() {
    final facebookLogin = FacebookLogin();
    facebookLogin.logOut();
  }

  static Future<String> getAuthToken() async {
    final authToken = await storage.read(key: 'jwt');
    if (authToken == null) return '';
    return authToken;
  }

  static Future<void> deleteToken() async {
    await storage.delete(key: 'jwt');
    return;
  }

  static Future<void> persistToken(String authToken) async {
    if (authToken != null) {
      await storage.write(key: 'jwt', value: authToken);
    }
    return;
  }

  static Future<bool> hasToken() async {
    final key = await storage.read(key: 'jwt');
    if (key == null) return false;
    return true;
  }
}
