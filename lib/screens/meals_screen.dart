import 'package:flutter/material.dart';
import '../models/meal.dart';
import '../services/meal_service.dart';
import '../widgets/meal_card.dart';
import '../widgets/search_bar.dart' as custom; // Use alias
import 'recipe_detail_screen.dart';

class MealsScreen extends StatefulWidget {
  final String category;

  const MealsScreen({Key? key, required this.category}) : super(key: key);

  @override
  _MealsScreenState createState() => _MealsScreenState();
}

class _MealsScreenState extends State<MealsScreen> {
  List<Meal> _meals = [];
  List<Meal> _filteredMeals = [];
  bool _isLoading = true;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadMeals();
  }

  Future<void> _loadMeals() async {
    try {
      final meals = await MealService.getMealsByCategory(widget.category);
      setState(() {
        _meals = meals;
        _filteredMeals = meals;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showErrorSnackBar('Failed to load meals');
    }
  }

  Future<void> _searchMeals(String query) async {
    setState(() {
      _searchQuery = query;
      _isLoading = true;
    });

    try {
      List<Meal> results;
      if (query.isEmpty) {
        results = await MealService.getMealsByCategory(widget.category);
      } else {
        results = await MealService.searchMeals(query);
        results = results.where((meal) => meal.category == widget.category).toList();
      }

      setState(() {
        _filteredMeals = results;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showErrorSnackBar('Failed to search meals');
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.category} Meals'),
      ),
      body: Column(
        children: [
          custom.SearchBar(
            onSearch: _searchMeals,
            hintText: 'Search meals...',
          ),
          Expanded(
            child: _isLoading
                ? Center(child: CircularProgressIndicator())
                : _filteredMeals.isEmpty
                ? Center(
              child: Text(
                _searchQuery.isEmpty
                    ? 'No meals found in ${widget.category}'
                    : 'No meals found for "$_searchQuery"',
                style: TextStyle(fontSize: 16),
              ),
            )
                : GridView.builder(
              padding: EdgeInsets.all(8),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
                childAspectRatio: 0.75,
              ),
              itemCount: _filteredMeals.length,
              itemBuilder: (context, index) {
                final meal = _filteredMeals[index];
                return MealCard(
                  meal: meal,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => RecipeDetailScreen(mealId: meal.id),
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