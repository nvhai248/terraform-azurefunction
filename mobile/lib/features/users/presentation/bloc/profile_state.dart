import 'package:equatable/equatable.dart';
import 'package:mobile/features/auth/domain/entities/user.dart';

class ProfileState extends Equatable {
  final bool isLoading;
  final User? profile;
  final String? error;

  const ProfileState({this.isLoading = false, this.profile, this.error});

  ProfileState copyWith({
    bool? isLoading,
    User? profile,
    String? error,
  }) {
    return ProfileState(
      isLoading: isLoading ?? this.isLoading,
      profile: profile ?? this.profile,
      error: error,
    );
  }

  @override
  List<Object?> get props => [isLoading, profile, error];
}
