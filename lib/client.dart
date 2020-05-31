import 'dart:convert';
import 'package:http/http.dart' as http;
import 'repositories/userRepository.dart';

class AuthenticatedApiClient {
  final userRepository = UserRepository();
  final apiUrl = 'http://150.254.78.200/api/';

  Future getAuthToken() async {
    var token = await userRepository.getAuthToken();
    return token;
  }

  Map<String, String> getHeaders(dynamic token, Map<String, String> additionalHeaders){
    final headers = {'Authorization': 'Bearer $token', 'Content-type': 'application/json'};
    if (additionalHeaders is Map) {
      headers.addAll(additionalHeaders);
    }
    return headers;
  }
  Future <http.Response> post(url, {Map<String, String> headers, dynamic body}) async {
    var token = await getAuthToken();
    var response = await http.post(apiUrl + url, headers: getHeaders(token, headers), body: json.encode(body));
    return response;
  }
  Future <http.Response> get(url, {Map<String, String> headers}) async{
    var token = await getAuthToken();
    var response = http.get(apiUrl + url, headers: getHeaders(token, headers));
    return response;
  }

  Future <http.Response> delete(url, {Map<String, String> headers}) async{
    var token = await getAuthToken();
    var response = http.delete(apiUrl + url, headers: getHeaders(token, headers));
    return response;
  }
  Future <http.Response> put(url, {Map<String, String> headers, dynamic body}) async{
    var token = await getAuthToken();
    var response = http.put(apiUrl + url, headers: getHeaders(token, headers), body: json.encode(body));
    return response;
  }

}