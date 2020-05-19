import 'package:meta/meta.dart';
import 'package:http/http.dart';
import 'dart:convert';
import 'package:PickApp/main.dart';

class UserRepository {
  Future<String> authenticate({
    @required String email,
    @required String password,
  }) async {
    final url = 'http://150.254.78.200/api/login';
    var headers = {'Content-type': 'application/json'};
    var json = '{"email": "$email", "password": "$password"}';

    var response = await post(url, headers: headers, body: json);

    if (response.statusCode == 200) {
      return response.body;
    } else {
      throw Exception();
    }
  }

  Future<String> getAuthToken() async {
    final auth_token = await storage.read(key: 'jwt');
    if (auth_token == null) return '';
    return auth_token;
  }

  Future<void> deleteToken() async {
    await storage.delete(key: 'jwt');
    await Future<void>.delayed(Duration(seconds: 1));
    return;
  }

  Future<void> persistToken(String token) async {
    var auth_token = (json.decode(token))['auth_token'];
    await storage.write(key: 'jwt', value: auth_token);
    await Future<void>.delayed(Duration(seconds: 1));
    return;
  }

  Future<bool> hasToken() async {
    await storage.read(key: 'jwt').then((_) => true);
    await Future<bool>.delayed(Duration(seconds: 1));
    return false;
  }
}
