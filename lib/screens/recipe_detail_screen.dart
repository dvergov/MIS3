import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher_string.dart'; // Use url_launcher_string instead
import '../models/recipe.dart';
import '../services/meal_service.dart';

class RecipeDetailScreen extends StatefulWidget {
  final String? mealId;
  final Recipe? recipe;

  const RecipeDetailScreen({Key? key, this.mealId, this.recipe}) : super(key: key);

  @override
  _RecipeDetailScreenState createState() => _RecipeDetailScreenState();
}

class _RecipeDetailScreenState extends State<RecipeDetailScreen> {
  Recipe? _recipe;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    if (widget.recipe != null) {
      _recipe = widget.recipe;
      _isLoading = false;
    } else {
      _loadRecipe();
    }
  }

  Future<void> _loadRecipe() async {
    if (widget.mealId == null) return;

    try {
      final recipe = await MealService.getRecipeById(widget.mealId!);
      setState(() {
        _recipe = recipe;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showErrorSnackBar('Failed to load recipe');
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

  Future<void> _launchYoutubeVideo(String url) async {
    if (await canLaunchUrlString(url)) {
      await launchUrlString(url);
    } else {
      _showErrorSnackBar('Could not launch YouTube');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_recipe?.name ?? 'Recipe Details'),
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
                  Text(
                    _recipe!.instructions,
                    style: TextStyle(fontSize: 16, height: 1.5),
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