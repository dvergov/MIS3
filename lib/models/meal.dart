class Meal {
  final String id;
  final String name;
  final String imageUrl;
  final String? category;
  final bool isFavorite;

  Meal({
    required this.id,
    required this.name,
    required this.imageUrl,
    this.category,
    this.isFavorite = false,
  });

  factory Meal.fromJson(Map<String, dynamic> json) {
    return Meal(
      id: json['idMeal'],
      name: json['strMeal'],
      imageUrl: json['strMealThumb'],
      category: json['strCategory'],
    );
  }

  Meal copyWith({
    String? id,
    String? name,
    String? imageUrl,
    String? category,
    bool? isFavorite,
  }) {
    return Meal(
      id: id ?? this.id,
      name: name ?? this.name,
      imageUrl: imageUrl ?? this.imageUrl,
      category: category ?? this.category,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }
}