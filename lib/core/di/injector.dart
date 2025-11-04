import 'package:connectivity_plus/connectivity_plus.dart';
import '../../features/auth_shared/data/datasources/auth_local_datasource.dart';
import '../../features/auth_shared/data/repositories/auth_repository_impl.dart';
import '../../features/auth_shared/domain/repositories/auth_repository.dart';
import '../../features/cart/data/datasources/cart_local_datasource.dart';
import '../../features/cart/data/repositories/cart_repository_impl.dart';
import '../../features/cart/domain/repositories/cart_repository.dart';
import '../../features/cart/presentation/providers/cart_provider.dart';
import '../../features/favorites/data/datasources/favorites_local_datasource.dart';
import '../../features/favorites/data/repositories/favorites_repository_impl.dart';
import '../../features/favorites/domain/repositories/favorites_repository.dart';
import '../../features/favorites/presentation/providers/favorites_provider.dart';
import '../../features/home/data/datasources/home_remote_datasource.dart';
import '../../features/home/data/datasources/home_remote_datasource_impl.dart';
import '../../features/home/data/repositories/home_repository_impl.dart';
import '../../features/home/domain/repositories/home_repository.dart';
import '../../features/home/domain/usecases/get_areas_usecase.dart';
import '../../features/home/domain/usecases/get_categories_usecase.dart';
import '../../features/home/domain/usecases/get_meals_by_area_usecase.dart';
import '../../features/home/domain/usecases/get_meals_by_category_usecase.dart';
import '../../features/home/domain/usecases/search_meals_usecase.dart';
import '../../features/home/presentation/providers/home_provider.dart';
import '../../features/login/domain/usecases/login_usecase.dart';
import '../../features/login/presentation/providers/login_provider.dart';
import '../../features/meal_detail/domain/usecases/get_meal_by_id_usecase.dart';
import '../../features/meal_detail/presentation/providers/meal_detail_provider.dart';
import '../../features/meals_shared/data/datasources/meal_remote_datasource.dart';
import '../../features/meals_shared/data/repositories/meal_repository_impl.dart';
import '../../features/meals_shared/domain/repositories/meal_repository.dart';
import '../../features/orders/data/datasources/orders_local_datasource.dart';
import '../../features/orders/data/repositories/orders_repository_impl.dart';
import '../../features/orders/domain/repositories/orders_repository.dart';
import '../../features/orders/presentation/providers/orders_provider.dart';
import '../../features/profile/presentation/providers/profile_provider.dart';
import '../../features/register/domain/usecases/register_usecase.dart';
import '../../features/register/presentation/providers/register_provider.dart';
import '../application/app_state.dart';
import '../database/database_helper.dart';
import '../network/http_client.dart';
import '../network/network_info.dart';
import '../router/app_router.dart';

class Injector {
  static late final DatabaseHelper dbHelper;
  static late final HttpClient httpClient;
  static late final Connectivity connectivity;
  static late final NetworkInfo networkInfo;
  static late final AppState appState;
  static late final AppRouter appRouter;

  static late final AuthRepository authRepository;
  static late final MealRepository mealRepository;
  static late final HomeRepository homeRepository;
  static late final FavoritesRepository favoritesRepository;
  static late final CartRepository cartRepository;
  static late final OrdersRepository ordersRepository;

  static late final AuthLocalDataSource authLocalDataSource;
  static late final MealRemoteDataSource mealRemoteDataSource;
  static late final HomeRemoteDataSource homeRemoteDataSource;
  static late final FavoritesLocalDataSource favoritesLocalDataSource;
  static late final CartLocalDataSource cartLocalDataSource;
  static late final OrdersLocalDataSource ordersLocalDataSource;

