import 'dart:convert';
import 'dart:io';
import 'package:PickApp/main.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'repositories/user_repository.dart';

class AuthenticatedApiClient {
  final userRepository = UserRepository();
  final apiUrl = 'http://150.254.78.200/api/';

  Future getAuthToken() async {
    var token = await userRepository.getAuthToken();
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

    while (response == null) {
      try {
        response = await http.post(
          apiUrl + url,
          headers: getHeaders(token, headers),
          body: json.encode(body),
        );
      } on SocketException {
        await showConnectionDialog();
      }
    }

    return response;
  }

  Future<http.Response> get(url, {Map<String, String> headers}) async {
    var response;
    var token = await getAuthToken();

    while (response == null) {
      try {
        response = await http.get(
          apiUrl + url,
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

    while (response == null) {
      try {
        response = await http.delete(
          apiUrl + url,
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

    while (response == null) {
      try {
        response = await http.put(
          apiUrl + url,
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
