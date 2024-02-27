import 'package:flutter/material.dart';
import 'package:mobile/services/services.dart';

class UsernameGenerator extends StatefulWidget {
  final Function(String) onUsernameGenerated;

  UsernameGenerator({super.key, required this.onUsernameGenerated});

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
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildLanguageSelector(),
          Container(
            constraints: BoxConstraints(maxWidth: 600),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Flexible(
                  child: CheckboxListTile(
                    controlAffinity: ListTileControlAffinity.leading,
                    title: const Text(
                      "Contenant le nom d'un animal",
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    value: hasAnimalName,
                    onChanged: (bool? value) {
                      setState(() {
                        hasAnimalName = value!;
                      });
                    },
                  ),
                ),
                Flexible(
                  child: CheckboxListTile(
                    controlAffinity: ListTileControlAffinity.leading,
                    title: const Text(
                      "Contenant des chiffres",
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    value: hasNumber,
                    onChanged: (bool? value) {
                      setState(() {
                        hasNumber = value!;
                      });
                    },
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.only(top: 20, bottom: 20),
            child: ElevatedButton(
              onPressed: () {
                int languageIndex = selectedLanguage;
                nameGenerationService.generateName(
                    languageIndex, hasAnimalName, hasNumber);
                setState(() {
                  userNameController.text = nameGenerationService.generatedName;
                });
                widget.onUsernameGenerated(nameGenerationService.generatedName);
              },
              child: Text('Générer un nom'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLanguageSelector() {
    return Container(
      constraints: BoxConstraints(maxWidth: 400),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Flexible(
            child: ListTile(
              title: Text('En français'),
              leading: Radio<int>(
                value: 1,
                groupValue: selectedLanguage,
                onChanged: (value) {
                  setState(() => selectedLanguage = value!);
                },
              ),
            ),
          ),
          Flexible(
            child: ListTile(
              title: Text('En anglais'),
              leading: Radio<int>(
                value: 2,
                groupValue: selectedLanguage,
                onChanged: (value) {
                  setState(() => selectedLanguage = value!);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
