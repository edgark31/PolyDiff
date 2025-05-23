import 'package:mobile/constants/temp_images.dart';
import 'package:mobile/models/models.dart';

class CoordinateConversionService {
// TODO : Implement CoordinateConversionService

  List<Coordinate> testConvert() {
    List<Coordinate> coordinates = [];
    dynamic temp = oneDifferenceTemp['differencesData']['currentDifference'];
    for (var i = 0; i < temp.length; i++) {
      coordinates.add(Coordinate.fromJson(temp[i]));
    }
    return coordinates;
  }

  List<Coordinate> testConvert2() {
    List<Coordinate> coordinates = [];
    dynamic temp = oneDifferenceTemp2['differencesData']['currentDifference'];
    for (var i = 0; i < temp.length; i++) {
      coordinates.add(Coordinate.fromJson(temp[i]));
    }
    return coordinates;
  }

  List<List<Coordinate>> testCheat() {
    List<List<Coordinate>> cheatCoordinates = [];
    cheatCoordinates.add(testConvert());
    cheatCoordinates.add(testConvert2());
    return cheatCoordinates;
  }
}
