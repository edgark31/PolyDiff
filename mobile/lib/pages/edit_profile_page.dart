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

  @override
  void initState() {
    super.initState();
    print('init State');
    _validator = CredentialsValidator(onStateChanged: _forceRebuild);
    usernameController.addListener(_onUsernameChanged);

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

  void showFeedback(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Future<void> saveChanges() async {
    try {
      // Avatar changes
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
      if (currentSettings?.theme != initialSettings?.theme &&
          currentSettings?.theme != null) {
        String? response = await accountService.updateTheme(
            _infoService.username, currentSettings!.theme);
        if (response == null) {
          _infoService.setTheme(currentSettings!.theme);
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
    print('Current OnErrorSound: ${currentSettings?.onErrorSound.toJson()}');
    print(
        'Error Sound List: ${ERROR_SOUND_LIST.map((e) => e.toJson()).toList()}');
    print(
        'Current OnCorrectSound: ${currentSettings?.onCorrectSound.toJson()}');
    print(
        'Correct Sound List: ${CORRECT_SOUND_LIST.map((e) => e.toJson()).toList()}');
    // This checks if all sounds have a unique name property
    print(ERROR_SOUND_LIST.map((s) => s.name).toSet().length ==
        ERROR_SOUND_LIST.length);
    print(CORRECT_SOUND_LIST.map((s) => s.name).toSet().length ==
        CORRECT_SOUND_LIST.length);
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
                          final themeProvider = Provider.of<ThemeProvider>(
                              context,
                              listen: false);
                          themeProvider.toggleTheme(newValue == 'dark');
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
