import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/error/exceptions.dart';

abstract class FavoritesLocalDataSource {
  Future<List<String>> getFavoriteMealIds();
  Future<void> addFavoriteMealId(String mealId);
  Future<void> removeFavoriteMealId(String mealId);
  Future<void> clearFavorites();
}

class FavoritesLocalDataSourceImpl implements FavoritesLocalDataSource {
  final SharedPreferences sharedPreferences;
  static const String favoriteMealsKey = 'FAVORITE_MEALS';

  FavoritesLocalDataSourceImpl({required this.sharedPreferences});

  @override
  Future<List<String>> getFavoriteMealIds() async {
    try {
      return sharedPreferences.getStringList(favoriteMealsKey) ?? [];
    } catch (e) {
      throw CacheException('Error al obtener favoritos');
    }
  }

  @override
  Future<void> addFavoriteMealId(String mealId) async {
    try {
      final ids = await getFavoriteMealIds();
      if (!ids.contains(mealId)) {
        ids.add(mealId);
        await sharedPreferences.setStringList(favoriteMealsKey, ids);
      }
    } catch (e) {
      throw CacheException('Error al añadir favorito');
    }
  }

  @override
  Future<void> removeFavoriteMealId(String mealId) async {
    try {
      final ids = await getFavoriteMealIds();
      if (ids.contains(mealId)) {
        ids.remove(mealId);
        await sharedPreferences.setStringList(favoriteMealsKey, ids);
      }
    } catch (e) {
      throw CacheException('Error al eliminar favorito');
    }
  }

  @override
  Future<void> clearFavorites() async {
    try {
      await sharedPreferences.remove(favoriteMealsKey);
    } catch (e) {
      throw CacheException('Error al limpiar favoritos');
    }
  }
}