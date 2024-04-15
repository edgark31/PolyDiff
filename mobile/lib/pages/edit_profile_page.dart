import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:get/get.dart';
import 'package:mobile/constants/app_constants.dart';
import 'package:mobile/constants/app_routes.dart';
import 'package:mobile/constants/app_text_constants.dart';
import 'package:mobile/models/account.dart';
import 'package:mobile/providers/avatar_provider.dart';
import 'package:mobile/providers/register_provider.dart';
import 'package:mobile/services/account_service.dart';
import 'package:mobile/services/info_service.dart';
import 'package:mobile/services/socket_service.dart';
import 'package:mobile/services/sound_service.dart';
import 'package:mobile/utils/credentials_validation.dart';
import 'package:mobile/widgets/avatar_picker.dart';
import 'package:mobile/widgets/customs/custom_app_bar.dart';
import 'package:mobile/widgets/widgets.dart';
import 'package:provider/provider.dart';

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
  final SocketService socketService = Get.find();

  // Same logic when signing up : avatar
  ImageProvider? _selectedAvatar;
  String? _selectedAvatarId;
  String? _selectedAvatarBase64;
  String? _newSelectedAvatarId = 'id';
  String? _newSelectedAvatarBase64 = 'base64';

  final AccountService accountService = AccountService();
  AccountSettings? initialSettings;
  AccountSettings? currentSettings;

  // Define the lists for dropdown items
  final List<String> languages = ['fr', 'en'];
  final List<String> themes = ['light', 'dark']; // Clair ou sombre

  String serverErrorMessage = "";

  late final CredentialsValidator _validator;

  String usernameFormat = '';

  TextEditingController passwordController = TextEditingController();
  TextEditingController confirmationController = TextEditingController();

  String passwordStrength = '';
  String passwordConfirmation = '';
  String newPassword = '';

  String avatarFeedback = '';
  String passwordFeedback = '';
  String usernameFeedback = '';
  String languageFeedback = '';
  String themeFeedback = '';
  String errorSoundFeedback = '';
  String differenceFoundSoundFeedback = '';

  Queue<String> _snackBarQueue = Queue<String>();
  bool _isSnackBarActive = false;

  @override
  void initState() {
    Future.delayed(Duration.zero, () {
      if (ModalRoute.of(context)?.isCurrent ?? false) {
        socketService.onlyAuthSocketShouldBeConnected(
            pageName: EDIT_PROFILE_ROUTE);
      }
    });
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
              ? AppLocalizations.of(context)!.edit_profile_invalid
              : '';
    });
  }

  void updateValidatorStates() {
    setState(() {
      passwordStrength = _validator.passwordStrength;
      switch (passwordStrength) {
        case WEAK_PASSWORD:
          passwordStrength =
              AppLocalizations.of(context)!.edit_profile_passwordWeak;
          break;
        case AVERAGE_PASSWORD:
          passwordStrength =
              AppLocalizations.of(context)!.edit_profile_passwordAverage;
          break;
        case STRONG_PASSWORD:
          passwordStrength =
              AppLocalizations.of(context)!.edit_profile_passwordStrong;
          break;
      }
      passwordConfirmation =
          _validator.states['passwordConfirmation'] == ValidatorState.isValid
              ? AppLocalizations.of(context)!.confirmation_yes
              : AppLocalizations.of(context)!.confirmation_no;
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
      if (_selectedAvatarId != null &&
          _selectedAvatarId != _newSelectedAvatarId) {
        UploadAvatarBody predefinedAvatarBody = UploadAvatarBody(
            username: _infoService.username, id: _selectedAvatarId);
        String? response = await _registerProvider.putAvatarData(
            predefinedAvatarBody, AvatarType.predefined);

        print("HERE AVATAR CHANGED");
        print("response : $response");
        if (response == null) {
          _avatarProvider.setAccountAvatarUrl();
          _newSelectedAvatarId = _selectedAvatarId!;
          showFeedback(avatarFeedback);
        } else {
          throw Exception(response);
        }
      } else if (_selectedAvatarBase64 != null &&
          _selectedAvatarBase64 != _newSelectedAvatarBase64) {
        print("HERE AVATAR CHANGED WRONG");
        UploadAvatarBody avatarBody = UploadAvatarBody(
            username: _infoService.username,
            base64Avatar: _selectedAvatarBase64!);
        String? response = await _registerProvider.putAvatarData(
            avatarBody, AvatarType.camera);

        if (response == null) {
          _avatarProvider.setAccountAvatarUrl();
          _newSelectedAvatarBase64 = _selectedAvatarBase64!;
          showFeedback(avatarFeedback);
        } else {
          throw Exception(response);
        }
      }

      // Password changes
      if ((passwordConfirmation == "Yes" || passwordConfirmation == "Oui") &&
          passwordController.text.trim() != newPassword) {
        String? response = await accountService.updatePassword(
            _infoService.username, passwordController.text.trim());
        if (response == null) {
          newPassword = passwordController.text.trim();
          showFeedback(passwordFeedback);
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
          showFeedback(usernameFeedback);
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
          showFeedback(languageFeedback);
        } else {
          throw Exception(response);
        }
      }
      // Theme changes
      if (currentSettings?.theme != initialSettings?.theme &&
          currentSettings?.theme != null) {
        String? response = await accountService.updateTheme(
            _infoService.username, currentSettings!.theme);
        if (response == null) {
          _infoService.setTheme(currentSettings!.theme);
          showFeedback(themeFeedback);
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
          showFeedback(errorSoundFeedback);
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
          showFeedback(differenceFoundSoundFeedback);
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
    final infoService = context.watch<InfoService>();

    avatarFeedback = AppLocalizations.of(context)!.edit_profile_avatarFeedback;
    passwordFeedback =
        AppLocalizations.of(context)!.edit_profile_passwordFeedback;
    usernameFeedback =
        AppLocalizations.of(context)!.edit_profile_usernameFeedback;
    languageFeedback =
        AppLocalizations.of(context)!.edit_profile_languageFeedback;
    themeFeedback = AppLocalizations.of(context)!.edit_profile_themeFeedback;
    errorSoundFeedback =
        AppLocalizations.of(context)!.edit_profile_errorSoundFeedback;
    differenceFoundSoundFeedback =
        AppLocalizations.of(context)!.edit_profile_differenceFoundSoundFeedback;

    return BackgroundContainer(
      backgroundImagePath: infoService.isThemeLight
          ? MENU_BACKGROUND_PATH
          : MENU_BACKGROUND_PATH_DARK,
      child: Scaffold(
          backgroundColor: Colors.transparent,
          appBar: CustomAppBar(
              title: AppLocalizations.of(context)!.edit_profile_title),
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
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 15.0, vertical: 5.0),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(color: Colors.black),
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        child: DropdownButtonFormField<Sound>(
                          value: currentSettings?.onErrorSound,
                          onChanged: (newValue) {
                            if (newValue != null) {
                              soundService.playOnErrorSound(newValue);
                              currentSettings = currentSettings!
                                  .copyWith(onErrorSound: newValue);
                            }
                          },
                          items: ERROR_SOUND_LIST.map((sound) {
                            return DropdownMenuItem(
                                value: sound, child: Text(sound.name));
                          }).toList(),
                          decoration: InputDecoration(
                              labelText: AppLocalizations.of(context)!
                                  .edit_profile_errorSound),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 15.0, vertical: 5.0),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(color: Colors.black),
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        child: DropdownButtonFormField<Sound>(
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
                              labelText: AppLocalizations.of(context)!
                                  .edit_profile_differenceFoundSound),
                        ),
                      ),
                      // Choisir le thème de l'application
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 15.0, vertical: 5.0),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(color: Colors.black),
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        child: DropdownButtonFormField<String>(
                          value: currentSettings!.theme,
                          items: themes
                              .map<DropdownMenuItem<String>>((String value) {
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
                      ),
                      // Choisir la langue de l'application
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 15.0, vertical: 5.0),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(color: Colors.black),
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        child: DropdownButtonFormField<String>(
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
                          decoration: InputDecoration(
                            labelText: AppLocalizations.of(context)!
                                .edit_profile_language,
                          ),
                        ),
                      ),
                      Row(
                        children: [
                          OutlinedButton(
                            onPressed: () {
                              Navigator.pushNamed(context, PROFILE_ROUTE);
                            },
                            style: OutlinedButton.styleFrom(
                                backgroundColor: Colors.black,
                                padding: EdgeInsets.symmetric(horizontal: 50),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20))),
                            child: Text(
                                AppLocalizations.of(context)!
                                    .edit_profile_cancel,
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
                            child: Text(
                                AppLocalizations.of(context)!.edit_profile_save,
                                style: TextStyle(
                                  fontSize: 15,
                                  letterSpacing: 2,
                                  color: kLight,
                                )),
                          ),
                        ],
                      ),
                      SizedBox(width: 125),
                    ],
                  )))),
    );
  }

  Widget buildUsernameField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomTextInputField(
          label: AppLocalizations.of(context)!.edit_profile_username,
          controller: usernameController,
          hint: AppLocalizations.of(context)!.edit_profile_usernameHint,
          helperText:
              '${AppLocalizations.of(context)!.edit_profile_usernameHelper}: $usernameFormat',
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
          label: AppLocalizations.of(context)!.edit_profile_password,
          controller: passwordController,
          hint: AppLocalizations.of(context)!.edit_profile_passwordHint,
          helperText:
              '${AppLocalizations.of(context)!.edit_profile_passwordStrength}: $passwordStrength',
          errorText: _validator.states['password'] == ValidatorState.isEmpty
              ? AppLocalizations.of(context)!.edit_profile_passwordCondition
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
          label:
              AppLocalizations.of(context)!.edit_profile_passwordConfirmation,
          controller: confirmationController,
          hint: AppLocalizations.of(context)!
              .edit_profile_passwordConfirmationHint,
          helperText:
              '${AppLocalizations.of(context)!.edit_profile_passwordConfirmationHelper}: $passwordConfirmation',
          maxLength: 20,
          errorText: _validator.states['passwordConfirmation'] ==
                  ValidatorState.isEmpty
              ? AppLocalizations.of(context)!
                  .edit_profile_passwordConfirmationCondition
              : _validator.states['passwordConfirmation'] ==
                      ValidatorState.isInvalid
                  ? AppLocalizations.of(context)!
                      .edit_profile_passwordConfirmationMatch
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