  static late final LoginUseCase loginUseCase;
  static late final RegisterUseCase registerUseCase;
  static late final SearchMealsUseCase searchMealsUseCase;
  static late final GetCategoriesUseCase getCategoriesUseCase;
  static late final GetMealsByCategoryUseCase getMealsByCategoryUseCase;
  static late final GetAreasUseCase getAreasUseCase;
  static late final GetMealsByAreaUseCase getMealsByAreaUseCase;
  static late final GetMealByIdUseCase getMealByIdUseCase;

  static Future<void> init() async {
    dbHelper = DatabaseHelper.instance;
    httpClient = HttpClient();
    connectivity = Connectivity();

    networkInfo = NetworkInfoImpl(connectivity);

    authLocalDataSource = AuthLocalDataSourceImpl(dbHelper: dbHelper);
    mealRemoteDataSource = MealRemoteDataSourceImpl(httpClient: httpClient);
    homeRemoteDataSource = HomeRemoteDataSourceImpl(httpClient: httpClient);
    favoritesLocalDataSource = FavoritesLocalDataSourceImpl(dbHelper: dbHelper);
    cartLocalDataSource = CartLocalDataSourceImpl(dbHelper: dbHelper);
    ordersLocalDataSource = OrdersLocalDataSourceImpl(dbHelper: dbHelper);

    authRepository = AuthRepositoryImpl(localDataSource: authLocalDataSource);
    mealRepository = MealRepositoryImpl(
      remoteDataSource: mealRemoteDataSource,
      networkInfo: networkInfo,
    );
    homeRepository = HomeRepositoryImpl(
      remoteDataSource: homeRemoteDataSource,
      networkInfo: networkInfo,
    );
    favoritesRepository = FavoritesRepositoryImpl(
      localDataSource: favoritesLocalDataSource,
    );
    cartRepository = CartRepositoryImpl(localDataSource: cartLocalDataSource);
    ordersRepository =
        OrdersRepositoryImpl(localDataSource: ordersLocalDataSource);

    loginUseCase = LoginUseCase(repository: authRepository);
    registerUseCase = RegisterUseCase(repository: authRepository);
    searchMealsUseCase = SearchMealsUseCase(repository: homeRepository);
    getCategoriesUseCase = GetCategoriesUseCase(repository: homeRepository);
    getMealsByCategoryUseCase =
        GetMealsByCategoryUseCase(repository: homeRepository);
    getAreasUseCase = GetAreasUseCase(repository: homeRepository);
    getMealsByAreaUseCase = GetMealsByAreaUseCase(repository: homeRepository);
    getMealByIdUseCase = GetMealByIdUseCase(repository: mealRepository);

    appState = AppState(
      authRepository: authRepository,
      favoritesLocalDataSource: favoritesLocalDataSource,
    );
    appRouter = AppRouter(appState: appState);
  }

  static LoginProvider createLoginProvider() =>
      LoginProvider(loginUseCase: loginUseCase);
  static RegisterProvider createRegisterProvider() =>
      RegisterProvider(registerUseCase: registerUseCase);
  static HomeProvider createHomeProvider() => HomeProvider(
    searchMealsUseCase: searchMealsUseCase,
    getCategoriesUseCase: getCategoriesUseCase,
    getMealsByCategoryUseCase: getMealsByCategoryUseCase,
    getAreasUseCase: getAreasUseCase,
    getMealsByAreaUseCase: getMealsByAreaUseCase,
  );
  static MealDetailProvider createMealDetailProvider() =>
      MealDetailProvider(getMealByIdUseCase: getMealByIdUseCase);
  static ProfileProvider createProfileProvider() => ProfileProvider(
    authRepository: authRepository,
    favoritesLocalDataSource: favoritesLocalDataSource,
  );
  static FavoritesProvider createFavoritesProvider() => FavoritesProvider(
    favoritesRepository: favoritesRepository,
    mealRepository: mealRepository,
  );
  static CartProvider createCartProvider() =>
      CartProvider(cartRepository: cartRepository);
  static OrdersProvider createOrdersProvider() =>
      OrdersProvider(ordersRepository: ordersRepository);
}