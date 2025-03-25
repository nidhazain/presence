part of 'profile_bloc.dart';

@immutable
abstract class ProfileState {}

class ProfileInitial extends ProfileState {} // Initial state
class ProfileLoading extends ProfileState {} // When data is loading
class ProfileLoaded extends ProfileState {
  final String fullName;
  final String email;
  final String position;
  final String department;
  final String community;
  final String employeeId;
  final String hiringDate;
  final String profileImageUrl;

  ProfileLoaded({
    required this.fullName,
    required this.email,
    required this.position,
    required this.department,
    required this.community,
    required this.employeeId,
    required this.hiringDate,
    required this.profileImageUrl,
  });
}

class ProfileError extends ProfileState {
  final String error;

  ProfileError({required this.error});
}
