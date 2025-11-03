import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import '../../../auth_shared/domain/entities/user.dart';
import '../../../auth_shared/domain/repositories/auth_repository.dart';
import '../../../favorites/data/datasources/favorites_local_datasource.dart';

enum ProfileState { initial, loading, loaded, error, saving }

class ProfileProvider extends ChangeNotifier {
  final AuthRepository authRepository;
  final FavoritesLocalDataSource favoritesLocalDataSource;

  ProfileProvider({
    required this.authRepository,
    required this.favoritesLocalDataSource,
  });

  ProfileState _state = ProfileState.initial;
  String? _errorMessage;
  User? _user;
  File? _profileImage;

  ProfileState get state => _state;
  String? get errorMessage => _errorMessage;
  User? get user => _user;
  File? get profileImage => _profileImage;

  Future<void> loadUser() async {
    _state = ProfileState.loading;
    notifyListeners();

    final result = await authRepository.getCurrentUser();
    result.fold(
          (failure) {
        _state = ProfileState.error;
        _errorMessage = failure.message;
      },
          (user) {
        _user = user;
        _state = ProfileState.loaded;
      },
    );
    notifyListeners();
  }

  Future<void> pickImage() async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(source: ImageSource.gallery);

      if (pickedFile != null) {
        _profileImage = File(pickedFile.path);
        notifyListeners();
      }
    } catch (e) {
      _errorMessage = "Error al seleccionar la imagen";
      notifyListeners();
    }
  }

  Future<bool> saveChanges(String name, String email) async {
    if (_user == null) return false;

    _state = ProfileState.saving;
    notifyListeners();

    final updatedUser = User(
      id: _user!.id,
      email: email,
      name: name,
    );

    final result = await authRepository.updateUser(updatedUser);
    bool success = false;
    result.fold(
          (failure) {
        _state = ProfileState.error;
        _errorMessage = failure.message;
        success = false;
      },
          (user) {
        _user = user;
        _state = ProfileState.loaded;
        success = true;
      },
    );

    notifyListeners();
    return success;
  }

  Future<bool> deleteAccount() async {
    _state = ProfileState.saving;
    notifyListeners();

    final result = await authRepository.deleteUser();
    bool success = false;
    result.fold(
          (failure) {
        _state = ProfileState.error;
        _errorMessage = failure.message;
        success = false;
      },
          (_) async {
        await favoritesLocalDataSource.clearFavorites();
        _user = null;
        _profileImage = null;
        _state = ProfileState.initial;
        success = true;
      },
    );

    notifyListeners();
    return success;
  }
}