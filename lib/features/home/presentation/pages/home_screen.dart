import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../../core/router/routes.dart';
import '../../../../shared/components/molecules/category_filter.dart';
import '../../../../shared/components/molecules/loading_widget.dart';
import '../../../../shared/components/molecules/restaurant_meal_card.dart';
import '../../../../shared/components/organisms/app_drawer.dart';
import '../../../../shared/components/organisms/filter_bottom_sheet.dart';
import '../providers/home_provider.dart';
import '../../../../shared/components/molecules/error_widget.dart' as app_error;

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _searchController = TextEditingController();
  bool _showSearch = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<HomeProvider>(context, listen: false).loadInitialData();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _performSearch(String query) {
    if (query.isNotEmpty) {
      Provider.of<HomeProvider>(context, listen: false).searchMeals(query);
    }
  }

  void _showFilterBottomSheet(
      BuildContext context, HomeProvider homeProvider) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return FractionallySizedBox(
          heightFactor: 0.6,
          child: FilterBottomSheet(
            areas: homeProvider.areas,
            selectedArea: homeProvider.selectedArea,
            onAreaSelected: (area) {
              homeProvider.filterByArea(area);
            },
          ),
        );
      },
    );
  }

  List<CategoryItem> _buildCategoryItems(List<String> categories) {
    final categoryImages = {
      'Beef': 'https://www.themealdb.com/images/category/beef.png',
      'Chicken': 'https://www.themealdb.com/images/category/chicken.png',
      'Dessert': 'https://www.themealdb.com/images/category/dessert.png',
      'Lamb': 'https://www.themealdb.com/images/category/lamb.png',
      'Miscellaneous':'https://www.themealdb.com/images/category/miscellaneous.png',
      'Pasta': 'https://www.themealdb.com/images/category/pasta.png',
      'Pork': 'https://www.themealdb.com/images/category/pork.png',
      'Seafood': 'https://www.themealdb.com/images/category/seafood.png',
      'Side':'https://www.themealdb.com/images/category/side.png',
      'Starter':'https://www.themealdb.com/images/category/starter.png',
      'Vegan':'https://www.themealdb.com/images/category/vegan.png',
      'Vegetarian': 'https://www.themealdb.com/images/category/vegetarian.png',
      'Breakfast':'https://www.themealdb.com/images/category/breakfast.png',
      'Goat':'https://www.themealdb.com/images/category/goat.png'
    };

    return categories
        .map((category) => CategoryItem(
      name: category,
      imageUrl: categoryImages[category] ?? '',
    ))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final homeProvider = Provider.of<HomeProvider>(context);

    return Scaffold(
      appBar: AppBar(
        leading: Builder(
          builder: (context) {
            return IconButton(
              icon: const Icon(Icons.menu),
              onPressed: () {
                Scaffold.of(context).openDrawer();
              },
            );
          },
        ),
        title: _showSearch
            ? TextField(
          controller: _searchController,
          autofocus: true,
          decoration: InputDecoration(
            hintText: 'Buscar comida...',
            border: InputBorder.none,
            hintStyle: TextStyle(color: Theme.of(context).hintColor),
          ),
          onSubmitted: _performSearch,
        )
            : const Text(
          'Bienvenido',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(_showSearch ? Icons.close : Icons.search),
            onPressed: () {
              setState(() {
                _showSearch = !_showSearch;
                if (!_showSearch) {
                  _searchController.clear();
                  homeProvider.reset();
                }
              });
            },
          ),
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () {
              _showFilterBottomSheet(context, homeProvider);
            },
          ),
        ],
      ),
      drawer: const AppDrawer(),
      body: LayoutBuilder(builder: (context, constraints) {
        return CustomScrollView(
          slivers: [
            if (homeProvider.categories.isNotEmpty)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: CategoryFilter(
                    categories: _buildCategoryItems(homeProvider.categories),
                    selectedCategory: homeProvider.selectedCategory,
                    onCategorySelected: (category) {
                      homeProvider.filterByCategory(category);
                    },
                  ),
                ),
              ),
            _buildContent(homeProvider, constraints),
          ],
        );
      }),
    );
  }

  Widget _buildContent(HomeProvider homeProvider, BoxConstraints constraints) {
    final isTablet = constraints.maxWidth > 600;
    final padding = isTablet ? 24.0 : 16.0;

    if (homeProvider.state == HomeState.initial) {
      return SliverFillRemaining(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.search,
                size: 80,
                color: Theme.of(context).hintColor,
              ),
              const SizedBox(height: 10),
              Text(
                'Busca tu comida favorita',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                  color:
                  Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                ),
              ),
              Text(
                'o filtra por categorías',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Theme.of(context).hintColor,
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (homeProvider.state == HomeState.loading) {
      return const SliverFillRemaining(
        child: LoadingWidget(message: 'Cargando...'),
      );
    }

    if (homeProvider.state == HomeState.error) {
      return SliverFillRemaining(
        child: app_error.ErrorWidget(
          message: homeProvider.errorMessage ?? 'Ocurrió un error',
          onRetry: () {
            if (homeProvider.selectedCategory != null) {
              homeProvider.filterByCategory(homeProvider.selectedCategory);
            } else if (homeProvider.selectedArea != null) {
              homeProvider.filterByArea(homeProvider.selectedArea);
            } else {
              homeProvider.reset();
            }
          },
        ),
      );
    }

    if (homeProvider.meals.isEmpty) {
      return const SliverFillRemaining(
        child: Center(
          child: Text('No se encontraron resultados'),
        ),
      );
    }

    int crossAxisCount = (constraints.maxWidth / 350).floor().clamp(1, 4);

    return SliverPadding(
      padding: EdgeInsets.all(padding),
      sliver: SliverGrid.builder(
        itemCount: homeProvider.meals.length,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: crossAxisCount,
          crossAxisSpacing: padding,
          mainAxisSpacing: padding,
          mainAxisExtent: 320,
        ),
        itemBuilder: (context, index) {
          final meal = homeProvider.meals[index];
          return RestaurantMealCard(
            imageUrl: meal.thumbnail,
            title: meal.name,
            deliveryTime: 30 + (index * 5),
            category: meal.category,
            area: meal.area,
            rating: 0.88 + (index * 0.02),
            votes: 24 + (index * 5),
            onTap: () {
              context.pushNamed(
                AppRoutes.mealDetail,
                pathParameters: {'id': meal.id},
              );
            },
          );
        },
      ),
    );
  }
}