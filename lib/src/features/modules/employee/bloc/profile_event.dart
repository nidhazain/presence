part of 'profile_bloc.dart';

@immutable
abstract class ProfileEvent {}

class FetchProfileData extends ProfileEvent {} // To fetch data from the API
class UpdateProfileData extends ProfileEvent { // To update the profile image or other details
  final String imagePath;
  UpdateProfileData({required this.imagePath});
}
