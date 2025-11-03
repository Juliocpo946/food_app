import 'package:flutter/foundation.dart';
import 'package:device_preview/device_preview.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'app/my_app.dart';
import 'core/application/app_state.dart';
import 'core/network/http_client.dart';
import 'core/router/app_router.dart';

import 'features/auth_shared/data/datasources/auth_local_datasource.dart';
import 'features/auth_shared/data/repositories/auth_repository_impl.dart';
import 'features/auth_shared/domain/repositories/auth_repository.dart';
import 'features/login/domain/usecases/login_usecase.dart';
import 'features/register/domain/usecases/register_usecase.dart';

import 'features/login/presentation/providers/login_provider.dart';
import 'features/register/presentation/providers/register_provider.dart';

import 'features/meals_shared/data/datasources/meal_remote_datasource.dart';
import 'features/meals_shared/data/repositories/meal_repository_impl.dart';
import 'features/meals_shared/domain/repositories/meal_repository.dart';
import 'features/home/domain/usecases/search_meals_usecase.dart';
import 'features/home/domain/usecases/get_categories_usecase.dart';
import 'features/home/domain/usecases/get_meals_by_category_usecase.dart';
import 'features/home/domain/usecases/get_areas_usecase.dart';
import 'features/home/domain/usecases/get_meals_by_area_usecase.dart';
import 'features/meal_detail/domain/usecases/get_meal_by_id_usecase.dart';

import 'features/home/presentation/providers/home_provider.dart';
import 'features/meal_detail/presentation/providers/meal_detail_provider.dart';
import 'features/profile/presentation/providers/profile_provider.dart';

import 'features/favorites/data/datasources/favorites_local_datasource.dart';
import 'features/favorites/data/repositories/favorites_repository_impl.dart';
import 'features/favorites/domain/repositories/favorites_repository.dart';
import 'features/favorites/presentation/providers/favorites_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final sharedPreferences = await SharedPreferences.getInstance();
  final httpClient = HttpClient();

  final authLocalDataSource = AuthLocalDataSourceImpl(
    sharedPreferences: sharedPreferences,
  );
  final AuthRepository authRepository = AuthRepositoryImpl(
    localDataSource: authLocalDataSource,
  );
  final loginUseCase = LoginUseCase(repository: authRepository);
  final registerUseCase = RegisterUseCase(repository: authRepository);

  final mealRemoteDataSource = MealRemoteDataSourceImpl(
    httpClient: httpClient,
  );
  final MealRepository mealRepository = MealRepositoryImpl(
    remoteDataSource: mealRemoteDataSource,
  );
  final searchMealsUseCase = SearchMealsUseCase(repository: mealRepository);
  final getCategoriesUseCase = GetCategoriesUseCase(repository: mealRepository);
  final getMealsByCategoryUseCase =
  GetMealsByCategoryUseCase(repository: mealRepository);
  final getMealByIdUseCase = GetMealByIdUseCase(repository: mealRepository);
  final getAreasUseCase = GetAreasUseCase(repository: mealRepository);
  final getMealsByAreaUseCase =
  GetMealsByAreaUseCase(repository: mealRepository);

  final favoritesLocalDataSource = FavoritesLocalDataSourceImpl(
    sharedPreferences: sharedPreferences,
  );
  final FavoritesRepository favoritesRepository = FavoritesRepositoryImpl(
    localDataSource: favoritesLocalDataSource,
  );

  final appState = AppState(
    authRepository: authRepository,
    favoritesLocalDataSource: favoritesLocalDataSource,
  );
  final appRouter = AppRouter(appState: appState);

  runApp(
    DevicePreview(
      enabled: kDebugMode,
      builder: (context) => MultiProvider(
        providers: [
          ChangeNotifierProvider.value(value: appState),
          ChangeNotifierProvider(
            create: (_) => LoginProvider(loginUseCase: loginUseCase),
          ),
          ChangeNotifierProvider(
            create: (_) => RegisterProvider(registerUseCase: registerUseCase),
          ),
          ChangeNotifierProvider(
            create: (_) => HomeProvider(
              searchMealsUseCase: searchMealsUseCase,
              getCategoriesUseCase: getCategoriesUseCase,
              getMealsByCategoryUseCase: getMealsByCategoryUseCase,
              getAreasUseCase: getAreasUseCase,
              getMealsByAreaUseCase: getMealsByAreaUseCase,
            ),
          ),
          ChangeNotifierProvider(
            create: (_) =>
                MealDetailProvider(getMealByIdUseCase: getMealByIdUseCase),
          ),
          ChangeNotifierProvider(
            create: (_) => ProfileProvider(
              authRepository: authRepository,
              favoritesLocalDataSource: favoritesLocalDataSource,
            ),
          ),
          ChangeNotifierProvider(
            create: (_) => FavoritesProvider(
              favoritesRepository: favoritesRepository,
              mealRepository: mealRepository,
            ),
          ),
        ],
        child: MyApp(router: appRouter),
      ),
    ),
  );
}