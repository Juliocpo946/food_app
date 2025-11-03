import 'package:flutter/foundation.dart';
import '../../../meals_shared/domain/entities/meal.dart';
import '../../../meals_shared/domain/repositories/meal_repository.dart';
import '../../domain/repositories/favorites_repository.dart';

enum FavoritesState { initial, loading, loaded, error }

class FavoritesProvider extends ChangeNotifier {
  final FavoritesRepository favoritesRepository;
  final MealRepository mealRepository;

  FavoritesProvider({
    required this.favoritesRepository,
    required this.mealRepository,
  });

  FavoritesState _state = FavoritesState.initial;
  String? _errorMessage;
  List<Meal> _favorites = [];
  List<String> _favoriteIds = [];

  FavoritesState get state => _state;
  String? get errorMessage => _errorMessage;
  List<Meal> get favorites => _favorites;

  Future<void> loadFavorites() async {
    _state = FavoritesState.loading;
    notifyListeners();

    final idsResult = await favoritesRepository.getFavoriteMealIds();
    idsResult.fold(
          (failure) {
        _state = FavoritesState.error;
        _errorMessage = failure.message;
        notifyListeners();
      },
          (ids) async {
        _favoriteIds = ids;
        List<Meal> tempFavorites = [];
        for (String id in ids) {
          final mealResult = await mealRepository.getMealById(id);
          mealResult.fold(
                (_) {},
                (meal) {
              tempFavorites.add(meal);
            },
          );
        }
        _favorites = tempFavorites;
        _state = FavoritesState.loaded;
        notifyListeners();
      },
    );
  }

  bool isFavorite(String mealId) {
    return _favoriteIds.contains(mealId);
  }

  Future<void> toggleFavorite(Meal meal) async {
    if (isFavorite(meal.id)) {
      _favorites.removeWhere((m) => m.id == meal.id);
      _favoriteIds.remove(meal.id);
      await favoritesRepository.removeFavoriteMealId(meal.id);
    } else {
      _favorites.add(meal);
      _favoriteIds.add(meal.id);
      await favoritesRepository.addFavoriteMealId(meal.id);
    }
    notifyListeners();
  }
}