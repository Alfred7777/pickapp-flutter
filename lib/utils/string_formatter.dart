class StringFormatter {
  static String formatErrors(Map<String, dynamic> errors) {
    var errorMessage = '';
    var errorsMap = <String, dynamic>{};
    errors.keys.forEach((key) {
      var errorMessage = '';
      errors[key].forEach((message) {
        if (message.contains('blank')) {
          errorMessage = errorMessage +
              '${key[0].toUpperCase()}${key.substring(1)} is required!\n';
        } else {
          errorMessage = errorMessage + message + '\n';
        }
      });
      errorsMap[key] = errorMessage.substring(0, errorMessage.length - 1);
    });

    errorsMap.forEach((k, v) {
      errorMessage = errorMessage + v + '\n';
    });

    return capitalize(errorMessage);
  }

  static String capitalize(String s) => s[0].toUpperCase() + s.substring(1);
}
