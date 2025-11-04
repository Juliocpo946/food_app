import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'app/my_app.dart';
import 'core/application/app_state.dart';
import 'core/database/database_helper.dart';
import 'core/network/http_client.dart';
import 'core/router/app_router.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'core/network/network_info.dart';

import 'features/auth_shared/data/datasources/auth_local_datasource.dart';
import 'features/auth_shared/data/repositories/auth_repository_impl.dart';
import 'features/auth_shared/domain/repositories/auth_repository.dart';
import 'features/home/data/datasources/home_remote_datasource_impl.dart';
import 'features/login/domain/usecases/login_usecase.dart';
import 'features/register/domain/usecases/register_usecase.dart';
import 'features/login/presentation/providers/login_provider.dart';
import 'features/register/presentation/providers/register_provider.dart';

import 'features/meals_shared/data/datasources/meal_remote_datasource.dart';
import 'features/meals_shared/data/repositories/meal_repository_impl.dart';
import 'features/meals_shared/domain/repositories/meal_repository.dart';

import 'features/home/data/repositories/home_repository_impl.dart';
import 'features/home/domain/repositories/home_repository.dart';
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

import 'features/cart/data/datasources/cart_local_datasource.dart';
import 'features/cart/data/repositories/cart_repository_impl.dart';
import 'features/cart/domain/repositories/cart_repository.dart';
import 'features/cart/presentation/providers/cart_provider.dart';

import 'features/orders/data/datasources/orders_local_datasource.dart';
import 'features/orders/data/repositories/orders_repository_impl.dart';
import 'features/orders/domain/repositories/orders_repository.dart';
import 'features/orders/presentation/providers/orders_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");

  final dbHelper = DatabaseHelper.instance;
  final httpClient = HttpClient();

  final connectivity = Connectivity();
  final NetworkInfo networkInfo = NetworkInfoImpl(connectivity);

  final authLocalDataSource = AuthLocalDataSourceImpl(dbHelper: dbHelper);
  final AuthRepository authRepository = AuthRepositoryImpl(localDataSource: authLocalDataSource);
  final loginUseCase = LoginUseCase(repository: authRepository);
  final registerUseCase = RegisterUseCase(repository: authRepository);

  final mealRemoteDataSource = MealRemoteDataSourceImpl(httpClient: httpClient);
  final MealRepository mealRepository = MealRepositoryImpl(
    remoteDataSource: mealRemoteDataSource,
    networkInfo: networkInfo,
  );

  final homeRemoteDataSource = HomeRemoteDataSourceImpl(httpClient: httpClient);
  final HomeRepository homeRepository = HomeRepositoryImpl(
    remoteDataSource: homeRemoteDataSource,
    networkInfo: networkInfo,
  );

  final searchMealsUseCase = SearchMealsUseCase(repository: homeRepository);
  final getCategoriesUseCase = GetCategoriesUseCase(repository: homeRepository);
  final getMealsByCategoryUseCase = GetMealsByCategoryUseCase(repository: homeRepository);
  final getAreasUseCase = GetAreasUseCase(repository: homeRepository);
  final getMealsByAreaUseCase = GetMealsByAreaUseCase(repository: homeRepository);
  final getMealByIdUseCase = GetMealByIdUseCase(repository: mealRepository);

  final favoritesLocalDataSource = FavoritesLocalDataSourceImpl(dbHelper: dbHelper);
  final FavoritesRepository favoritesRepository = FavoritesRepositoryImpl(
    localDataSource: favoritesLocalDataSource,
  );

  final cartLocalDataSource = CartLocalDataSourceImpl(dbHelper: dbHelper);
  final CartRepository cartRepository = CartRepositoryImpl(localDataSource: cartLocalDataSource);

  final ordersLocalDataSource = OrdersLocalDataSourceImpl(dbHelper: dbHelper);
  final OrdersRepository ordersRepository = OrdersRepositoryImpl(localDataSource: ordersLocalDataSource);

  final appState = AppState(
    authRepository: authRepository,
    favoritesLocalDataSource: favoritesLocalDataSource,
  );
  final appRouter = AppRouter(appState: appState);

  runApp(
    //DevicePreview(
    //enabled: kDebugMode,
    //builder: (context) =>
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: appState),
        ChangeNotifierProvider(create: (_) => LoginProvider(loginUseCase: loginUseCase)),
        ChangeNotifierProvider(create: (_) => RegisterProvider(registerUseCase: registerUseCase)),
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
          create: (_) => MealDetailProvider(getMealByIdUseCase: getMealByIdUseCase),
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
        ChangeNotifierProvider(
          create: (_) => CartProvider(cartRepository: cartRepository),
        ),
        ChangeNotifierProvider(
          create: (_) => OrdersProvider(ordersRepository: ordersRepository),
        ),
      ],
      child: MyApp(router: appRouter),
    ),
  //);
  );
}