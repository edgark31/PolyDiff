import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobile/constants/app_constants.dart';
import 'package:mobile/constants/app_routes.dart';
import 'package:mobile/constants/app_text_constants.dart';
import 'package:mobile/models/account.dart';
import 'package:mobile/providers/avatar_provider.dart';
import 'package:mobile/providers/register_provider.dart';
import 'package:mobile/providers/theme_provider.dart';
import 'package:mobile/services/account_service.dart';
import 'package:mobile/services/info_service.dart';
import 'package:mobile/services/sound_service.dart';
import 'package:mobile/utils/credentials_validation.dart';
import 'package:mobile/widgets/avatar_picker.dart';
import 'package:mobile/widgets/customs/custom_app_bar.dart';
import 'package:mobile/widgets/widgets.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  static const routeName = EDIT_PROFILE_ROUTE;

  static Route<dynamic> route() {
    return MaterialPageRoute(
      builder: (_) => const EditProfilePage(),
      settings: RouteSettings(name: routeName),
    );
  }

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final TextEditingController usernameController = TextEditingController();
  AvatarProvider _avatarProvider = Get.find();
  InfoService _infoService = Get.find();
  RegisterProvider _registerProvider = Get.find();
  SoundService soundService = Get.find();
  final ThemeProvider themeProvider = Get.find();

  // Same logic when signing up : avatar
  ImageProvider? _selectedAvatar;
  String? _selectedAvatarId;
  String? _selectedAvatarBase64;

  final AccountService accountService = AccountService();
  AccountSettings? initialSettings;
  AccountSettings? currentSettings;

  // Define the lists for dropdown items
  final List<String> languages = ['fr', 'en'];
  final List<String> themes = ['light', 'dark']; // Clair ou sombre

  String serverErrorMessage = "";

  late final CredentialsValidator _validator;

  String usernameFormat = NO;

  TextEditingController passwordController = TextEditingController();
  TextEditingController confirmationController = TextEditingController();

  String passwordStrength = '';
  String passwordConfirmation = '';
  String newPassword = '';

  Queue<String> _snackBarQueue = Queue<String>();
  bool _isSnackBarActive = false;

  @override
  void initState() {
    super.initState();
    print('init State');
    _validator = CredentialsValidator(onStateChanged: _forceRebuild);
    usernameController.addListener(_onUsernameChanged);
    passwordController.addListener(validatePassword);
    confirmationController.addListener(validatePasswordConfirmation);

    _loadInitialSettings();
  }

  void _loadInitialSettings() {
    print('_loadInitialSettings');
    print(_infoService.onCorrectSound.toJson());
    print(_infoService.onErrorSound.toJson());

    initialSettings = AccountSettings.fromInfoService(_infoService);
    currentSettings = AccountSettings.fromInfoService(_infoService);
  }

  void _forceRebuild() => setState(() {});

  void _onUsernameChanged() {
    if (currentSettings != null) {
      currentSettings =
          currentSettings!.copyWith(username: usernameController.text);
      _forceRebuild();
    }
  }

  void validateUsername() {
    _validator.isValidUsername(usernameController.text);
    updateUsernameValidationStates();
  }

  void updateUsernameValidationStates() {
    setState(() {
      usernameFormat = _validator.states['username'] == ValidatorState.isEmpty
          ? ''
          : _validator.states['username'] == ValidatorState.isInvalid
              ? "invalide"
              : '';
    });
  }

  void updateValidatorStates() {
    setState(() {
      passwordStrength = _validator.passwordStrength;
      passwordConfirmation =
          _validator.states['passwordConfirmation'] == ValidatorState.isValid
              ? YES
              : NO;
    });
  }

  void validatePassword() {
    _validator.updatePasswordStrength(passwordController.text);
    updateValidatorStates();
  }

  void validatePasswordConfirmation() {
    _validator.hasMatchingPasswords(
        passwordController.text, confirmationController.text);
    updateValidatorStates();
  }

  void showFeedback(String message) {
    if (_isSnackBarActive) {
      _snackBarQueue.add(message);
      return;
    }

    _isSnackBarActive = true;
    ScaffoldMessenger.of(context)
        .showSnackBar(
          SnackBar(
            content: Text(message),
            duration: Duration(seconds: 1),
          ),
        )
        .closed
        .then((reason) {
      _isSnackBarActive = false;
      if (_snackBarQueue.isNotEmpty) {
        showFeedback(_snackBarQueue.removeFirst());
      }
    });
  }

  Future<void> saveChanges() async {
    try {
      if (_selectedAvatarId != null) {
        UploadAvatarBody predefinedAvatarBody = UploadAvatarBody(
            username: _infoService.username, id: _selectedAvatarId);
        String? response = await _registerProvider.putAvatarData(
            predefinedAvatarBody, AvatarType.predefined);

        print("HERE AVATAR CHANGED");
        print("response : $response");
        if (response == null) {
          _avatarProvider.setAccountAvatarUrl();
          showFeedback("Avatar updated successfully.");
        } else {
          throw Exception(response);
        }
      } else if (_selectedAvatarBase64 != null) {
        print("HERE AVATAR CHANGED WRONG");
        UploadAvatarBody avatarBody = UploadAvatarBody(
            username: _infoService.username,
            base64Avatar: _selectedAvatarBase64!);
        String? response = await _registerProvider.putAvatarData(
            avatarBody, AvatarType.camera);

        if (response == null) {
          showFeedback("Avatar updated successfully.");
        } else {
          throw Exception(response);
        }
      }

      // Password changes
      if (passwordConfirmation == YES &&
          passwordController.text.trim() != newPassword) {
        String? response = await accountService.updatePassword(
            _infoService.username, passwordController.text.trim());
        if (response == null) {
          newPassword = passwordController.text.trim();
          showFeedback("Password updated successfully.");
        } else {
          throw Exception(response);
        }
      }
      // Username changes
      if (usernameController.text.trim() != initialSettings?.username &&
          usernameController.text.trim().isNotEmpty) {
        String? response = await accountService.updateUsername(
            _infoService.username, usernameController.text.trim());
        if (response == null) {
          _infoService.setUsername(usernameController.text.trim());
          showFeedback("Username updated successfully.");
        } else {
          throw Exception(response);
        }
      }
      // Language changes
      if (currentSettings?.language != initialSettings?.language &&
          currentSettings?.language != null) {
        String? response = await accountService.updateLanguage(
            _infoService.username, currentSettings!.language);
        if (response == null) {
          _infoService.setLanguage(currentSettings!.language);
          showFeedback("Language updated successfully.");
        } else {
          throw Exception(response);
        }
      }
      // Theme changes
      print('currentSettings?.theme : ${currentSettings?.theme}');
      print('initialSettings?.theme : ${initialSettings?.theme}');
      if (currentSettings?.theme != initialSettings?.theme &&
          currentSettings?.theme != null) {
        print('HERE THEME CHANGED');
        String? response = await accountService.updateTheme(
            _infoService.username, currentSettings!.theme);
        if (response == null) {
          _infoService.setTheme(currentSettings!.theme);
          themeProvider.toggleTheme(currentSettings!.theme == 'dark');
          showFeedback("Theme updated successfully.");
        } else {
          throw Exception(response);
        }
      }
      // Sound changes
      if (currentSettings?.onErrorSound != initialSettings?.onErrorSound &&
          currentSettings?.onErrorSound != null) {
        String? response = await accountService.updateErrorSound(
            _infoService.username, currentSettings!.onErrorSound);
        if (response == null) {
          _infoService.setOnErrorSound(currentSettings!.onErrorSound);
          showFeedback("Sound onError updated successfully.");
        } else {
          throw Exception(response);
        }
      }
      if (currentSettings?.onCorrectSound != initialSettings?.onCorrectSound &&
          currentSettings?.onCorrectSound != null) {
        String? response = await accountService.updateCorrectSound(
            _infoService.username, currentSettings!.onCorrectSound);
        if (response == null) {
          _infoService.setOnCorrectSound(currentSettings!.onCorrectSound);
          showFeedback("Correct sound updated successfully.");
        } else {
          throw Exception(response);
        }
      }

      // Refresh initial settings to the current state
      initialSettings = AccountSettings.fromInfoService(_infoService);
    } catch (e) {
      showFeedback(e.toString());
    }
  }

  @override
  void dispose() {
    usernameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        drawer: CustomMenuDrawer(),
        appBar: CustomAppBar(title: "Personnalisation du profil"),
        body: Container(
            padding: EdgeInsets.only(left: 15, top: 20, right: 15),
            child: GestureDetector(
                onTap: () {
                  FocusScope.of(context).unfocus();
                },
                child: ListView(
                  children: [
                    Row(
                      children: [
                        buildSelectedAvatar(),
                        SizedBox(width: 100),
                        buildAvatarPicker(),
                      ],
                    ),
                    SizedBox(height: 30),
                    buildUsernameField(),
                    SizedBox(height: 30),
                    buildPasswordField(),
                    buildPasswordConfirmationField(),
                    SizedBox(height: 30),
                    DropdownButtonFormField<Sound>(
                      value: currentSettings?.onErrorSound,
                      onChanged: (newValue) {
                        if (newValue != null) {
                          soundService.playOnErrorSound(newValue);
                          currentSettings =
                              currentSettings!.copyWith(onErrorSound: newValue);
                        }
                      },
                      items: ERROR_SOUND_LIST.map((sound) {
                        return DropdownMenuItem(
                            value: sound, child: Text(sound.name));
                      }).toList(),
                      decoration: InputDecoration(labelText: "Son d'erreur"),
                    ),
                    DropdownButtonFormField<Sound>(
                      value: currentSettings?.onCorrectSound,
                      onChanged: (Sound? newValue) {
                        if (newValue != null) {
                          soundService.playOnCorrectSound(newValue);
                          currentSettings = currentSettings!
                              .copyWith(onCorrectSound: newValue);
                        }
                      },
                      items: CORRECT_SOUND_LIST.map((sound) {
                        return DropdownMenuItem(
                            value: sound, child: Text(sound.name));
                      }).toList(),
                      decoration: InputDecoration(
                          labelText: "Son de différence trouvée"),
                    ),
                    // Choisir le thème de l'application
                    DropdownButtonFormField<String>(
                      value: currentSettings!.theme,
                      items:
                          themes.map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        if (newValue != null) {
                          currentSettings =
                              currentSettings!.copyWith(theme: newValue);
                        }
                        setState(() {
                          // final themeProvider = Provider.of<ThemeProvider>(
                          //     context,
                          //     listen: false);
                          // themeProvider.toggleTheme(newValue == 'dark');
                        });
                      },
                      decoration: InputDecoration(labelText: 'Theme'),
                    ),
                    // Choisir la langue de l'application
                    DropdownButtonFormField<String>(
                      value: currentSettings!.language,
                      items: languages
                          .map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                      onChanged: (newValue) {
                        if (newValue != null) {
                          currentSettings =
                              currentSettings!.copyWith(language: newValue);
                        }
                      },
                      decoration: InputDecoration(labelText: "Langue"),
                    ),
                    Row(
                      children: [
                        OutlinedButton(
                          onPressed: () {},
                          style: OutlinedButton.styleFrom(
                              padding: EdgeInsets.symmetric(horizontal: 50),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20))),
                          child: Text(CANCEL_BTN_TXT,
                              style: TextStyle(
                                fontSize: 15,
                                color: Colors.red,
                                letterSpacing: 2,
                              )),
                        ),
                        SizedBox(width: 125),
                        ElevatedButton(
                          onPressed: () => saveChanges(),
                          style: ElevatedButton.styleFrom(
                              backgroundColor: kMidOrange,
                              padding: EdgeInsets.symmetric(horizontal: 50),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20))),
                          child: Text(SAVE_BTN_TXT,
                              style: TextStyle(
                                fontSize: 15,
                                letterSpacing: 2,
                                color: kLight,
                              )),
                        ),
                      ],
                    )
                  ],
                ))));
  }

  Widget buildUsernameField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomTextInputField(
          label: "Nom d'utilisateur",
          controller: usernameController,
          hint: "Entrez votre nom d'utilisateur",
          helperText: 'Non vide: $usernameFormat',
          maxLength: 20,
        ),
        SizedBox(height: 10),
      ],
    );
  }

  Widget buildPasswordField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomTextInputField(
          label: "Mot de passe",
          controller: passwordController,
          hint: "Entrez votre mot de passe",
          helperText: 'Force du mot de passe: $passwordStrength',
          errorText: _validator.states['password'] == ValidatorState.isEmpty
              ? "Mot de passe requis"
              : null,
          maxLength: 20,
          isPassword: true,
        ),
        SizedBox(height: 10),
      ],
    );
  }

  Widget buildPasswordConfirmationField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomTextInputField(
          label: "Confirmation du mot de passe",
          controller: confirmationController,
          hint: "Confirmez votre mot de passe",
          helperText:
              'Doit correspondre au mot de passe: $passwordConfirmation',
          maxLength: 20,
          errorText: _validator.states['passwordConfirmation'] ==
                  ValidatorState.isEmpty
              ? "Veuillez confirmer votre mot de passe"
              : _validator.states['passwordConfirmation'] ==
                      ValidatorState.isInvalid
                  ? "Les mots de passes doivent être identiques"
                  : null,
          isPassword: true,
        ),
        SizedBox(height: 10),
      ],
    );
  }

  Widget buildSelectedAvatar() {
    return CircleAvatar(
      backgroundImage: _selectedAvatar,
      radius: 50,
      backgroundColor: Colors.grey.shade200,
      child: _selectedAvatar == null ? Icon(Icons.person, size: 50) : null,
    );
  }

  void setPredefinedAvatarSelection(String id) {
    _selectedAvatarId = id;
  }

  void setCameraAvatarSelection(String base64) {
    _selectedAvatarBase64 = base64;
  }

  Widget buildAvatarPicker() {
    return AvatarPicker(
      onAvatarSelected: (ImageProvider image, {String? id, String? base64}) {
        if (id != null) {
          setPredefinedAvatarSelection(id);
        } else if (base64 != null) {
          setCameraAvatarSelection(base64);
        }
        // Updates the UI
        setState(() {
          _selectedAvatar = image;
        });
      },
    );
  }
}
