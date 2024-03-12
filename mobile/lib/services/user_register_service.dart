import 'package:mobile/models/models.dart';
import 'package:mobile/services/avatar_service.dart';
import 'package:mobile/services/form_service.dart';

// TODO : move logic of signupform here
class UserRegistrationService {
  final FormService formService = FormService();
  final AvatarService avatarService = AvatarService();

  Future<Map<String, String?>> registerUser({
    required Credentials credentials,
    String? selectedAvatarId,
    String? selectedAvatarBase64,
  }) async {
    String? serverErrorMessage;
    String? avatarErrorMessage;

    if (selectedAvatarId != null) {
      serverErrorMessage =
          await formService.register(credentials, selectedAvatarId);
    } else if (selectedAvatarBase64 != null) {
      const tempsId = "1";
      serverErrorMessage = await formService.register(credentials, tempsId);
      if (serverErrorMessage == null) {
        avatarErrorMessage = await avatarService.uploadCameraImage(
          credentials.username,
          selectedAvatarBase64,
        );
      }
    } else {
      avatarErrorMessage = "avatar non sélectionné";
    }

    return {
      'serverErrorMessage': serverErrorMessage,
      'avatarErrorMessage': avatarErrorMessage,
    };
  }

  bool isFormValid(
      String username, String email, String password, String confirmation) {
    // Implement form validation logic here
    return true; // Example implementation
  }

  // Add other validation methods here...
}
