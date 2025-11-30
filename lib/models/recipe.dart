class Recipe {
  final String id;
  final String name;
  final String instructions;
  final String imageUrl;
  final String? youtubeUrl;
  final List<Ingredient> ingredients;
  final bool isFavorite;

  Recipe({
    required this.id,
    required this.name,
    required this.instructions,
    required this.imageUrl,
    this.youtubeUrl,
    required this.ingredients,
    this.isFavorite = false,
  });

  factory Recipe.fromJson(Map<String, dynamic> json) {
    List<Ingredient> ingredients = [];

    for (int i = 1; i <= 20; i++) {
      String ingredient = json['strIngredient$i'] ?? '';
      String measure = json['strMeasure$i'] ?? '';

      if (ingredient.trim().isNotEmpty) {
        ingredients.add(Ingredient(
          name: ingredient,
          measure: measure,
        ));
      }
    }

    return Recipe(
      id: json['idMeal'],
      name: json['strMeal'],
      instructions: json['strInstructions'] ?? '',
      imageUrl: json['strMealThumb'],
      youtubeUrl: json['strYoutube'],
      ingredients: ingredients,
    );
  }

  Recipe copyWith({
    String? id,
    String? name,
    String? instructions,
    String? imageUrl,
    String? youtubeUrl,
    List<Ingredient>? ingredients,
    bool? isFavorite,
  }) {
    return Recipe(
      id: id ?? this.id,
      name: name ?? this.name,
      instructions: instructions ?? this.instructions,
      imageUrl: imageUrl ?? this.imageUrl,
      youtubeUrl: youtubeUrl ?? this.youtubeUrl,
      ingredients: ingredients ?? this.ingredients,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }
}

class Ingredient {
  final String name;
  final String measure;

  Ingredient({
    required this.name,
    required this.measure,
  });
}