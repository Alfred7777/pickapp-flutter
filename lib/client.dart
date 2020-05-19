import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:PickApp/repositories/userRepository.dart';

class AuthenticatedApiClient extends http.BaseClient {
  final http.Client _httpClient = http.Client();
  final userRepository = UserRepository();
  final api_url = 'http://150.254.78.200/api/';

  bool isMapEmpty(Map<String, String> map) {
    return (map is Map) ? map.isEmpty : false;
  }

  Future getAuthHeader() async {
    final token = await userRepository.getAuthToken();
    final auth_header = {'Authorization': 'Bearer ' + token};
    return auth_header;
  }

  Future getHeadersMap(Map<String, String> headers) async {
    var auth_header = await getAuthHeader();
    if (isMapEmpty(headers)) {
      headers.addAll(auth_header);
    } else {
      headers = auth_header;
    }
    return headers;
  }

  @override
  Future<http.Response> delete(url, {Map<String, String> headers}) async {
    var request_headers = await getHeadersMap(headers);
    return _httpClient.delete(api_url + url, headers: request_headers);
  }

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request,
      {Map<String, String> headers}) async {
    var request_headers = await getHeadersMap(headers);
    request.headers.addAll(request_headers);
    return _httpClient.send(request);
  }

  @override
  Future<http.Response> get(url, {Map<String, String> headers}) async {
    var request_headers = await getHeadersMap(headers);
    return _httpClient.get(api_url + url, headers: request_headers);
  }

  @override
  Future<http.Response> post(url,
      {Map<String, String> headers, dynamic body, Encoding encoding}) async {
    var request_headers = await getHeadersMap(headers);
    return _httpClient.post(url,
        headers: request_headers, body: body, encoding: encoding);
  }

  @override
  Future<http.Response> patch(url,
      {Map<String, String> headers, dynamic body, Encoding encoding}) async {
    var request_headers = await getHeadersMap(headers);
    return _httpClient.post(url,
        headers: request_headers, body: body, encoding: encoding);
  }

  @override
  Future<http.Response> put(url,
      {Map<String, String> headers, dynamic body, Encoding encoding}) async {
    var request_headers = await getHeadersMap(headers);
    return _httpClient.post(url,
        headers: request_headers, body: body, encoding: encoding);
  }

  @override
  Future<http.Response> head(url, {Map<String, String> headers}) async {
    var request_headers = await getHeadersMap(headers);
    return _httpClient.post(url, headers: request_headers);
  }
}
