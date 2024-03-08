import 'package:mobile/constants/temp_images.dart';
import 'package:mobile/models/models.dart';

class GameManagerService {
// TODO : Implement GameManagerService

  void testConvert() {
    // print('Test convert called');
    // dynamic temp = jsonDecode(messageTemps);
    // final Differences difference = Differences.fromJson(differencesTemp);
    List<Coordinate> coordinates = [];
    dynamic temp = oneDifferenceTemp['differencesData']['currentDifference'];
    for (var i = 0; i < temp.length; i++) {
      coordinates.add(Coordinate.fromJson(temp[i]));
    }

    print(coordinates);
    print(oneDifferenceTemp['differencesData']['currentDifference']);

    // boo
  }
}
