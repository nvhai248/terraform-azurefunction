import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile/features/auth/domain/entities/user.dart';

import '../../../../core/enums/user.dart';
import '../bloc/profile_bloc.dart';
import '../bloc/profile_event.dart';
import '../bloc/profile_state.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final _dobController = TextEditingController();
  final _weightController = TextEditingController();
  final _heightController = TextEditingController();
  final _allergyController = TextEditingController();

  Gender? _gender;
  List<String> _allergies = [];

  @override
  void initState() {
    super.initState();
    context.read<ProfileBloc>().add(LoadProfileEvent());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Profile')),
      body: BlocConsumer<ProfileBloc, ProfileState>(
        listener: (context, state) {
          if (state.error != null) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.error!)));
          }
        },
        builder: (context, state) {
          if (state.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final profile = state.profile;
          if (profile == null) {
            return const Center(child: Text('No profile found'));
          }

          // Initialize form fields only once
          if (_dobController.text.isEmpty && profile.dateOfBirth != null) {
            _dobController.text =
                profile.dateOfBirth!.toIso8601String().split('T').first;
          }
          if (_weightController.text.isEmpty && profile.weight != null) {
            _weightController.text = profile.weight.toString();
          }
          if (_heightController.text.isEmpty && profile.height != null) {
            _heightController.text = profile.height.toString();
          }
          if (_gender == null && profile.gender != null) {
            _gender = profile.gender;
          }
          if (_allergies.isEmpty && profile.allergies.isNotEmpty) {
            _allergies = List.from(profile.allergies);
          }

          return Padding(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: ListView(
                children: [
                  TextFormField(
                    controller: _dobController,
                    decoration: const InputDecoration(
                      labelText: 'Date of Birth',
                    ),
                    readOnly: true,
                    onTap: _selectDate,
                  ),
                  DropdownButtonFormField<Gender>(
                    value: _gender,
                    items: const [
                      DropdownMenuItem(value: Gender.male, child: Text('Male')),
                      DropdownMenuItem(
                        value: Gender.female,
                        child: Text('Female'),
                      ),
                      DropdownMenuItem(
                        value: Gender.other,
                        child: Text('Other'),
                      ),
                    ],
                    onChanged: (v) => setState(() => _gender = v),
                    decoration: const InputDecoration(labelText: 'Gender'),
                  ),
                  TextFormField(
                    controller: _weightController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Weight (kg)'),
                  ),
                  TextFormField(
                    controller: _heightController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Height (cm)'),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 6,
                    children:
                        _allergies
                            .map(
                              (a) => Chip(
                                label: Text(a),
                                onDeleted:
                                    () => setState(() => _allergies.remove(a)),
                              ),
                            )
                            .toList(),
                  ),
                  TextFormField(
                    controller: _allergyController,
                    decoration: InputDecoration(
                      labelText: 'Add Allergy',
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.add),
                        onPressed: () {
                          if (_allergyController.text.isNotEmpty) {
                            setState(() {
                              _allergies.add(_allergyController.text.trim());
                              _allergyController.clear();
                            });
                          }
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.save),
                    label: const Text('Save Changes'),
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        final updated = User(
                          id: profile.id,
                          dateOfBirth: DateTime.tryParse(_dobController.text),
                          gender: _gender,
                          weight: double.tryParse(_weightController.text),
                          height: double.tryParse(_heightController.text),
                          allergies: _allergies,
                          avatarUrl: profile.avatarUrl,
                          createdAt: profile.createdAt,
                          updatedAt: DateTime.now(),
                        );

                        context.read<ProfileBloc>().add(
                          UpdateProfileEvent(updated),
                        );
                      }
                    },
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Future<void> _selectDate() async {
    final initialDate =
        DateTime.tryParse(_dobController.text) ??
        DateTime(DateTime.now().year - 25);
    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(
        () => _dobController.text = picked.toIso8601String().split('T').first,
      );
    }
  }

  @override
  void dispose() {
    _dobController.dispose();
    _weightController.dispose();
    _heightController.dispose();
    _allergyController.dispose();
    super.dispose();
  }
}
