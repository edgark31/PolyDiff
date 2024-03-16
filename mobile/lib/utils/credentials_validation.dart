import 'package:mobile/constants/app_text_constants.dart';

enum NewInputStateMessageEnum {
  usernameInput(
    invalidMessage: "Veuillez entrée un nom d'utilisateur valide",
    isEmptyMessage: "Nom d'utilisateur requis",
  ),
  emailInputField(
    invalidMessage: "Veuillez entrer une adresse courriel valide",
    isEmptyMessage: "Addresse courriel requis(e)",
  ),
  selectedAvatar(
    invalidMessage: "Veuillez choisir une format de l'avatar valide",
    isEmptyMessage: "Veuillez sélectionné un avatar",
  ),
  passwordInput(
    invalidMessage: "Veuillez entrée un mot de passe valide",
    isEmptyMessage: "Mot de passe requis",
  );

  final String invalidMessage;
  final String isEmptyMessage;

  const NewInputStateMessageEnum({
    required this.invalidMessage,
    required this.isEmptyMessage,
  });
}

enum LoginInputFieldsStateMessageEnum {
  usernameInput(
    invalidMessage: "Utilisateur inconnu",
    isEmptyMessage: "Nom d'utilisateur ou addresse courriel requis(e)",
  ),
  passwordInput(
    invalidMessage: "Veuillez entrée un mot de passe valide",
    isEmptyMessage: "Mot de passe requis",
  );

  final String invalidMessage;
  final String isEmptyMessage;

  const LoginInputFieldsStateMessageEnum({
    required this.invalidMessage,
    required this.isEmptyMessage,
  });
}

enum ValidatorState {
  isValid,
  isInvalid,
  isEmpty,
  isNotEmpty;

  String get inputValidatorStateMessage {
    switch (this) {
      case ValidatorState.isInvalid:
        return 'Champ invalide';

      case ValidatorState.isValid:
        return '';

      case ValidatorState.isEmpty:
        return 'Information requise';

      case ValidatorState.isNotEmpty:
        return '';
    }
  }
}

class CredentialsValidator {
  Function? onStateChanged;

  CredentialsValidator({this.onStateChanged});

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
  Map<String, ValidatorState> states = {
    'username': ValidatorState.isEmpty,
    'email': ValidatorState.isEmpty,
    'password': ValidatorState.isEmpty,
    'passwordConfirmation': ValidatorState.isEmpty,
  };

  bool isValidUsername(String username) {
    ValidatorState state =
        username.isNotEmpty ? ValidatorState.isValid : ValidatorState.isInvalid;

    states['username'] = state;
    notifyStateChanged();

    return state == ValidatorState.isValid;
  }

  bool isValidEmail(String email) {
    ValidatorState state = emailRegex.hasMatch(email) && email.isNotEmpty
        ? ValidatorState.isValid
        : ValidatorState.isInvalid;

    states['email'] = state;
    notifyStateChanged();

    return state == ValidatorState.isValid;
  }

  void updatePasswordStrength(String password) {
    if (password.isEmpty) {
      passwordStrength = '';
      states['password'] = ValidatorState.isEmpty;
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

    states['password'] = ValidatorState.isValid;
    notifyStateChanged();
  }

  bool hasMatchingPasswords(String password, String confirmation) {
    bool areMatching = password == confirmation && password.isNotEmpty;

    states['passwordConfirmation'] =
        areMatching ? ValidatorState.isValid : ValidatorState.isInvalid;
    notifyStateChanged();

    return areMatching;
  }

  bool hasValidCredentials() {
    return states.values.every((state) => state == ValidatorState.isValid);
  }
}
