import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'app/my_app.dart';
import 'core/di/injector.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  await Injector.init();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: Injector.appState),
        ChangeNotifierProvider(create: (_) => Injector.createLoginProvider()),
        ChangeNotifierProvider(create: (_) => Injector.createRegisterProvider()),
        ChangeNotifierProvider(create: (_) => Injector.createHomeProvider()),
        ChangeNotifierProvider(
            create: (_) => Injector.createMealDetailProvider()),
        ChangeNotifierProvider(create: (_) => Injector.createProfileProvider()),
        ChangeNotifierProvider(
            create: (_) => Injector.createFavoritesProvider()),
        ChangeNotifierProvider(create: (_) => Injector.createCartProvider()),
        ChangeNotifierProvider(create: (_) => Injector.createOrdersProvider()),
      ],
      child: MyApp(router: Injector.appRouter),
    ),
  );
}