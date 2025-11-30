import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher_string.dart';
import '../models/recipe.dart';
import '../services/meal_service.dart';
import '../services/favorites_service.dart';
import '../services/analytics_service.dart';
import '../widgets/favorite_button.dart';

class RecipeDetailScreen extends StatefulWidget {
  final String? mealId;
  final Recipe? recipe;
  final Function(bool)? onFavoriteToggle;

  const RecipeDetailScreen({
    Key? key,
    this.mealId,
    this.recipe,
    this.onFavoriteToggle,
  }) : super(key: key);

  @override
  _RecipeDetailScreenState createState() => _RecipeDetailScreenState();
}

class _RecipeDetailScreenState extends State<RecipeDetailScreen> {
  Recipe? _recipe;
  bool _isLoading = true;
  bool _hasLoggedView = false;

  @override
  void initState() {
    super.initState();
    if (widget.recipe != null) {
      _recipe = widget.recipe;
      _isLoading = false;
      _logRecipeView();
    } else {
      _loadRecipe();
    }
  }

  Future<void> _loadRecipe() async {
    if (widget.mealId == null) return;

    try {
      final recipe = await MealService.getRecipeById(widget.mealId!);
      final isFavorite = await FavoritesService.isFavorite(recipe.id);
      setState(() {
        _recipe = recipe.copyWith(isFavorite: isFavorite);
        _isLoading = false;
      });
      _logRecipeView();
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showErrorSnackBar('Failed to load recipe');
    }
  }

  void _logRecipeView() {
    if (_recipe != null && !_hasLoggedView) {
      AnalyticsService.logRecipeView(_recipe!.id, _recipe!.name);
      _hasLoggedView = true;
      print('📊 Analytics: Logged view for ${_recipe!.name}');
    }
  }

  void _toggleFavorite(bool isFavorite) async {
    if (_recipe == null) return;

    AnalyticsService.logFavoriteAction(_recipe!.id, isFavorite);
    print('📊 Analytics: Logged ${isFavorite ? 'favorite' : 'unfavorite'} for ${_recipe!.name}');

    if (isFavorite) {
      await FavoritesService.addToFavorites(_recipe!.id);
    } else {
      await FavoritesService.removeFromFavorites(_recipe!.id);
    }

    setState(() {
      _recipe = _recipe!.copyWith(isFavorite: isFavorite);
    });

    widget.onFavoriteToggle?.call(isFavorite);
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  Future<void> _launchYoutubeVideo(String url) async {
    if (_recipe != null) {
      AnalyticsService.logEvent(
        name: 'youtube_click',
        parameters: {
          'recipe_id': _recipe!.id,
          'recipe_name': _recipe!.name,
        },
      );
      print('📊 Analytics: Logged YouTube click for ${_recipe!.name}');
    }

    if (await canLaunchUrlString(url)) {
      await launchUrlString(url);
    } else {
      _showErrorSnackBar('Could not launch YouTube');
    }
  }

  void _logInstructionsRead() {
    if (_recipe != null) {
      AnalyticsService.logEvent(
        name: 'instructions_read',
        parameters: {
          'recipe_id': _recipe!.id,
          'recipe_name': _recipe!.name,
        },
      );
      print('📊 Analytics: Logged instructions read for ${_recipe!.name}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_recipe?.name ?? 'Recipe Details'),
        actions: [
          if (_recipe != null)
            FavoriteButton(
              isFavorite: _recipe!.isFavorite,
              onPressed: _toggleFavorite,
            ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _recipe == null
          ? Center(child: Text('Recipe not found'))
          : SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Image.network(
              _recipe!.imageUrl,
              height: 250,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  height: 250,
                  color: Colors.grey[200],
                  child: Icon(Icons.fastfood, size: 60, color: Colors.grey),
                );
              },
            ),

            Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _recipe!.name,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 16),

                  if (_recipe!.youtubeUrl != null && _recipe!.youtubeUrl!.isNotEmpty)
                    Column(
                      children: [
                        ElevatedButton.icon(
                          icon: Icon(Icons.play_arrow),
                          label: Text('Watch on YouTube'),
                          onPressed: () => _launchYoutubeVideo(_recipe!.youtubeUrl!),
                        ),
                        SizedBox(height: 16),
                      ],
                    ),

                  Text(
                    'Ingredients:',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  ..._recipe!.ingredients.map((ingredient) => Padding(
                    padding: EdgeInsets.symmetric(vertical: 2),
                    child: Text(
                      '• ${ingredient.measure} ${ingredient.name}',
                      style: TextStyle(fontSize: 16),
                    ),
                  )),
                  SizedBox(height: 16),

                  Text(
                    'Instructions:',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  NotificationListener<ScrollNotification>(
                    onNotification: (scrollNotification) {
                      if (scrollNotification is ScrollEndNotification) {
                        final metrics = scrollNotification.metrics;
                        if (metrics.pixels >= metrics.maxScrollExtent * 0.8) {
                          _logInstructionsRead();
                        }
                      }
                      return false;
                    },
                    child: Text(
                      _recipe!.instructions,
                      style: TextStyle(fontSize: 16, height: 1.5),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}