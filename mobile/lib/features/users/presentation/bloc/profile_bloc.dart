import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile/features/users/data/repositories/user.dart';
import 'profile_event.dart';
import 'profile_state.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final UserRepository repository;

  ProfileBloc(this.repository) : super(const ProfileState()) {
    on<LoadProfileEvent>(_onLoadProfile);
    on<UpdateProfileEvent>(_onUpdateProfile);
  }

  Future<void> _onLoadProfile(
      LoadProfileEvent event,
      Emitter<ProfileState> emit,
      ) async {
    emit(state.copyWith(isLoading: true));
    try {
      final profile = await repository.getProfile();
      emit(state.copyWith(isLoading: false, profile: profile));
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }

  Future<void> _onUpdateProfile(
      UpdateProfileEvent event,
      Emitter<ProfileState> emit,
      ) async {
    emit(state.copyWith(isLoading: true));
    try {
      final updated = await repository.updateProfile(event.updatedProfile);
      emit(state.copyWith(isLoading: false, profile: updated));
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }
}
