import 'dart:convert';
import 'package:http/http.dart' as http; // This should work after running flutter pub get
import '../models/category.dart';
import '../models/meal.dart';
import '../models/recipe.dart';

class MealService {
  static const String baseUrl = 'https://www.themealdb.com/api/json/v1/1';

  static Future<List<Category>> getCategories() async {
    final response = await http.get(Uri.parse('$baseUrl/categories.php'));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      List<dynamic> categoriesJson = data['categories'];
      return categoriesJson.map((json) => Category.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load categories');
    }
  }

  static Future<List<Meal>> getMealsByCategory(String category) async {
    final response = await http.get(Uri.parse('$baseUrl/filter.php?c=$category'));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      List<dynamic> mealsJson = data['meals'] ?? [];
      return mealsJson.map((json) => Meal.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load meals');
    }
  }

  static Future<List<Meal>> searchMeals(String query) async {
    final response = await http.get(Uri.parse('$baseUrl/search.php?s=$query'));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      List<dynamic> mealsJson = data['meals'] ?? [];
      return mealsJson.map((json) => Meal.fromJson(json)).toList();
    } else {
      throw Exception('Failed to search meals');
    }
  }

  static Future<Recipe> getRecipeById(String id) async {
    final response = await http.get(Uri.parse('$baseUrl/lookup.php?i=$id'));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      List<dynamic> mealsJson = data['meals'];
      if (mealsJson != null && mealsJson.isNotEmpty) {
        return Recipe.fromJson(mealsJson.first);
      } else {
        throw Exception('Recipe not found');
      }
    } else {
      throw Exception('Failed to load recipe');
    }
  }

  static Future<Recipe> getRandomRecipe() async {
    final response = await http.get(Uri.parse('$baseUrl/random.php'));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      List<dynamic> mealsJson = data['meals'];
      return Recipe.fromJson(mealsJson.first);
    } else {
      throw Exception('Failed to load random recipe');
    }
  }
}