import 'package:flutter/material.dart';
import 'package:mobile/constants/app_constants.dart';
import 'package:mobile/constants/app_routes.dart';
import 'package:mobile/constants/app_text_constants.dart';
import 'package:mobile/providers/avatar_provider.dart';
import 'package:mobile/providers/theme_provider.dart';
import 'package:mobile/services/account_service.dart';
import 'package:mobile/services/info_service.dart';
import 'package:mobile/utils/credentials_validation.dart';
import 'package:mobile/widgets/customs/custom_app_bar.dart';
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
  // Define the lists for dropdown items
  final List<String> errorSounds = [
    'ErrorSound1.mp3',
    'ErrorSound2.mp3',
    'ErrorSound3.mp3'
  ];
  final List<String> differenceSounds = [
    'WinSound1.mp3',
    'WinSound2.mp3',
    'WinSound3.mp3'
  ];
  final List<String> languages = ['Français', 'Anglais'];
  final List<String> themes = ['Dark', 'Light'];

  String currentErrorSound = '';
  String currentDifferenceSound = '';
  String currentLanguage = '';
  String currentTheme = '';

  final AccountService accountService = AccountService();
  late final CredentialsValidation _validator;
  String usernameFormat = NO;

  // TODO: Update with provider Sound, Username, Avatar and Theme
  Future<void> updateProfile() async {}

  void validateUsername() {
    _validator.isValidUsername(usernameController.text);
    updateUsernameValidationStates();
  }

  void updateUsernameValidationStates() {
    setState(() {
      usernameFormat =
          _validator.states['username'] == ValidationState.valid ? YES : NO;
    });
  }

  @override
  void initState() {
    super.initState();
    _validator = CredentialsValidation(
      onStateChanged: () {
        setState(() {
          // Force the widget to rebuild with updated validation status
        });
      },
    );
    usernameController.addListener(validateUsername);
    final infoService = Provider.of<InfoService>(context, listen: false);
    currentErrorSound = errorSounds.contains(infoService.soundOnError)
        ? infoService.soundOnError
        : errorSounds.first;
    currentDifferenceSound =
        differenceSounds.contains(infoService.soundOnDifference)
            ? infoService.soundOnDifference
            : differenceSounds.first;
    currentLanguage = languages.contains(infoService.language)
        ? infoService.language
        : languages.first;
    currentTheme = Provider.of<ThemeProvider>(context, listen: false).isDarkMode
        ? 'Dark'
        : 'Light';
  }

  @override
  void dispose() {
    usernameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final infoService = context.watch<InfoService>();

    // avatar
    AvatarProvider.instance.setAccountAvatarUrl(infoService.username);

    return Scaffold(
        appBar: CustomAppBar(title: "M O D I F I E R   S O N  P R O F I L"),
        body: Container(
            padding: EdgeInsets.only(left: 15, top: 20, right: 15),
            child: GestureDetector(
                onTap: () {
                  FocusScope.of(context).unfocus();
                },
                child: ListView(
                  children: [
                    Center(
                      child: Stack(
                        children: [
                          Container(
                            width: 130,
                            height: 130,
                            decoration: BoxDecoration(
                                border: Border.all(width: 4, color: kLight),
                                boxShadow: [
                                  BoxShadow(
                                    spreadRadius: 2,
                                    blurRadius: 10,
                                    color: kDark.withOpacity(0.1),
                                  ),
                                ],
                                shape: BoxShape.circle,
                                image: DecorationImage(
                                  fit: BoxFit.cover,
                                  image: NetworkImage(
                                      AvatarProvider.instance.currentAvatarUrl),
                                )),
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: Container(
                              height: 40,
                              width: 40,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  width: 4,
                                  color: kLight,
                                ),
                                color: kMidOrange,
                              ),
                              child: Icon(
                                Icons.edit,
                                color: kLight,
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                    SizedBox(height: 30),
                    buildTextField(
                        "Nom d'utilisateur", usernameController, false),
                    SizedBox(height: 30),
                    // Choisir un son lorsqu'un joueur ne click pas sur une différence
                    DropdownButtonFormField<String>(
                      value: currentErrorSound,
                      items: errorSounds
                          .map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                      onChanged: (newValue) {
                        setState(() {
                          currentErrorSound = newValue!;
                          infoService.setSoundOnError(currentErrorSound);
                        });
                      },
                      decoration: InputDecoration(labelText: "Son d'erreur"),
                    ),
                    // Choisir un son lorsqu'un joueur click sur une différence
                    DropdownButtonFormField<String>(
                      value: currentDifferenceSound,
                      items: differenceSounds
                          .map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        setState(() {
                          currentDifferenceSound = newValue!;
                          infoService
                              .setSoundOnDifference(currentDifferenceSound);
                        });
                      },
                      decoration:
                          InputDecoration(labelText: "Son Différence trouvée"),
                    ),
                    // Choisir le thème de l'application
                    DropdownButtonFormField<String>(
                      value: currentTheme,
                      items:
                          themes.map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        setState(() {
                          currentTheme = newValue!;
                          final themeProvider = Provider.of<ThemeProvider>(
                              context,
                              listen: false);
                          themeProvider.toggleTheme(newValue == 'Dark');
                        });
                      },
                      decoration: InputDecoration(labelText: 'Theme'),
                    ),
                    // Choisir la langue de l'application
                    DropdownButtonFormField<String>(
                      value: currentLanguage,
                      items: languages
                          .map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                      onChanged: (newValue) {
                        setState(() {
                          currentLanguage = newValue!;
                          infoService.setLanguage(currentLanguage);
                        });
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
                          onPressed: updateProfile,
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

  Widget buildTextField(String labelText, TextEditingController controller,
      bool isPasswordField) {
    return Padding(
      padding: EdgeInsets.only(bottom: 30),
      child: TextField(
        controller: controller,
        maxLength: 20,
        decoration: InputDecoration(
          contentPadding: EdgeInsets.only(bottom: 30),
          labelText: labelText,
          floatingLabelBehavior: FloatingLabelBehavior.always,
          hintText: controller.text,
          hintStyle: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.grey,
          ),
          errorText: _validator.states['username'] == ValidationState.invalid
              ? "Nom d'utilisateur requis"
              : null,
        ),
      ),
    );
  }
}
