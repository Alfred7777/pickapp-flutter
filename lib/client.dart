import 'dart:convert';
import 'dart:io';
import 'package:PickApp/main.dart';
import 'package:PickApp/repositories/authentication_repository.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class AuthenticatedApiClient {
  final apiUrl = '18.197.42.194';
  final apiPort = 4000;

  Future getAuthToken() async {
    var token = await AuthenticationRepository.getAuthToken();
    return token;
  }

  Map<String, String> getHeaders(
      dynamic token, Map<String, String> additionalHeaders) {
    final headers = {
      'Authorization': 'Bearer $token',
      'Content-type': 'application/json',
    };
    if (additionalHeaders is Map) {
      headers.addAll(additionalHeaders);
    }
    return headers;
  }

  Future<http.Response> post(url,
      {Map<String, String> headers, dynamic body}) async {
    var response;
    var token = await getAuthToken();
    var uri = Uri(
      scheme: 'http',
      host: apiUrl,
      port: apiPort,
      path: '/api/' + url,
    );

    while (response == null) {
      try {
        response = await http.post(
          uri,
          headers: getHeaders(token, headers),
          body: json.encode(body),
        );
      } on SocketException {
        await showConnectionDialog();
      }
    }

    return response;
  }

  Future<http.Response> get(url,
      {Map<String, String> headers, Map<String, dynamic> queryParams}) async {
    var response;
    var token = await getAuthToken();
    var uri = Uri(
      scheme: 'http',
      host: apiUrl,
      port: apiPort,
      path: '/api/' + url,
      queryParameters: queryParams,
    );

    while (response == null) {
      try {
        response = await http.get(
          uri,
          headers: getHeaders(token, headers),
        );
      } on SocketException {
        await showConnectionDialog();
      }
    }

    return response;
  }

  Future<http.Response> delete(url, {Map<String, String> headers}) async {
    var response;
    var token = await getAuthToken();
    var uri = Uri(
      scheme: 'http',
      host: apiUrl,
      port: apiPort,
      path: '/api/' + url,
    );

    while (response == null) {
      try {
        response = await http.delete(
          uri,
          headers: getHeaders(token, headers),
        );
      } on SocketException {
        await showConnectionDialog();
      }
    }

    return response;
  }

  Future<http.Response> put(url,
      {Map<String, String> headers, dynamic body}) async {
    var response;
    var token = await getAuthToken();
    var uri = Uri(
      scheme: 'http',
      host: apiUrl,
      port: apiPort,
      path: '/api/' + url,
    );

    while (response == null) {
      try {
        response = await http.put(
          uri,
          headers: getHeaders(token, headers),
          body: json.encode(body),
        );
      } on SocketException {
        await showConnectionDialog();
      }
    }
    return response;
  }

  void showConnectionDialog() async {
    await showDialog(
      context: navigatorKey.currentContext,
      builder: (BuildContext context) {
        return _buildConnectionAlert(context);
      },
    );
  }

  Widget _buildConnectionAlert(BuildContext context) {
    return AlertDialog(
      title: Text('Connection Error!'),
      content: Text('Failed to connect to the server.'),
      actions: [
        FlatButton(
          child: Text('Try Again'),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        FlatButton(
          child: Text('Close App'),
          onPressed: () {
            exit(0);
          },
        ),
      ],
    );
  }
}
