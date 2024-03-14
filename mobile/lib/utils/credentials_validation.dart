import 'package:mobile/constants/app_text_constants.dart';

enum ValidationState { valid, invalid }

enum EmptyState { isEmpty, notEmpty }

class CredentialsValidation {
  Function? onStateChanged;

  CredentialsValidation({this.onStateChanged});

  void notifyStateChanged() {
    onStateChanged?.call();
  }

  // Regex
  final RegExp emailRegex =
      RegExp(r'^[\w-]+(\.[\w-]+)*@([\w-]+\.)+[a-zA-Z]{2,7}$');
  final RegExp weakIndicatorRegex = RegExp(r'[a-zA-Z0-9]');
  final RegExp strongIndicatorRegex = RegExp(r'[$,!,&]');

  String passwordStrength = '';

  // InputTextField states
  Map<String, ValidationState> states = {
    'username': ValidationState.invalid,
    'email': ValidationState.invalid,
    'password': ValidationState.invalid,
    'passwordConfirmation': ValidationState.invalid,
  };

  bool isValidUsername(String username) {
    var state =
        username.isNotEmpty ? ValidationState.valid : ValidationState.invalid;

    states['username'] = state;
    notifyStateChanged();

    return state == ValidationState.valid;
  }

  bool isValidEmail(String email) {
    var state = emailRegex.hasMatch(email) && email.isNotEmpty
        ? ValidationState.valid
        : ValidationState.invalid;

    states['email'] = state;
    notifyStateChanged();

    return state == ValidationState.valid;
  }

  void updatePasswordStrength(String password) {
    if (password.isEmpty) {
      passwordStrength = '';
      states['password'] = ValidationState.invalid;
      return;
    }

    bool hasWeakIndicator = weakIndicatorRegex.hasMatch(password);
    bool hasStrongIndicator = strongIndicatorRegex.hasMatch(password);
    int length = password.length;

    if (length < 10) {
      passwordStrength = hasWeakIndicator ? WEAK_PASSWORD : AVERAGE_PASSWORD;
    } else if (length >= 10) {
      if (hasStrongIndicator) {
        passwordStrength = STRONG_PASSWORD;
      } else {
        passwordStrength = AVERAGE_PASSWORD;
      }
    }

    states['password'] = ValidationState.valid;
    notifyStateChanged();
  }

  bool hasMatchingPasswords(String password, String confirmation) {
    bool areMatching = password == confirmation && password.isNotEmpty;

    states['passwordConfirmation'] =
        areMatching ? ValidationState.valid : ValidationState.invalid;
    notifyStateChanged();

    return areMatching;
  }

  bool hasValidCredentials() {
    return states.values.every((state) => state == ValidationState.valid);
  }
}
