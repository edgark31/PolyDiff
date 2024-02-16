import 'dart:math';

import '../common/random_name_lists.dart';

class NameGenerationService {
  String generatedName = '';
  void generateName(int languageIndex, bool hasAnimalName, bool hasNumber) {
    Random random = Random();
    List<String> nameComponents = [];
    nameComponents.add(
        colors[languageIndex]![random.nextInt(colors[languageIndex]!.length)]);
    nameComponents.add(
        dishes[languageIndex]![random.nextInt(dishes[languageIndex]!.length)]);

    if (hasAnimalName) {
      nameComponents.add(animals[languageIndex]![
          random.nextInt(animals[languageIndex]!.length)]);
    }
    if (hasNumber) {
      nameComponents.add(numbers[random.nextInt(numbers.length)].toString());
    }

    for (int i = 0; i < nameComponents.length; i++) {
      nameComponents[i] =
          nameComponents[i][0].toUpperCase() + nameComponents[i].substring(1);
    }
    nameComponents.shuffle();
    generatedName = nameComponents.join('');
  }
}
