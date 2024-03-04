import 'package:flutter/material.dart';
import 'package:mobile/constants/app_constants.dart';
import 'package:mobile/services/services.dart';

class UsernameGenerator extends StatefulWidget {
  final Function(String) onUsernameGenerated;

  UsernameGenerator({
    super.key,
    required this.onUsernameGenerated,
  });

  @override
  State<UsernameGenerator> createState() => _UsernameGeneratorState();
}

class _UsernameGeneratorState extends State<UsernameGenerator> {
  bool hasAnimalName = false;
  bool hasNumber = false;
  int selectedLanguage = 1; // Default 1 for 'En français'
  final userNameController = TextEditingController();
  final NameGenerationService nameGenerationService = NameGenerationService();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        child: Center(
          child: Container(
            padding: EdgeInsets.only(top: 8.0, bottom: 8.0),
            width: MediaQuery.of(context).size.width * 0.3,
            decoration: BoxDecoration(
              color: kLightOrange.withOpacity(0.7),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Options de génération nom d'utilisateur",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 10),
                _buildLanguageSelector(),
                _buildOptions(),
                _generateButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLanguageSelector() {
    return Center(
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _languageOption('En français', 1),
              _languageOption('En anglais', 2),
            ],
          ),
        ],
      ),
    );
  }

  Widget _languageOption(String title, int value) {
    return Flexible(
      child: ListTile(
        title: Text(title),
        leading: Radio<int>(
          value: value,
          groupValue: selectedLanguage,
          onChanged: (int? newValue) {
            setState(() => selectedLanguage = newValue!);
          },
        ),
      ),
    );
  }

  Widget _buildOptions() {
    return Column(
      children: [
        CheckboxListTile(
          controlAffinity: ListTileControlAffinity.leading,
          title: const Text("Contenant le nom d'un animal"),
          value: hasAnimalName,
          onChanged: (bool? value) {
            setState(() {
              hasAnimalName = value!;
            });
          },
        ),
        CheckboxListTile(
          controlAffinity: ListTileControlAffinity.leading,
          title: const Text("Contenant des chiffres"),
          value: hasNumber,
          onChanged: (bool? value) {
            setState(() {
              hasNumber = value!;
            });
          },
        ),
      ],
    );
  }

  Widget _generateButton() {
    return Padding(
      padding: EdgeInsets.only(top: 20),
      child: ElevatedButton(
        onPressed: () {
          nameGenerationService.generateName(
              selectedLanguage, hasAnimalName, hasNumber);
          setState(() {
            userNameController.text = nameGenerationService.generatedName;
          });
          widget.onUsernameGenerated(nameGenerationService.generatedName);
        },
        child: Icon(Icons.refresh),
      ),
    );
  }
}
