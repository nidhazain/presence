import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:presence/src/features/api/employee/profileapi.dart';

part 'profile_event.dart';
part 'profile_state.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  ProfileBloc() : super(ProfileInitial()) {
    on<FetchProfileData>(_onFetchProfileData);
    on<UpdateProfileData>(_onUpdateProfileData);
  }

  Future<void> _onFetchProfileData(FetchProfileData event, Emitter<ProfileState> emit) async {
    emit(ProfileLoading());
    try {
      var profileData = await ProfileService.fetchProfileData();
      if (profileData.isNotEmpty && profileData['error'] == null) {
        emit(ProfileLoaded(
          fullName: profileData['name'] ?? "",
          email: profileData['email'] ?? "",
          position: profileData['position'] ?? "",
          department: profileData['department'] ?? "",
          community: profileData['community_name'] ?? "",
          employeeId: profileData['employee_id'] ?? "",
          hiringDate: profileData['hire_date'] ?? "",
          profileImageUrl: profileData['image'] ?? "",
        ));
      } else {
        emit(ProfileError(error: profileData['error'] ?? 'No profile data found'));
      }
    } catch (e) {
      emit(ProfileError(error: 'Error fetching profile: $e'));
    }
  }

  Future<void> _onUpdateProfileData(UpdateProfileData event, Emitter<ProfileState> emit) async {
    emit(ProfileLoading());
    try {
      var response = await ProfileService.updateProfileData(imagePath: event.imagePath);
      if (response.isNotEmpty && response['error'] == null) {
        add(FetchProfileData()); // refresh after update
      } else {
        emit(ProfileError(error: response['error'] ?? 'Error updating profile data'));
      }
    } catch (e) {
      emit(ProfileError(error: 'Error updating profile: $e'));
    }
  }
}
