import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';

abstract class FavoritesRepository {
  Future<Either<Failure, List<String>>> getFavoriteMealIds();
  Future<Either<Failure, void>> addFavoriteMealId(String mealId);
  Future<Either<Failure, void>> removeFavoriteMealId(String mealId);
  Future<Either<Failure, void>> clearFavorites();
}