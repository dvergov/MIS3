import 'package:flutter/material.dart';
import '../models/category.dart';
import '../services/meal_service.dart';
import '../services/favorites_service.dart';
import '../widgets/category_card.dart';
import '../widgets/search_bar.dart' as custom;
import 'meals_screen.dart';
import 'recipe_detail_screen.dart';
import 'favorites_screen.dart';

class CategoriesScreen extends StatefulWidget {
  @override
  _CategoriesScreenState createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {
  List<Category> _categories = [];
  List<Category> _filteredCategories = [];
  bool _isLoading = true;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    try {
      final categories = await MealService.getCategories();
      setState(() {
        _categories = categories;
        _filteredCategories = categories;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showErrorSnackBar('Failed to load categories');
    }
  }

  void _searchCategories(String query) {
    setState(() {
      _searchQuery = query;
      if (query.isEmpty) {
        _filteredCategories = _categories;
      } else {
        _filteredCategories = _categories
            .where((category) =>
            category.name.toLowerCase().contains(query.toLowerCase()))
            .toList();
      }
    });
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _navigateToRandomRecipe() async {
    try {
      final randomRecipe = await MealService.getRandomRecipe();
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => RecipeDetailScreen(
            recipe: randomRecipe,
            onFavoriteToggle: (isFavorite) {
              if (isFavorite) {
                FavoritesService.addToFavorites(randomRecipe.id);
              } else {
                FavoritesService.removeFromFavorites(randomRecipe.id);
              }
            },
          ),
        ),
      );
    } catch (e) {
      _showErrorSnackBar('Failed to load random recipe');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Recipe Categories'),
        actions: [
          IconButton(
            icon: Icon(Icons.favorite),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => FavoritesScreen(),
                ),
              );
            },
            tooltip: 'Favorite Recipes',
          ),
          IconButton(
            icon: Icon(Icons.shuffle),
            onPressed: _navigateToRandomRecipe,
            tooltip: 'Random Recipe',
          ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : Column(
        children: [
          custom.SearchBar(
            onSearch: _searchCategories,
            hintText: 'Search categories...',
          ),
          Expanded(
            child: _filteredCategories.isEmpty
                ? Center(
              child: Text(
                _searchQuery.isEmpty
                    ? 'No categories found'
                    : 'No categories found for "$_searchQuery"',
                style: TextStyle(fontSize: 16),
              ),
            )
                : GridView.builder(
              padding: EdgeInsets.all(8),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
                childAspectRatio: 0.8,
              ),
              itemCount: _filteredCategories.length,
              itemBuilder: (context, index) {
                final category = _filteredCategories[index];
                return CategoryCard(
                  category: category,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => MealsScreen(category: category.name),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}