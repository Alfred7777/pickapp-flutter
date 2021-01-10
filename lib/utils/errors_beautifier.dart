import 'dart:convert';

class ErrorsBeautifier {
  static String call(String responseBody) {
    var errors = Map<String, dynamic>.from(json.decode(responseBody)['errors']);
    var error_formatted = '';

    errors.forEach((key, value) {
      error_formatted = error_formatted +
          capitalize(key.toString().replaceAll('_', ' ')) +
          ' ' +
          value.toString().replaceAll('[', '').replaceAll(']', '') +
          ' ' +
          '\n';
    });

    return error_formatted.substring(0, error_formatted.length - 1);
  }

  static String capitalize(String s) => s[0].toUpperCase() + s.substring(1);
}
