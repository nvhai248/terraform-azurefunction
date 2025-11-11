import 'package:equatable/equatable.dart';
import 'package:mobile/features/auth/domain/entities/user.dart';

abstract class ProfileEvent extends Equatable {
  const ProfileEvent();
  @override
  List<Object?> get props => [];
}

class LoadProfileEvent extends ProfileEvent {}

class UpdateProfileEvent extends ProfileEvent {
  final User updatedProfile;
  const UpdateProfileEvent(this.updatedProfile);
  @override
  List<Object?> get props => [updatedProfile];
}
